const logger = require("../methods/logger");

function _getRandomStep(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function uploadProgress(req, _, next) {
  const contentLength = parseInt(req.headers["content-length"] || "0", 10);
  let nextLogAt = _getRandomStep(0, 4);
  let uploadedBytes = 0;

  req.on("data", (chunk) => {
    uploadedBytes += chunk.length;

    if (contentLength > 0) {
      const progress = Math.floor((uploadedBytes / contentLength) * 100);

      if (progress >= nextLogAt) {
        logger.info(`Upload progress: ${progress}%`);
        nextLogAt = progress + _getRandomStep(3, 8);
      }
    }
  });

  req.on("end", () => logger.info("Upload complete"));
  next();
}

module.exports = uploadProgress;
