const {
  ROLES,
  validateRole,
  uploadProgress,
} = require("../../middlewares/index");
const { uploadToR2 } = require("../../clients/s3_client");
const { asyncHandler } = require("../../methods/utils");
const file = require("./controller");
const express = require("express");
const router = express.Router();

router
  .get("/get_file/*", asyncHandler(file.getFile))
  .post(
    "/upload",
    validateRole("userid", [ROLES.ADMIN, ROLES.USER]),
    uploadProgress,
    uploadToR2.single("file"),
    asyncHandler(file.handleUpload)
  );

module.exports = router;
