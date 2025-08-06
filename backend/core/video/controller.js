const Video = require("../../database/models/video_model");

const getAllVideos = async (req, res) => {
  const videos = await Video.find({});
  res.json(videos);
};

module.exports = {
  getAllVideos,
};
