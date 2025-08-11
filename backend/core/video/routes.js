const { validateRole, ROLES } = require("../../middlewares/validate_role");
const { asyncHandler } = require("../../methods/utils");
const vid = require("./controller");
const express = require("express");
const router = express.Router();

router
  .post(
    "/get_all",
    validateRole("userId", [ROLES.ADMIN, ROLES.USER]),
    asyncHandler(vid.getAllVideos)
  )
  .post(
    "/add_video",
    validateRole("userId", [ROLES.ADMIN, ROLES.USER]),
    asyncHandler(vid.addVideo)
  );

module.exports = router;
