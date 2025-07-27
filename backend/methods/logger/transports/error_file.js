const logFormat = require("../formatters/log_format");
const { transports } = require("winston");
const path = require("path");

module.exports = new transports.File({
  filename: path.join(__dirname, "../logger_logs/error.log"),
  format: logFormat,
  level: "error",
});
