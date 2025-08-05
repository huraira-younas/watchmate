const { SocketParams } = require("../../../methods/socket/socket_methods");
const socketHandler = require("../../../methods/socket/socket_handler");
const logger = require("../../../methods/logger");
const { event, namespace } = require("./enums");
const methods = require("./methods");

const events = (io) => {
  io.on(event.CONNECTION, (socket) => {
    logger.info(`[SOCKET:${namespace.toUpperCase()}]: Connected: ${socket.id}`);

    socket.on(event.DOWNLOAD_YT, (data) =>
      socketHandler(
        methods.downloadYT,
        new SocketParams({ event: event.DOWNLOAD_YT, socket, data, io })
      )
    );

    socket.on(event.GET_ALL, (data) =>
      socketHandler(
        methods.getAll,
        new SocketParams({ event: event.GET_ALL, socket, data, io })
      )
    );
  });
};

module.exports = events;
