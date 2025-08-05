const {
  SocketError,
  validateEvent,
  SocketResponse,
} = require("../../../methods/socket/socket_methods.js");
const logger = require("../../../methods/logger");
const sanitize = require("sanitize-filename");
const ytdl = require("@distube/ytdl-core");
const path = require("path");
const fs = require("fs");

const BASE = path.join(process.cwd(), "app_data");

const downloadYT = async ({ event, socket, data }) => {
  validateEvent(data, ["userId", "url"]);
  const { userId, url } = data;

  if (!ytdl.validateURL(url)) {
    throw new SocketError("Invalid YouTube URL", 400);
  }

  const info = await ytdl.getInfo(url);
  const title = sanitize(info.videoDetails.title);

  const filename = `${title}-${Date.now()}.mp4`;
  const filePath = path.resolve(BASE, "downloads/youtube", userId, filename);

  fs.mkdirSync(path.dirname(filePath), { recursive: true });

  const format =
    info.formats.find(
      (f) => f.itag === 137 || (f.hasVideo && f.hasAudio && f.isProgressive)
    ) || info.formats[0];

  const totalBytes = parseInt(format?.contentLength || "0", 10);
  const videoStream = await ytdl(url, { quality: "highestvideo" });

  const writeStream = fs.createWriteStream(filePath);
  videoStream.pipe(writeStream);

  let lastPercent = 0;
  let downloaded = 0;

  videoStream.on("data", (chunk) => {
    downloaded += chunk.length;
    if (totalBytes > 0) {
      const percent = parseFloat(((downloaded / totalBytes) * 100).toFixed(2));
      if (percent > lastPercent) {
        lastPercent = percent;
        socket.emit(
          event,
          new SocketResponse({
            message: `Downloading ${filename}`,
            data: { percent, downloaded, total: totalBytes },
          })
        );
      }
    }
  });

  writeStream.on("finish", () => {
    socket.emit(
      event,
      new SocketResponse({
        message: `Downloaded ${filename} successfully`,
        data: { downloaded: totalBytes, total: totalBytes, percent: 100 },
      })
    );
  });

  videoStream.on("error", (err) => {
    logger.error(`Download ${filename} error: ${err}`);
    socket.emit(
      event,
      new SocketResponse({
        message: `File download error: ${err.message}`,
        code: 500,
      })
    );
  });

  writeStream.on("error", (err) => {
    logger.error(`Write stream error for ${filename}: ${err}`);
    socket.emit(
      event,
      new SocketResponse({
        message: `File saving error: ${err.message}`,
        code: 500,
      })
    );
  });
};

module.exports = {
  downloadYT,
};
