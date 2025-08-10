const {
  validateEvent,
  SocketResponse,
} = require("../../../methods/socket/socket_methods.js");
const R2Client = require("../../../clients/r2_client.js");
const User = require("../../../database/models/user_model");
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

const pauseDownload = ({ event, socket, data }) => {
  validateEvent(data, ["id"]);
  const { id } = data;
  const download = DownloadManager.get(id);
  if (download) download.pause();
  else {
    socket.emit(
      event,
      new SocketResponse({ message: "Download not found", code: 404 })
    );
  }
};

const resumeDownload = ({ event, socket, data }) => {
  validateEvent(data, ["id"]);
  const { id } = data;
  const download = DownloadManager.get(id);
  if (download) download.resume();
  else {
    socket.emit(
      event,
      new SocketResponse({ message: "Download not found", code: 404 })
    );
  }
};

const stopDownload = ({ event, socket, data }) => {
  validateEvent(data, ["id"]);
  const { id } = data;
  const download = DownloadManager.get(id);
  if (download) download.stop();
  else {
    socket.emit(
      event,
      new SocketResponse({ message: "Download not found", code: 404 })
    );
  }
};

module.exports = {
  resumeDownload,
  pauseDownload,
  stopDownload,
  download,
};
