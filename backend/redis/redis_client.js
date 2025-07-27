const logger = require("../methods/logger");
const { Redis } = require("ioredis");

const redis = new Redis({
  password: process.env.REDIS_PASSWORD,
  port: process.env.REDIS_PORT,
  host: process.env.REDIS_IP,
  maxRetriesPerRequest: null,
});

redis.on("connect", async () => {
  logger.info("Connected to Redis server");
});

redis.on("error", (err) => {
  logger.warn(`Error connecting to Redis: ${err}`);
});

redis.on("ready", () => {
  logger.info("Redis client is ready");
});

redis.on("end", () => {
  logger.info("Redis client disconnected");
});

redis.on("reconnecting", () => {
  logger.info("Reconnecting to Redis");
});

const gracefulShutdown = () => {
  logger.info("Shutting down gracefully...");
  redis.quit((err, res) => {
    if (err) {
      logger.warn(`Error shutting down Redis client: ${err}`);
    } else {
      logger.info(`Redis client shut down: ${res}`);
    }
    process.exit();
  });
};

process.on("SIGTERM", gracefulShutdown);
process.on("SIGUSR2", gracefulShutdown);
process.on("SIGINT", gracefulShutdown);

module.exports = redis;
