const { rateLimit } = require("express-rate-limit");
const { RedisStore } = require("rate-limit-redis");
const redis = require("../redis/redis_client.js");

const limiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args) => redis.call(...args),
  }),
  keyGenerator: (req) => req.ip,
  windowMs: 15 * 60 * 1000,
  standardHeaders: true,
  legacyHeaders: false,
  limit: 1500,
  handler: (_, res, __, ___) => {
    res.status(500).json({
      message: "Too many requests. Please try again later.",
    });
  },
});

module.exports = limiter;
