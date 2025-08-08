const { AppError } = require("../../methods/utils");
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
  const filePath = req.file.path;
  const userId = req.user.id;

  const [, afterUserId] = filePath.split(userId);
  const cleanedPath = afterUserId.replace(/^\\+|\/+/, "");

  console.log(cleanedPath);
  res.json(cleanedPath);
};

const getFile = (req, res) => {
  const url = req.params[0];
  const filePath = path.join(BASE, url);
  _validatePath(filePath);

  res.setHeader("Cache-Control", "public, max-age=31536000");
  res.setHeader("Content-Type", mime.default.getType(filePath));
  res.sendFile(filePath);
};

module.exports = { handleUpload, getFile };
