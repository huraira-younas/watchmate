const {
  addToSet,
  addToHash,
  removeFromSet,
  deleteFromHash,
} = require("../../../redis/redis_methods.js");
const {
  SocketError,
  validateEvent,
  SocketResponse,
} = require("../../../methods/socket/socket_methods.js");
const User = require("../../../database/models/user_model.js");
const logger = require("../../..//methods/logger");

const onDisconnect = async ({ socket }) => {
  logger.info("From auto disconnect");
  await disconnectUser({ event: "disconnect_user", socket });
};

const connectUser = async ({ event, socket, data }) => {
  validateEvent(data, ["userId"]);
  const { userId } = data;

  if (!userId) throw new SocketError("userId not found", 400);
  socket.userId = userId;

  const user = await User.findByIdAndUpdate({
    data: { disabled: false },
    userId,
  });
  if (!user) throw new SocketError("User not found", 400);

  socket.email = user.email;
  logger.info("User: " + user.email + " connected");
  await Promise.all([
    addToHash(`socket:${userId}`, socket.id, 0),
    deleteFromHash(`disabled:${userId}`),
    addToSet("online_users", userId),
  ]);

  socket.emit(
    event,
    new SocketResponse({ message: "Connected User", data: user })
  );
};

let retries = 3;
const disconnectUser = async ({ event, socket, data }) => {
  const userId = socket.userId || data?.userId;
  try {
    const email = socket.email;

    if (!userId) return;
    const key = `socket:${userId}`;

    await Promise.all([
      removeFromSet("online_users", userId),
      deleteFromHash(key),
    ]);

    delete socket.userId;
    delete socket.email;
    retries = 3;

    socket.broadcast.emit(
      event,
      new SocketResponse({ message: "Disconnected User", data: { userId } })
    );
    logger.info("User: " + email || userId + " disconnected");
  } catch (e) {
    if (retries-- > 0) {
      logger.error(`Retrying... ${retries} attempts left.`);
      await disconnectUser({ event, socket, data });
    } else {
      logger.error(
        `Failed to disconnect user after multiple attempts. ${e.message}`
      );
    }
  }
};

module.exports = {
  disconnectUser,
  onDisconnect,
  connectUser,
};
