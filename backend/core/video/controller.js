const Video = require("../../database/models/video_model");
const { validateReq } = require("../../methods/utils");

const getAllVideos = async (req, res) => {
  validateReq(req.body, ["visibility"]);
  const { visibility, cursor = null, limit = 10, search } = req.body;

  const conditions = { visibility };
  if (visibility === "private") {
    conditions.userId = req.body.userId;
  }

  const videos = await Video.pagination({
    conditions,
    cursor,
    search,
    limit,
  });

  res.json(videos);
};

module.exports = { getAllVideos };
