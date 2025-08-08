const fs = require("fs-extra");
const path = require("path");
const mime = require("mime");

const BASE = path.join(process.cwd(), "app_data");

const _getContentType = (ext) => {
  const map = {
    ".m3u8": "application/vnd.apple.mpegurl",
    ".ts": "video/MP2T",
    ".mp4": "video/mp4",
  };

  return map[ext] || "application/octet-stream";
};

const _handleFullStream = ({ res, filePath, fileSize, contentType }) => {
  res.writeHead(200, {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": contentType,
    "Cache-Control": "no-cache",
    "Content-Length": fileSize,
  });

  fs.createReadStream(filePath).pipe(res);
};

const _handleRangeStream = ({
  contentType,
  filePath,
  fileSize,
  range,
  res,
}) => {
  const [startStr, endStr] = range.replace(/bytes=/, "").split("-");
  const start = parseInt(startStr, 10);

  const end = endStr ? parseInt(endStr, 10) : fileSize - 1;
  const chunkSize = end - start + 1;

  res.writeHead(206, {
    "Content-Range": `bytes ${start}-${end}/${fileSize}`,
    "Access-Control-Allow-Headers": "Origin, Range",
    "Access-Control-Allow-Origin": "*",
    "Content-Length": chunkSize,
    "Content-Type": contentType,
    "Accept-Ranges": "bytes",
  });

  fs.createReadStream(filePath, { start, end }).pipe(res);
};

const _validatePath = (filePath, res) => {
  if (!fs.existsSync(filePath)) {
    return res.status(404).send("❌ File not found");
  }

  if (fs.lstatSync(filePath).isDirectory()) {
    return res.status(400).send("❌ Cannot stream a directory");
  }
};

const streamVideo = async (req, res) => {
  const url = req.params[0];
  const filePath = path.join(BASE, url);
  _validatePath(filePath, res);

  const ext = path.extname(filePath).toLowerCase();
  const fileSize = fs.statSync(filePath).size;
  const contentType = _getContentType(ext);
  const range = req.headers.range;

  if (ext === ".m3u8" || !range) {
    return _handleFullStream({
      contentType,
      filePath,
      fileSize,
      res,
    });
  }

  return _handleRangeStream({
    contentType,
    filePath,
    fileSize,
    range,
    res,
  });
};

const getThumbnail = (req, res) => {
  const url = req.params[0];
  const filePath = path.join(BASE, url);
  _validatePath(filePath, res);

  res.setHeader("Cache-Control", "public, max-age=31536000");
  res.setHeader("Content-Type", mime.default.getType(filePath));
  res.sendFile(filePath);
};

module.exports = { streamVideo, getThumbnail };
