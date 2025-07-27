const { getFriendlySqlError } = require("./sql_errors");
const logger = require("./logger");
const chalk = require("chalk");
let requestCount = 0;

class AppError extends Error {
  constructor(message, statusCode = 500) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith("4") ? "fail" : "error";
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

const asyncHandler = (fn) => (req, res) => {
  requestCount++;
  logger.info(`Request Count: ${requestCount}`);

  const l = "-".repeat(80);
  console.log(chalk.white.bold(l));

  logger.info(`➡️  [${req.method}] ${req.originalUrl} - Request Received`);
  let data = req.method === "POST" ? req.body : req.params;

  if (Object.keys(data).length !== 0) {
    data = { status: req.method.toUpperCase(), ...data };
    logger.info(chalk.cyanBright(JSON.stringify(data, null, 2)));
  }

  console.info(chalk.white.bold(l));

  Promise.resolve(fn(req, res)).catch((err) => {
    const code = err instanceof AppError ? err.statusCode : 500;
    const isAppError = err instanceof AppError;

    (code === 400 ? logger.warn : logger.error)(
      `🙂 [${req.method}] ${req.originalUrl} - Error: ${err.message}`,
      {
        userAgent: req.headers["user-agent"],
        timestamp: new Date().toISOString(),
        stack: err.stack,
        ip: req.ip,
      }
    );

    res.status(code).json({
      error: isAppError ? err.message : getFriendlySqlError(err),
    });
  });
};

const getBaseURL = (input) => {
  let url;

  if (typeof input === "string") {
    url = new URL(input);
  } else if (input?.get) {
    const fullUrl =
      input.get("origin") ||
      input.get("referer") ||
      `${input.protocol}://${input.get("host")}`;

    url = new URL(fullUrl);
  } else {
    throw new Error(
      "Invalid input: Must be a valid URL string or Express request object."
    );
  }

  return `${url.protocol}//${url.host}`;
};

const getIpAddress = (req) => {
  const hIp = req.headers["x-forwarded-for"]?.split(",")[0];
  let ip = hIp || req.socket.remoteAddress;

  if (ip.startsWith("::ffff:")) {
    ip = ip.substring(7);
  }

  return ip;
};

function validateReq(fields, requiredFields, exclude = []) {
  if (exclude.includes("*")) {
    for (const key of Object.keys(fields)) {
      if (!requiredFields.includes(key)) delete fields[key];
    }
  } else if (exclude.length > 0) {
    for (const key of exclude) delete fields[key];
  }

  const missing = requiredFields.filter(
    (field) => fields[field] === undefined || fields[field] === null
  );

  if (missing.length) {
    throw new AppError(`Missing required fields: ${missing.join(", ")}`, 400);
  }
}

const capitalizeWords = (str) =>
  str
    ? str
        .split(" ")
        .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
        .join(" ")
    : "";

module.exports = {
  capitalizeWords,
  asyncHandler,
  getIpAddress,
  validateReq,
  getBaseURL,
  AppError,
};
