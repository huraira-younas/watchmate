const { asyncHandler } = require("../../methods/utils");
const stream = require("./controller");
const express = require("express");
const router = express.Router();

router.get("/video/*", asyncHandler(stream.streamVideo));
module.exports = router;
