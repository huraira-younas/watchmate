const fs = require("fs-extra");
const path = require("path");

const BASE = path.join(process.cwd(), "app_data");

const streamVideo = async (req, res) => {
  const url = req.params[0];
  const filePath = path.join(BASE, url);

  if (!fs.existsSync(filePath)) {
    return res.status(404).send("❌ File not found");
  }

  if (fs.lstatSync(filePath).isDirectory()) {
    return res.status(400).send("❌ Cannot stream a directory");
  }

  const ext = path.extname(filePath).toLowerCase();
  const stat = fs.statSync(filePath);
  const fileSize = stat.size;
  const range = req.headers.range;

  const contentType =
    ext === ".m3u8"
      ? "application/vnd.apple.mpegurl"
      : ext === ".ts"
      ? "video/MP2T"
      : "application/octet-stream";

  if (ext === ".m3u8") {
    res.writeHead(200, {
      "Access-Control-Allow-Headers": "Origin, Range",
      "Access-Control-Allow-Origin": "*",
      "Cache-Control": "no-cache",
      "Content-Type": contentType,
      "Content-Length": fileSize,
    });
    return fs.createReadStream(filePath).pipe(res);
  }

  if (ext === ".ts" && range) {
    const parts = range.replace(/bytes=/, "").split("-");
    const start = parseInt(parts[0], 10);
    
    const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
    const chunkSize = end - start + 1;

    res.writeHead(206, {
      "Content-Range": `bytes ${start}-${end}/${fileSize}`,
      "Access-Control-Allow-Headers": "Origin, Range",
      "Access-Control-Allow-Origin": "*",
      "Content-Length": chunkSize,
      "Content-Type": contentType,
      "Accept-Ranges": "bytes",
    });

    return fs.createReadStream(filePath, { start, end }).pipe(res);
  }

  res.writeHead(200, {
    "Access-Control-Allow-Origin": "*",
    "Cache-Control": "no-cache",
    "Content-Type": contentType,
    "Content-Length": fileSize,
  });

  return fs.createReadStream(filePath).pipe(res);
};

module.exports = { streamVideo };
