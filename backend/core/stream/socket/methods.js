const {
  validateEvent,
  SocketResponse,
} = require("../../../methods/socket/socket_methods.js");
const User = require("../../../database/models/user_model");
const R2Client = require("../../../clients/r2_client.js");
const logger = require("../../../methods/logger");

const download = async ({ event, socket, data }) => {
  try {
    validateEvent(data, ["userId", "url", "type", "visibility"]);
    const { userId, url, visibility, title, type, thumbnail } = data;

    const user = await User.findById(userId, ["name", "profileURL", "id"]);
    const r2 = new R2Client({ socket, event, user, url });
    await r2.start(type, visibility, title, thumbnail);
  } catch (err) {
    logger.error(`An error occurred during download: ${err.stack}`);
    socket.emit(
      event,
      new SocketResponse({
        message: err.message || "An unexpected error occurred.",
        code: err.code || 500,
      })
    );
  }
};

module.exports = { download };
