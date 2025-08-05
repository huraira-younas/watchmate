const { SocketParams } = require("../../../methods/socket/socket_methods");
const socketHandler = require("../../../methods/socket/socket_handler");
const logger = require("../../../methods/logger");
const { event, namespace } = require("./enums");
const methods = require("./methods");

const events = (io) => {
  const _connect = (data, socket) =>
    socketHandler(
      methods.connectUser,
      new SocketParams({ event: event.CONNECT_USER, socket, data, io })
    );

  io.on(event.CONNECTION, (socket) => {
    logger.info(`[SOCKET:${namespace.toUpperCase()}]: Connected: ${socket.id}`);

    _connect({ userId: socket.handshake.query.userId }, socket);
    socket.on(event.CONNECT_USER, (d) => _connect(d, socket));

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
