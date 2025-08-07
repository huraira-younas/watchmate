const {
  validateEvent,
  SocketResponse,
} = require("../../../methods/socket/socket_methods.js");
const { Download, DownloadManager } = require("../download_service");
const logger = require("../../../methods/logger");

const download = async ({ event, socket, data }) => {
  try {
    validateEvent(data, ["userId", "url", "type", "visibility"]);
    const { userId, url, visibility, type, title } = data;

    const download = new Download({
      userId,
      socket,
      event,
      type,
      url,
    });

    await download.init(visibility, title);
    DownloadManager.add(download);

    socket.emit(
      event,
      new SocketResponse({
        data: { id: download.id, ...download.videoData },
        message: "Download started",
        code: 201,
      })
    );
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
