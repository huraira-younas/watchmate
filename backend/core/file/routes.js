const { validateRole, ROLES } = require("../../middlewares/validate_role");
const uploadLocally = require("../../clients/multer_client");
const { asyncHandler } = require("../../methods/utils");
const file = require("./controller");
const express = require("express");
const router = express.Router();

router
  .get("/get_file/*", asyncHandler(file.getFile))
  .post(
    "/upload",
    validateRole("userid", [ROLES.ADMIN, ROLES.USER]),
    uploadLocally.single("file"),
    asyncHandler(file.handleUpload)
  );

module.exports = router;
