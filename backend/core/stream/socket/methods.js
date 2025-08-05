const {
  SocketError,
  validateEvent,
  SocketResponse,
} = require("../../../methods/socket/socket_methods.js");
const Video = require("../../../database/models/video_model.js");
const logger = require("../../../methods/logger");
const sanitize = require("sanitize-filename");
const ytdl = require("@distube/ytdl-core");
const path = require("path");
const fs = require("fs");

const BASE = path.join(process.cwd(), "app_data");
const INACTIVITY_TIMEOUT_MS = 10000;

const downloadYT = async ({ event, socket, data }) => {
  validateEvent(data, ["userId", "url"]);
  const { userId, url } = data;

  if (!ytdl.validateURL(url)) {
    throw new SocketError("Invalid YouTube URL", 400);
  }

  const info = await ytdl.getInfo(url);
  const details = info.videoDetails;
  const title = sanitize(details.title);
  const filename = `${title}-${Date.now()}.mp4`;
  const filePath = path.resolve(BASE, "downloads/youtube", userId, filename);

  const videoData = {
    thumbnailURL: details.thumbnails.at(-1)?.url,
    visibility: "public",
    title: details.title,
    videoURL: filePath,
    type: "youtube",
    userId,
  };

  fs.mkdirSync(path.dirname(filePath), { recursive: true });

  const format =
    info.formats.find(
      (f) => f.itag === 137 || (f.hasVideo && f.hasAudio && f.isProgressive)
    ) || info.formats[0];

  const totalBytes = parseInt(format?.contentLength || "0", 10);
  const videoStream = ytdl(url, { quality: "highestvideo" });
  const writeStream = fs.createWriteStream(filePath);
  videoStream.pipe(writeStream);

  let finished = false;
  let lastPercent = 0;
  let downloaded = 0;
  let timeout = null;

  const clearTimers = () => clearTimeout(timeout);
  const resetTimeout = () => {
    clearTimers();
    timeout = setTimeout(() => {
      const err = new Error("Download timed out due to inactivity");
      videoStream.destroy(err);
      writeStream.destroy(err);
    }, INACTIVITY_TIMEOUT_MS);
  };

  const sendProgress = (percent) => {
    socket.emit(
      event,
      new SocketResponse({
        code: 201,
        message: `Downloading ${filename}`,
        data: {
          ...videoData,
          total: totalBytes,
          downloaded,
          percent,
        },
      })
    );
  };

  videoStream.on("data", (chunk) => {
    downloaded += chunk.length;
    resetTimeout();

    if (totalBytes > 0) {
      const percent = (downloaded / totalBytes) * 100;
      const rounded = Math.floor(percent / 5) * 5;

      if (rounded > lastPercent && rounded <= 100) {
        lastPercent = rounded;
        sendProgress(rounded);
      }
    }
  });

  videoStream.on("end", () => {
    logger.debug(`Stream ended for ${filename}`);
    if (!writeStream.closed) {
      writeStream.end();
    }
  });

  writeStream.on("finish", async () => {
    if (finished) return;
    finished = true;
    clearTimers();

    try {
      const saved = await Video.insert({ data: videoData });
      socket.emit(
        event,
        new SocketResponse({
          message: `Downloaded ${filename} successfully`,
          data: saved,
          code: 200,
        })
      );
    } catch (err) {
      logger.error(`DB save error for ${filename}: ${err}`);
      socket.emit(
        event,
        new SocketResponse({
          message: `Database error: ${err.message}`,
          code: 500,
        })
      );
    }
  });

  const handleError = (source) => (err) => {
    if (finished) return;
    finished = true;
    clearTimers();
    logger.error(`${source} error for ${filename}: ${err}`);
    socket.emit(
      event,
      new SocketResponse({
        message: `${source} error: ${err.message}`,
        code: 500,
      })
    );
  };

  videoStream.on("error", handleError("Download"));
  writeStream.on("error", handleError("Write"));

  writeStream.on("close", () => {
    logger.debug(`Write stream closed for ${filename}`);
  });
};

const getAll = async ({ event, socket }) => {
  const videos = await Video.find({});

  socket.emit(
    event,
    new SocketResponse({
      message: `All Videos`,
      data: videos,
      code: 200,
    })
  );
};

module.exports = {
  downloadYT,
  getAll,
};
