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
  )
  .post("/test", uploadToR2.single("file"), (req, res) => {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message:
          "No file received. The upload may have been blocked due to size limit.",
      });
    }

    res.json({
      success: true,
      filename: req.file.originalname,
      sizeBytes: req.file.size,
      sizeMB: (req.file.size / (1024 * 1024)).toFixed(2),
      message: "File uploaded successfully.",
    });
  });

module.exports = router;
