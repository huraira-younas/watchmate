const {
  SocketError,
  SocketResponse,
} = require("../../../methods/socket/socket_methods");
const Video = require("../../../database/models/video_model");
const logger = require("../../../methods/logger");
const sanitize = require("sanitize-filename");
const DownloadManager = require("./manager");
const ytdl = require("@distube/ytdl-core");
const { v4: uuidv4 } = require("uuid");
const fs = require("fs-extra");
const axios = require("axios");
const path = require("path");

const BASE = path.join(process.cwd(), "app_data");
const INACTIVITY_TIMEOUT_MS = 30000;

class Download {
  constructor({
    filter = (f) => f.container === "mp4" && f.hasVideo && f.hasAudio,
    quality = "highestvideo",
    type = "direct",
    socket,
    event,
    user,
    url,
  }) {
    this.writeStream = null;
    this.videoStream = null;
    this.isStopped = false;
    this.quality = quality;
    this.isPaused = false;
    this.filter = filter;
    this.filePath = null;
    this.lastPercent = 0;
    this.socket = socket;
    this.videoData = {};
    this.totalBytes = 0;
    this.downloaded = 0;
    this.timeout = null;
    this.event = event;
    this.id = uuidv4();
    this.user = user;
    this.type = type;
    this.url = url;
  }

  async init(visibility, title, thumbnail) {
    if (this.type === "youtube") await this._initYT(visibility);
    else await this._initDirect(visibility, title, thumbnail);
  }

  async _initYT(visibility) {
    if (!ytdl.validateURL(this.url)) {
      throw new SocketError("Invalid YouTube URL", 400);
    }
    const info = await ytdl.getInfo(this.url);
    const { videoDetails } = info;
    const title = sanitize(videoDetails.title);
    const filename = `${title}-${Date.now()}.mp4`;

    const url = path.join(`${this.user.id}/downloads`, "youtube", filename);
    this.filePath = path.resolve(BASE, url);

    fs.mkdirSync(path.dirname(this.filePath), { recursive: true });

    const format = ytdl.chooseFormat(info.formats, {
      quality: this.quality,
      filter: this.filter,
    });

    if (!format) {
      throw new SocketError("No suitable MP4 format found.", 400);
    }

    const size = parseInt(String(format.contentLength || 0), 10);
    const height = parseInt(String(format.height || 0), 10);
    const width = parseInt(String(format.width || 0), 10);
    this.videoData = {
      duration: parseInt(videoDetails.lengthSeconds, 10),
      thumbnailURL: videoDetails.thumbnails.at(-1)?.url,
      title: videoDetails.title,
      userId: this.user.id,
      type: "youtube",
      videoURL: url,
      id: this.id,
      visibility,
      height,
      width,
      size,
    };

    console.log(this.videoData);

    this.writeStream = fs.createWriteStream(this.filePath);
    this.videoStream = ytdl(this.url, { format });
    this.totalBytes = size;
    this._setupListeners();
  }

  async _initDirect(visibility, title, thumbnail) {
    const headers = {
      "User-Agent":
        "Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Mobile/15E148 Safari/604.1",
    };

    const filename = `${sanitize(title)}-${Date.now()}.mp4`;
    const USER_DIR = path.join(this.user.id, "downloads");
    const url = path.join(USER_DIR, "direct", filename);

    const thumbnailURL = await this._downloadThumbnail({
      dir_path: USER_DIR,
      thumbnail,
      title,
    });

    const response = await axios({
      responseType: "stream",
      url: this.url,
      method: "get",
      headers,
    });

    const size = parseInt(response.headers["content-length"] || "0", 10);
    if (size === 0) {
      return this._onError(new SocketError("Invalid Video Format", 400));
    }

    this.filePath = path.resolve(BASE, url);
    this.videoStream = response.data;
    this.totalBytes = size;

    this.videoData = {
      userId: this.user.id,
      type: "direct",
      videoURL: url,
      thumbnailURL,
      duration: 0,
      id: this.id,
      visibility,
      title,
      size,
    };

    fs.mkdirSync(path.dirname(this.filePath), { recursive: true });
    this.writeStream = fs.createWriteStream(this.filePath);
    this._setupListeners();
  }

