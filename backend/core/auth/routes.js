const { asyncHandler } = require("../../methods/utils");
const auth = require("./controller");
const express = require("express");
const router = express.Router();

//? -- User Routes
router
  .post("/reset_password", asyncHandler(auth.resetPassword))
  .post("/update_user", asyncHandler(auth.updateUser))
  .post("/verify_code", asyncHandler(auth.verifyCode))
  .post("/send_code", asyncHandler(auth.sendCode))
  .post("/sign_up", asyncHandler(auth.signUp))
  .post("/login", asyncHandler(auth.login))
  .get("/fetch", asyncHandler(auth.fetch))
  .post("/get", asyncHandler(auth.getUser));

module.exports = router;
