const { addToHash, deleteFromHash } = require("../../../redis/redis_methods");
const { SocketParams } = require("../../../methods/socket/socket_methods");
const socketHandler = require("../../../methods/socket/socket_handler");
const { socketKey } = require("../../../redis/admin_keys");
const logger = require("../../../methods/logger");
const { event, namespace } = require("./enums");
const methods = require("./methods");

const events = (io) => {
  const _handleKey = async (userId, socketId) => {
    const key = socketKey(userId, namespace);
    if (socketId) await addToHash(key, socketId, 2440);
    else await deleteFromHash(key);
  };

  io.on(event.CONNECTION, (socket) => {
    logger.info(`[SOCKET:${namespace.toUpperCase()}]: Connected: ${socket.id}`);

    _handleKey(socket.handshake.query.userId, socket.id);
    socket.on("disconnect", () => _handleKey(socket.handshake.query.userId));

    socket.on(event.CREATE_PARTY, (data) =>
      socketHandler(
        methods.createParty,
        new SocketParams({ event: event.CREATE_PARTY, socket, data, io })
      )
    );
  });
};

module.exports = events;
