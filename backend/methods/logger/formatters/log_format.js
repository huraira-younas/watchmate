const { format } = require("winston");

module.exports = format.combine(
  format.timestamp({ format: "YYYY-MM-DD hh:mm:ss A" }),
  format.printf(({ timestamp, level, message }) => {
    return `[${timestamp}] ${level.toUpperCase()}: ${message}`;
  })
);
