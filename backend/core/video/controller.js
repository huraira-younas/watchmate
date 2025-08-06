const Video = require("../../database/models/video_model");

const getAllVideos = async (req, res) => {
  const { visibility = "public", cursor = null, limit = 10, search } = req.body;

  const videos = await Video.pagination({
    conditions: { visibility },
    cursor,
    search,
    limit,
  });

  res.json(videos);
};

module.exports = { getAllVideos };
