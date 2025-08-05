const {
  SocketError,
  validateEvent,
  SocketResponse,
} = require("../../../methods/socket/socket_methods.js");
const logger = require("../../..//methods/logger");
const sanitize = require("sanitize-filename");
const ytdl = require("ytdl-core");
const path = require("path");
const fs = require("fs");

const BASE = path.join(process.cwd(), "app_data");

const downloadYT = async ({ event, socket, data }) => {
  validateEvent(data, ["userId", "url"]);
  const { userId, url } = data;

  if (!ytdl.validateURL(url)) throw new SocketError("Invalid YouTube URL", 400);

  const info = await ytdl.getInfo(url);
  const title = sanitize(info.videoDetails.title);
  const filename = `${title}-${Date.now()}.mp4`;

  const filePath = path.resolve(BASE, "downloads/youtube", userId, filename);
  fs.mkdirSync(path.dirname(filePath), { recursive: true });

  const format = info.formats.find((f) => f.itag === 137 || f.hasVideo);
  const totalSize = format?.contentLength || "0";

  let downloaded = 0;
  const totalBytes = parseInt(totalSize, 10);

  const videoStream = ytdl(url, { quality: "highestvideo" });
  const writeStream = fs.createWriteStream(filePath);
  videoStream.pipe(writeStream);

  videoStream.on("progress", (_, chunkLength, downloadedBytes) => {
    downloaded += chunkLength;
    if (totalBytes > 0) {
      const percent = ((downloadedBytes / totalBytes) * 100).toFixed(2);
      const response = new SocketResponse({
        message: `Downloading ${filename}`,
        data: {
          percent: parseFloat(percent),
          downloaded: downloadedBytes,
          total: totalBytes,
        },
      });

      socket.emit(event, response);
    }
  });

  videoStream.on("end", () => {
    const response = new SocketResponse({
      message: `Downloaded ${filename} successfully`,
      data: {
        downloaded: totalBytes,
        total: totalBytes,
        percent: 100,
      },
    });

    socket.emit(event, response);
  });

  videoStream.on("error", (err) => {
    logger.error(`Download ${filename} error: ${err}`);
    const response = new SocketResponse({
      message: err.message,
      code: 500,
    });

    socket.emit(event, response);
  });
};

module.exports = {
  downloadYT,
};
