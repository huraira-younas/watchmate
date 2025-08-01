import path from "path";
import fs from "fs";

const BASE = path.join(process.cwd(), "uploads");

export const streamVideo = async (req, res) => {
  const { resolution, filename } = req.params;
  const filePath = path.join(BASE, resolution, filename, "index.m3u8");

  if (!fs.existsSync(filePath)) {
    return res.status(404).send("❌ File not found");
  }

  if (fs.lstatSync(filePath).isDirectory()) {
    return res.status(400).send("❌ Cannot stream a directory");
  }

  const ext = path.extname(filename).toLowerCase();
  const stat = fs.statSync(filePath);
  const range = req.headers.range;
  const fileSize = stat.size;

  const contentType =
    ext === ".m3u8"
      ? "application/vnd.apple.mpegurl"
      : ext === ".ts"
      ? "video/MP2T"
      : "application/octet-stream";

  if (ext === ".m3u8") {
    res.writeHead(200, {
      "Content-Type": contentType,
      "Content-Length": fileSize,
    });
    return fs.createReadStream(filePath).pipe(res);
  }

  if (ext === ".ts" && range) {
    const parts = range.replace(/bytes=/, "").split("-");

    const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
    const start = parseInt(parts[0], 10);
    const chunkSize = end - start + 1;

    const file = fs.createReadStream(filePath, { start, end });

    res.writeHead(206, {
      "Content-Range": `bytes ${start}-${end}/${fileSize}`,
      "Content-Length": chunkSize,
      "Content-Type": contentType,
      "Accept-Ranges": "bytes",
    });

    return file.pipe(res);
  }

  res.writeHead(200, {
    "Content-Type": contentType,
    "Content-Length": fileSize,
  });

  return fs.createReadStream(filePath).pipe(res);
};
