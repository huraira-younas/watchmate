const logger = require("../../../methods/logger");

class DownloadManager {
  constructor() {
    if (DownloadManager.instance) {
      return DownloadManager.instance;
    }

    this.downloads = new Map();
    DownloadManager.instance = this;
  }

  static add(download) {
    this.getInstance().downloads.set(download.id, download);
    logger.info(`Download added: ${download.id}`);
  }

  static get(id) {
    return this.getInstance().downloads.get(id);
  }

  static remove(id) {
    this.getInstance().downloads.delete(id);
    logger.info(`Download removed: ${id}`);
  }

  static getInstance() {
    if (!this.instance) {
      this.instance = new DownloadManager();
    }
    return this.instance;
  }
}

module.exports = DownloadManager;
