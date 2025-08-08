const logger = require("../methods/logger");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const UPLOADS_DIR = path.join(process.cwd(), "app_data");

if (!fs.existsSync(UPLOADS_DIR)) {
  fs.mkdirSync(UPLOADS_DIR, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, _, cb) => {
    try {
      const userid = req.headers.userid;
      console.log(userid);
      if (!userid) {
        logger.error("userid is required");
        return cb(new Error("userid is required"));
      }

      const userFolder = path.join(UPLOADS_DIR, userid, "uploads");
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
  "application/octet-stream",
  "video/x-matroska",
  "video/quicktime",
  "video/x-msvideo",
  "image/jpeg",
  "image/webp",
  "video/mp4",
  "image/png",
];

const allowedExts = [".jpeg", ".webp", ".png", ".jpg", ".mp4", ".mov", ".avi"];

const uploadLocally = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 * 1024 },
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
