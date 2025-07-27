const { SocketParams } = require("../../../methods/socket/socket_methods");
const socketHandler = require("../../../methods/socket/socket_handler");
const logger = require("../../../methods/logger");
const methods = require("./methods");
const event = require("./enums");

const events = (io) => {
  io.on(event.CONNECTION, (socket) => {
    logger.info(`Socket connected: ${socket.id}`);
    socket.on(event.CONNECT_USER, (data) =>
      socketHandler(
        methods.connectUser,
        new SocketParams({ event: event.CONNECT_USER, socket, data, io })
      )
    );

    socket.on("disconnect", () =>
      socketHandler(
        methods.onDisconnect,
        new SocketParams({ event: event.DISCONNECT_USER, socket })
      )
    );

    socket.on(event.DISCONNECT_USER, (data) =>
      socketHandler(
        methods.disconnectUser,
        new SocketParams({ event: event.DISCONNECT_USER, socket, data, io })
      )
    );
  });
};

module.exports = events;
