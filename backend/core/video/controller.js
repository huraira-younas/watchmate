const { validateReq, AppError } = require("../../methods/utils");
const Video = require("../../database/models/video_model");

const addVideo = async (req, res) => {
  await Video.insert({ data: req.body, returnNew: false });
  res.json({ message: "Video added" });
};

const deleteVideo = async (req, res) => {
  validateReq(req.params, ["id"]);
  const id = req.params.id;

  const del = await Video.findByIdAndDelete(id);
  if (!del) throw new AppError("Video not found", 400);
  res.json({ message: "Video deleted successfully" });
};

const getAllVideos = async (req, res) => {
  validateReq(req.body, ["visibility", "isHome"]);
  const { visibility, cursor = null, isHome, limit = 10, search } = req.body;

  const conditions = { visibility };
  if (!isHome) conditions.userId = req.body.userId;

  const videos = await Video.pagination({
    conditions,
    cursor,
    search,
    limit,
  });

  res.json(videos);
};

module.exports = { getAllVideos, addVideo, deleteVideo };
