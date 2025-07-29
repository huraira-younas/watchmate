const { initFirebase } = require("./clients/firebase/firebase_client.js");
const { createAdapter } = require("@socket.io/redis-adapter");
const { initializeDB } = require("./database/methods");
const initializeQueues = require("./bullmq/index.js");
const limiter = require("./clients/rate_limiter");
const redis = require("./redis/redis_client.js");
const loadModules = require("./module_loader");
const logger = require("./methods/logger");
const { Server } = require("socket.io");
const express = require("express");
const http = require("http");
const cors = require("cors");

const pubClient = redis;
const subClient = pubClient.duplicate();

const PORT = process.env.PORT || 5000;
const app = express();

const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*" },
  path: "/v1/socket",
});

io.adapter(createAdapter(pubClient, subClient));
app.use(express.urlencoded({ extended: true }));

const corsOptions = {
  optionsSuccessStatus: 204,
  preflightContinue: false,
  methods: "GET, POST",
  credentials: true,
  origin: "*",
};

app.get("/", (_, res) => res.json("Welcome to WatchMate!"));
app.use(cors(corsOptions));
app.use(express.json());
app.use(limiter);

const runApp = () => {
  loadModules(app, io)
    .then(async () => {
      server.listen(PORT, "0.0.0.0", () =>
        logger.info(`🚀 Server running: ${PORT}`)
      );
      await initializeQueues();
      await initializeDB();
      initFirebase().then((r) => {
        if (r.success) logger.info("✅ Firebase initialized");
        else logger.warn(`⚠️  Firebase initialized failed: ${r.error}`);
      });
    })
    .catch((e) => logger.error(`Error: ${e.message}`));
};

module.exports = runApp;
