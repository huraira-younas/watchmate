const { EmailOnError } = require("./transports/error_email");
const dailyLog = require("./transports/daily_transport");
const { createLogger, transports } = require("winston");
const errorFile = require("./transports/error_file");

const logger = createLogger({
  transports: [dailyLog, errorFile, EmailOnError],
  level: "info",
});

if (process.env.NODE_ENV !== "production") {
  logger.add(
    new transports.Console({
      format: require("winston").format.combine(
        require("winston").format.colorize(),
        require("winston").format.simple()
      ),
    })
  );
}

module.exports = logger;
