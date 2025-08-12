const {
  DeleteObjectCommand,
  DeleteObjectsCommand,
  ListObjectsV2Command,
} = require("@aws-sdk/client-s3");
const { validateReq, AppError } = require("../../methods/utils");
const Video = require("../../database/models/video_model");
const { s3 } = require("../../clients/s3_client");

const _deleteR2Video = async ({ userId, id }) => {
  const dirPrefix = `${userId}/videos/${id}/`;

  const listResp = await s3.send(
    new ListObjectsV2Command({
      Bucket: process.env.R2_BUCKET,
      Prefix: dirPrefix,
    })
  );

  if (listResp.Contents && listResp.Contents.length > 0) {
    await s3.send(
      new DeleteObjectsCommand({
        Delete: { Objects: listResp.Contents.map((obj) => ({ Key: obj.Key })) },
        Bucket: process.env.R2_BUCKET,
      })
    );
  }
};

const deleteVideo = async (req, res) => {
  validateReq(req.body, ["id"]);
  const { id, userId } = req.body;

  const video = await Video.findById(id);
  if (!video) throw new AppError("Video not found", 400);

  if (video.type === "youtube") {
    const key = video.videoURL.split(process.env.R2_PUBLIC_BASE_URL)[1];
    if (!key) throw new AppError("Failed to delete, key is invalid", 400);

    await s3.send(
      new DeleteObjectCommand({
        Bucket: process.env.R2_BUCKET,
        Key: key,
      })
    );
  } else await _deleteR2Video({ userId, id });

  await Video.findByIdAndDelete(id);
  res.json({ message: "Video deleted successfully" });
};

const addVideo = async (req, res) => {
  await Video.insert({ data: req.body, returnNew: false });
  res.json({ message: "Video added" });
};

const getVideo = async (req, res) => {
  validateReq(req.body, ["id"]);
  const id = req.body.id;

  const video = await Video.findById(id);
  if (!video) throw new AppError("Video not found", 400);
  res.json(video);
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

module.exports = { getAllVideos, addVideo, getVideo, deleteVideo };
