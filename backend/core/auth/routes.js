const { asyncHandler } = require("../../methods/utils");
const auth = require("./controller");
const express = require("express");
const router = express.Router();

//? -- User Routes
router
  .post("/reset_password", asyncHandler(auth.resetPassword))
  .post("/verify_code", asyncHandler(auth.verifyCode))
  .post("/send_code", asyncHandler(auth.sendCode))
  .post("/sign_up", asyncHandler(auth.signUp))
  .post("/login", asyncHandler(auth.login))
  .post("/get", asyncHandler(auth.getUser));

module.exports = router;
