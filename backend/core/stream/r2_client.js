const {
  SocketResponse,
  SocketError,
} = require("../../methods/socket/socket_methods");
const { getMemberFromHash } = require("../../redis/redis_methods");
const Video = require("../../database/models/video_model");
const { getIO } = require("../../clients/socket_client");
const { socketKey } = require("../../redis/admin_keys");
const { Upload } = require("@aws-sdk/lib-storage");
const { s3 } = require("../../clients/s3_client");
const logger = require("../../methods/logger");
const sanitize = require("sanitize-filename");
const ytdl = require("@distube/ytdl-core");
const { PassThrough } = require("stream");
const { v4: uuid } = require("uuid");
const axios = require("axios");

class R2Client {
  constructor({ user, socket, url, event }) {
    this.lastPercent = -1;
    this.socket = socket;
    this.videoData = {};
    this.event = event;
    this.user = user;
    this.url = url;
  }

  async start(type, visibility, title, thumbnail) {
    if (type === "youtube") await this._initYT(visibility);
    else await this._initDirect(visibility, title, thumbnail);

    await this._saveVideoData();
  }

  async _initYT(visibility) {
    if (!ytdl.validateURL(this.url)) {
      throw new SocketError("Invalid YouTube URL", 400);
    }

    const info = await ytdl.getInfo(this.url);
    const { videoDetails } = info;

    const title = sanitize(videoDetails.title);
    const filename = `${title}.mp4`;

    const key = `${this.user.id}/youtube/${filename}`;

    const format = ytdl.chooseFormat(info.formats, {
      filter: (f) => f.container === "mp4" && f.hasVideo && f.hasAudio,
      quality: "highest",
    });

    const size = parseInt(format.contentLength || 0, 10);

    this.videoData = {
      videoURL: `${process.env.R2_PUBLIC_BASE_URL}/${key}`,
      duration: parseInt(videoDetails.lengthSeconds, 10),
      thumbnailURL: videoDetails.thumbnails.at(-1)?.url,
      height: parseInt(format.height || 0, 10),
      width: parseInt(format.width || 0, 10),
      title: videoDetails.title,
      userId: this.user.id,
      type: "youtube",
      visibility,
      id: uuid(),
      size,
    };

    this.videoStream = ytdl(this.url, { format });
    await this._uploadToR2(this.videoStream, key, "video/mp4", size);
  }

  async _initDirect(visibility, title, thumbnail) {
    const response = await axios.get(this.url, { responseType: "stream" });
    const contentType = response.headers["content-type"] || "video/mp4";

    const size = parseInt(response.headers["content-length"] || 0, 10);
    if (size <= 0) {
      throw new SocketError("Invalid Format. Use direct url of a video", 400);
    }

    const extension = contentType.split("/")[1] || "mp4";
    const filename = `video.${extension}`;

    const id = uuid();
    const key = `${this.user.id}/direct/${id}/${filename}`;

    this.videoData = {
      videoURL: `${process.env.R2_PUBLIC_BASE_URL}/${key}`,
      title: sanitize(title),
      userId: this.user.id,
      thumbnailURL: "",
      type: "direct",
      duration: 0,
      visibility,
      height: 0,
      width: 0,
      size,
      id,
    };

    await Promise.all([
      this._uploadToR2(response.data, key, contentType, size),
      this._uploadThumbnail(thumbnail, id),
    ]);
  }

  async _uploadToR2(stream, key, contentType, totalBytes) {
    let nextJump = Math.floor(Math.random() * 5) + 1;
    let uploadedBytes = 0;

    const progressStream = new PassThrough();
    stream.on("data", (chunk) => {
      uploadedBytes += chunk.length;
      const percent = Math.floor((uploadedBytes / totalBytes) * 100);
      if (percent >= this.lastPercent + nextJump) {
        nextJump = Math.floor(Math.random() * 5) + 1;
        this._sendProgress(percent);
        this.lastPercent = percent;
      }
    });

    stream.pipe(progressStream);
    const upload = new Upload({
      client: s3,
      params: {
        Bucket: process.env.R2_BUCKET,
        ContentType: contentType,
        Body: progressStream,
        Key: key,
      },
    });

    await upload.done();
    console.log(`[R2] Uploaded: ${key}`);
  }

  async _uploadThumbnail(url, id) {
    if (!url) return;

    const response = await axios.get(url, { responseType: "arraybuffer" });
    const contentType = response.headers["content-type"];

    const ext = contentType.split("/")[1] || "jpg";
    const key = `${this.user.id}/direct/${id}/thumbnail.${ext}`;

    const upload = new Upload({
      client: s3,
      params: {
        Body: Buffer.from(response.data),
        Bucket: process.env.R2_BUCKET,
        ContentType: contentType,
        Key: key,
      },
    });

    await upload.done();
    this.videoData.thumbnailURL = `${process.env.R2_PUBLIC_BASE_URL}/${key}`;
  }

  async _saveVideoData() {
    await Video.insert({ data: this.videoData, returnNew: false });
    logger.info(`[DB] Video saved for user ${this.user.id}`);
    await this._sendProgress(100, 200);
  }

  async _sendProgress(percent, code = 201) {
    if (!this.socket || !this.socket.connected) {
      const key = socketKey(this.user.id, "stream");
      const io = getIO();

      const sockets = await io.of("/stream").fetchSockets();
      const socketId = await getMemberFromHash(key);

      console.log(
        "Sockets in /stream:",
        sockets.map((s) => s.id)
      );
      this.socket = sockets.find((s) => s.id === socketId);
      console.log("Current SocketId: ", socketId);

      if (!this.socket) {
        logger.warn(`Socket not found: ${percent}`);
        return;
      }
    }

    this.socket.emit(
      this.event,
      new SocketResponse({
        message: `Downloading ${this.videoData.title}`,
        code: code,
        data: {
          ...this.videoData,
          user: this.user,
          percent,
        },
      })
    );
  }
}

module.exports = R2Client;
