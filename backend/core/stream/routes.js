const { asyncHandler } = require("../../methods/utils");
const { streamVideo } = require("./controller");
const express = require("express");
const router = express.Router();

router.get("/video/:resolution/:filename", asyncHandler(streamVideo));
module.exports = router;
