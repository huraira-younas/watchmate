const Video = require("../../database/models/video_model");

const getAllVideos = async (req, res) => {
  console.log(req.user);

  const videos = await Video.find({});
  res.json(videos);
};

module.exports = {
  getAllVideos,
};
