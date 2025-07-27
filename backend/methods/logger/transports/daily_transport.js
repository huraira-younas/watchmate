const DailyRotateFile = require("winston-daily-rotate-file");
const logFormat = require("../formatters/log_format");
const path = require("path");

const LOG_DIR = path.join(__dirname, "../logger_logs");

module.exports = new DailyRotateFile({
  filename: path.join(LOG_DIR, "%DATE%.log"),
  datePattern: "YYYY-MM-DD",
  format: logFormat,
  maxFiles: "14d",
  maxSize: "10m",
});
