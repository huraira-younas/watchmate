const { AppError } = require("../../methods/utils");

const handleUpload = async (req, res) => {
  if (!req.file) throw new AppError("File not uploaded", 400);
  const filePath = req.file.path;
  const userId = req.user.id;

  const [, afterUserId] = filePath.split(userId);
  const cleanedPath = afterUserId.replace(/^\\+|\/+/, "");

  console.log(cleanedPath);
  res.json(cleanedPath);
};

module.exports = { handleUpload };