  async _downloadThumbnail({ thumbnail, title, dir_path }) {
    const ext = path.extname(new URL(thumbnail).pathname) || ".jpg";
    const safeTitle = sanitize(title);

    const fileName = `${safeTitle}${ext}`;
    const url = path.join(dir_path, "thumbnails", fileName);
    const filePath = path.resolve(BASE, url);

    const response = await axios({
      responseType: "stream",
      url: thumbnail,
      method: "get",
    });

    fs.mkdirSync(path.dirname(filePath), { recursive: true });
    await new Promise((resolve, reject) => {
      const stream = fs.createWriteStream(filePath);
      response.data.pipe(stream);
      stream.on("finish", resolve);
      stream.on("error", reject);
    });

    return url;
  }

  async getDimensions(filepath) {
    // Todo: Do this in future by purchasing VPS, YOU SHIT
    return {
      duration: 0,
      height: 0,
      width: 0,
    };
  }

  _setupListeners() {
    this.videoStream.on("data", (chunk) => this._onData(chunk));
    this.videoStream.on("error", (err) => this._onError(err));
    this.writeStream.on("error", (err) => this._onError(err));
    this.writeStream.on("finish", () => this._onFinish());
    this.videoStream.on("end", () => this._onEnd());
    this.videoStream.pipe(this.writeStream);
    this._resetTimeout();
  }

  _resetTimeout() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      const err = new SocketError("Download timed out due to inactivity.", 400);
      this.videoStream.destroy(err);
    }, INACTIVITY_TIMEOUT_MS);
  }

  _onData(chunk) {
    this.downloaded += chunk.length;
    this._resetTimeout();

    if (this.totalBytes > 0) {
      const percent = (this.downloaded / this.totalBytes) * 100;
      const rounded = Math.floor(percent / 5) * 5;

      if (rounded > this.lastPercent && rounded <= 100) {
        this.lastPercent = rounded;
        this._sendProgress(rounded);
      }
    }
  }

  _sendProgress(percent) {
    this.socket.emit(
      this.event,
      new SocketResponse({
        message: `Downloading ${this.videoData.title}`,
        code: 201,
        data: {
          ...{ ...this.videoData, user: this.user },
          downloaded: this.downloaded,
          total: this.totalBytes,
          percent,
        },
      })
    );
  }

  _onError(err) {
    if (this.isStopped) return;
    clearTimeout(this.timeout);
    this.socket.emit(
      this.event,
      new SocketResponse({
        message: `Download error: ${err.message}`,
        code: 500,
      })
    );
    this.destroy();
  }

  _onEnd() {
    logger.debug(`Download stream ended for ${this.videoData.title}`);
  }

  async _onFinish() {
    logger.info(`File write finished for ${this.videoData.title}`);
    DownloadManager.remove(this.id);
    clearTimeout(this.timeout);

    if (!this.videoData.height && !this.videoData.width) {
      const dim = await this.getDimensions(this.filePath);
      this.videoData = { ...this.videoData, ...dim };
    }

    await Video.insert({ data: this.videoData, returnNew: false });
    if (!this.isStopped) {
      this.socket.emit(
        this.event,
        new SocketResponse({
          message: `Downloaded ${this.videoData.title} successfully`,
          data: { ...this.videoData, user: this.user },
          code: 200,
        })
      );
    }
  }

  pause() {
    if (!this.isPaused) {
      logger.info(`Download paused: ${this.id}`);
      clearTimeout(this.timeout);
      this.videoStream.pause();
      this.isPaused = true;
    }
  }

  resume() {
    if (this.isPaused) {
      logger.info(`Download resumed: ${this.id}`);
      this.videoStream.resume();
      this.isPaused = false;
      this._resetTimeout();
    }
  }

  stop() {
    logger.info(`Download stopped: ${this.id}`);
    DownloadManager.remove(this.id);
    clearTimeout(this.timeout);
    this.videoStream.destroy();
    this.writeStream.end();
    this.isStopped = true;

    if (this.filePath) {
      fs.unlink(this.filePath).catch((_) => {});
    }
  }

  destroy() {
    if (this.videoStream) this.videoStream.destroy();
    if (this.writeStream) this.writeStream.end();
    DownloadManager.remove(this.id);
    this.isStopped = true;

    clearTimeout(this.timeout);
    if (this.filePath) {
      fs.unlink(this.filePath).catch((_) => {});
    }
  }
}

module.exports = Download;
