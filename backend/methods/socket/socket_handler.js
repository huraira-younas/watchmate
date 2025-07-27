const { getFriendlySqlError } = require("../sql_errors");
const { SocketError } = require("./socket_methods");
const logger = require("../logger");
const chalk = require("chalk");

const socketHandler = (fn, { event, io, socket, data }) => {
  const separator = "-".repeat(80);

  logger.info(`🛜  Socket Event Received: ${event}`);
  console.log(chalk.white.bold(separator));

  if (data && Object.keys(data).length > 0) {
    logger.info(`➡️  [SOCKET EVENT] ${event} - Data Received`);
    logger.info(chalk.cyanBright(JSON.stringify(data, null, 2)));
  } else {
    logger.info(`➡️  [SOCKET EVENT] ${event} - No Data`);
  }

  console.log(chalk.white.bold(separator));

  Promise.resolve(fn({ event, io, socket, data })).catch((err) => {
    const code = err instanceof SocketError ? err.statusCode : 500;
    const isSocketError = err instanceof SocketError;

    (code === 400 ? logger.warn : logger.error)(
      `😵 [SOCKET EVENT] ${event} - Error: ${err.message}`,
      {
        timestamp: new Date().toISOString(),
        handshake: socket.handshake,
        socketId: socket.id,
        stack: err.stack,
      }
    );

    socket.emit(event, {
      error: isSocketError ? err.message : getFriendlySqlError(err),
      code,
    });
  });
};

module.exports = socketHandler;
