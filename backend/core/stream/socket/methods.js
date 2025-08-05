const {
  SocketError,
  validateEvent,
  SocketResponse,
} = require("../../../methods/socket/socket_methods.js");
const Video = require("../../../database/models/video_model.js");
const logger = require("../../../methods/logger");
const sanitize = require("sanitize-filename");
const ytdl = require("@distube/ytdl-core");
const fs = require("fs-extra");
const path = require("path");

const BASE = path.join(process.cwd(), "app_data");
const INACTIVITY_TIMEOUT_MS = 30000;

const downloadYT = async ({ event, socket, data }) => {
  let filePath;

  try {
    validateEvent(data, ["userId", "url"]);
    const { userId, url } = data;

    if (!ytdl.validateURL(url)) {
      throw new SocketError("Invalid YouTube URL", 400);
    }

    logger.info(`Fetching info for YouTube URL: ${url}`);
    const info = await ytdl.getInfo(url);
    const details = info.videoDetails;
    const title = sanitize(details.title);
    const filename = `${title}-${Date.now()}.mp4`;
    filePath = path.resolve(BASE, "downloads/youtube", userId, filename);

    const videoData = {
      thumbnailURL: details.thumbnails.at(-1)?.url,
      visibility: "public",
      title: details.title,
      videoURL: filePath,
      type: "youtube",
      userId,
    };

    logger.info(`Preparing to download "${title}" to ${filePath}`);
    fs.mkdirSync(path.dirname(filePath), { recursive: true });

    const format = ytdl.chooseFormat(info.formats, {
      quality: "highestvideo",
      filter: (f) => f.container === "mp4" && f.hasVideo && f.hasAudio,
    });

    if (!format) {
      throw new SocketError(
        "No suitable MP4 format with both video and audio found.",
        400
      );
    }

    const totalBytes = parseInt(format.contentLength || "0", 10);
    const writeStream = fs.createWriteStream(filePath);
    const videoStream = ytdl(url, { format });

    let lastPercent = 0;
    let downloaded = 0;
    let timeout;

    const resetTimeout = () => {
      clearTimeout(timeout);
      timeout = setTimeout(() => {
        const err = new Error("Download timed out due to inactivity.");
        videoStream.destroy(err);
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

    resetTimeout();
    await new Promise((resolve, reject) => {
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

      videoStream.on("error", (err) => {
        clearTimeout(timeout);
        reject(new SocketError(`Download error: ${err.message}`, 500));
      });

      videoStream.on("end", () => {
        logger.debug(`Download stream ended for ${filename}`);
      });

      writeStream.on("finish", () => {
        logger.info(`File write finished for ${filename}`);
        clearTimeout(timeout);
        resolve();
      });

      writeStream.on("error", (err) => {
        clearTimeout(timeout);
        reject(
          new SocketError(
            `Could not write downloaded file to disk: ${err.message}`,
            500
          )
        );
      });

      videoStream.pipe(writeStream);
    });

    logger.info(`Download complete for ${filename}. Saving to database.`);
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
    logger.error(`An error occurred during YouTube download: ${err.stack}`);
    if (filePath) fs.unlinkSync(filePath).catch((_) => {});
    socket.emit(
      event,
      new SocketResponse({
        message: err.message || "An unexpected error occurred.",
        code: err.code || 500,
      })
    );
  }
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
