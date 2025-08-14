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

  const _leaveParty = (userId, socket) => {
    if (!socket.partyId) return;

    const data = { partyId: socket.partyId, userId };
    socketHandler(
      methods.leaveParty,
      new SocketParams({ event: event.LEAVE_PARTY, socket, data, io })
    );
  };

  io.on(event.CONNECTION, (socket) => {
    logger.warn(`[SOCKET:${namespace.toUpperCase()}]: Connected: ${socket.id}`);

    _handleKey(socket.handshake.query.userId, socket.id);
    socket.on("disconnect", () => {
      const userId = socket.handshake.query.userId;
      _leaveParty(userId, socket);
      _handleKey(userId);
    });

    socket.on(event.CREATE_PARTY, (data) =>
      socketHandler(
        methods.createParty,
        new SocketParams({ event: event.CREATE_PARTY, socket, data, io })
      )
    );

    socket.on(event.LEAVE_PARTY, (data) =>
      socketHandler(
        methods.leaveParty,
        new SocketParams({ event: event.LEAVE_PARTY, socket, data, io })
      )
    );

    socket.on(event.PARTY_MESSAGE, (data) =>
      socketHandler(
        methods.sendMessage,
        new SocketParams({ event: event.PARTY_MESSAGE, socket, data, io })
      )
    );

    socket.on(event.JOIN_PARTY, (data) =>
      socketHandler(
        methods.joinParty,
        new SocketParams({ event: event.JOIN_PARTY, socket, data, io })
      )
    );

    socket.on(event.VIDEO_ACTION, (data) =>
      socketHandler(
        methods.videoAction,
        new SocketParams({ event: event.VIDEO_ACTION, socket, data, io })
      )
    );
  });
};

module.exports = events;
