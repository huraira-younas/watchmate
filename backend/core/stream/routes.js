const { asyncHandler } = require("../../methods/utils");
const stream = require("./controller");
const express = require("express");
const router = express.Router();

router
  .get("/video/:folder/:resolution/:filename", asyncHandler(stream.streamVideo))
  .post("/download_yt", stream.downloadYT);
module.exports = router;
