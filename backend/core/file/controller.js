const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");
const { PutObjectCommand } = require("@aws-sdk/client-s3");
const { s3 } = require("../../clients/s3_client");

const { AppError, validateReq } = require("../../methods/utils");
const fs = require("fs-extra");
const path = require("path");
const mime = require("mime");

const BASE = path.join(process.cwd(), "app_data");

const _validatePath = (filePath, res) => {
  if (!fs.existsSync(filePath)) {
    return res.status(404).send("❌ File not found");
  }

  if (fs.lstatSync(filePath).isDirectory()) {
    return res.status(400).send("❌ Cannot stream a directory");
  }
};

const handleUpload = async (req, res) => {
  if (!req.file) throw new AppError("File not uploaded", 400);
  const location = req.file.key;

  res.json(`${process.env.R2_PUBLIC_BASE_URL}/${location}`);
};

const getFile = (req, res) => {
  const url = req.params[0];
  const filePath = path.join(BASE, url);
  _validatePath(filePath);

  res.setHeader("Cache-Control", "public, max-age=31536000");
  res.setHeader("Content-Type", mime.default.getType(filePath));
  res.sendFile(filePath);
};

const getPresignedUrl = async (req, res) => {
  validateReq(req.body, ["folder", "filename"]);
  const { folder, filename, userId } = req.body;

  const baseName = path.basename(filename);
  const ext = path.extname(baseName).slice(1);
  const contentType = mime.default.getType(baseName);

  const key = `${userId}/${folder}/video.${ext}`;
  const command = new PutObjectCommand({
    ContentType: contentType || "application/octet-stream",
    Bucket: process.env.R2_BUCKET,
    Key: key,
  });

  const url = await getSignedUrl(s3, command, { expiresIn: 3600 });
  const videoURL = `${process.env.R2_PUBLIC_BASE_URL}/${key}`;
  res.json({ url, videoURL });
};

module.exports = { handleUpload, getFile, getPresignedUrl };
