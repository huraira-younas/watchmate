const { S3Client } = require("@aws-sdk/client-s3");
const logger = require("../methods/logger");
const multerS3 = require("multer-s3");
const multer = require("multer");
const path = require("path");

const R2_SECRET_KEY = process.env.R2_SECRET_ACCESS_KEY;
const R2_ACCESS_KEY = process.env.R2_ACCESS_KEY_ID;
const R2_ENDPOINT = process.env.R2_ENDPOINT;
const R2_BUCKET = process.env.R2_BUCKET;

const s3 = new S3Client({
  credentials: { secretAccessKey: R2_SECRET_KEY, accessKeyId: R2_ACCESS_KEY },
  endpoint: R2_ENDPOINT,
  region: "auto",
});

const allowedMimes = [
  "application/octet-stream",
  "video/x-matroska", 
  "video/quicktime",
  "video/x-msvideo",
  "video/3gpp2",
  "video/x-flv",
  "video/mpeg", 
  "video/webm",
  "video/3gpp", 
  "image/jpeg", 
  "image/webp", 
  "video/mp4",
  "video/ogg",
  "image/png",
];

const allowedExts = [
  ".jpeg",
  ".webm",
  ".webp",
  ".mpeg",
  ".jpg",
  ".mp4",
  ".png",
  ".ogg",
  ".mov",
  ".avi",
  ".mkv",
  ".mpg",
  ".3gp",
  ".3g2",
  ".flv",
];

const storage = multerS3({
  s3,
  bucket: R2_BUCKET,
  contentType: multerS3.AUTO_CONTENT_TYPE,
  key: (req, file, cb) => {
    try {
      const folder = req.headers.folder || "default";
      const userid = req.headers.userid;
      if (!userid) {
        logger.error("userid is required");
        return cb(new Error("userid is required"));
      }

      const fileName = `${userid}/${folder}/${file.originalname}`;
      cb(null, fileName);
    } catch (error) {
      logger.error(`Error in uploading: ${error.message}`);
      cb(error);
    }
  },
});

const uploadToR2 = multer({
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

module.exports = { uploadToR2, s3 };
