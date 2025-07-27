const logger = require("../methods/logger");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const UPLOADS_DIR = path.join(__dirname, "../uploads");
if (!fs.existsSync(UPLOADS_DIR)) {
  fs.mkdirSync(UPLOADS_DIR, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, _, cb) => {
    try {
      const userId = req.headers.userid;
      if (!userId) {
        logger.error("userId is required");
        return cb(new Error("userId is required"));
      }

      const userFolder = path.join(UPLOADS_DIR, userId);
      if (!fs.existsSync(userFolder)) {
        fs.mkdirSync(userFolder, { recursive: true });
      }

      cb(null, userFolder);
    } catch (error) {
      logger.error(`Error in uploading: ${error.message}`);
      cb(error);
    }
  },
  filename: (_, file, cb) => {
    cb(null, file.originalname);
  },
});

const allowedMimes = [
  "application/x-zip-compressed",
  "application/octet-stream",
  "application/vnd.rar",
  "video/x-matroska",
  "video/quicktime",
  "video/x-msvideo",
  "application/zip",
  "application/pdf",
  "image/jpeg",
  "text/plain",
  "image/webp",
  "video/mp4",
  "image/png",
];

const allowedExts = [
  ".jpeg",
  ".webp",
  ".zip",
  ".rar",
  ".pdf",
  ".png",
  ".jpg",
  ".mp4",
  ".mov",
  ".avi",
  ".p8",
];

const uploadLocally = multer({
  storage,
  limits: { fileSize: 100 * 1024 * 1024 },
  fileFilter: (_, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const isMimeAllowed = allowedMimes.includes(file.mimetype);
    const isExtAllowed = allowedExts.includes(ext);

    if (!isMimeAllowed && !isExtAllowed) {
      const e = `Invalid file type: ${file.originalname} (${file.mimetype})`;
      return cb(new Error(e));
    }

    cb(null, true);
  },
});

module.exports = uploadLocally;
