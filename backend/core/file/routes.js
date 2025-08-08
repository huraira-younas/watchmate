const { validateRole, ROLES } = require("../../middlewares/validate_role");
const uploadLocally = require("../../clients/multer_client");
const { asyncHandler } = require("../../methods/utils");
const upload = require("./controller");
const express = require("express");
const router = express.Router();

router.post(
  "/upload",
  validateRole("userid", [ROLES.ADMIN, ROLES.USER]),
  uploadLocally.single("file"),
  asyncHandler(upload.handleUpload)
);
module.exports = router;
