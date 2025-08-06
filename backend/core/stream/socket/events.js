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
        methods.download,
        new SocketParams({ event: event.DOWNLOAD_YT, socket, data, io })
      )
    );

    socket.on(event.DOWNLOAD_DIR, (data) =>
      socketHandler(
        methods.download,
        new SocketParams({ event: event.DOWNLOAD_DIR, socket, data, io })
      )
    );

    socket.on(event.PAUSE_DOWNLOAD, (data) =>
      socketHandler(
        methods.pauseDownload,
        new SocketParams({ event: event.PAUSE_DOWNLOAD, socket, data, io })
      )
    );

    socket.on(event.RESUME_DOWNLOAD, (data) =>
      socketHandler(
        methods.resumeDownload,
        new SocketParams({ event: event.RESUME_DOWNLOAD, socket, data, io })
      )
    );

    socket.on(event.STOP_DOWNLOAD, (data) =>
      socketHandler(
        methods.stopDownload,
        new SocketParams({ event: event.STOP_DOWNLOAD, socket, data, io })
      )
    );
  });
};

module.exports = events;
