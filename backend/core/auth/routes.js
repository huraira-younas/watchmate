const { asyncHandler } = require("../../methods/utils");
const auth = require("./controller");
const express = require("express");
const router = express.Router();

//? -- User Routes
router
//   .post("/reset_password", asyncHandler(auth.resetPassword))
//   .post("/delete_account", asyncHandler(auth.deleteAccount))
//   .post("/verify_code", asyncHandler(auth.verifyCode))
//   .get("/delete/:uid", asyncHandler(auth.deleteUser))
//   .post("/send_code", asyncHandler(auth.sendCode))
//   .post("/update", asyncHandler(auth.updateUser))
//   .post("/fetch", asyncHandler(auth.fetchUsers))
  .post("/sign_up", asyncHandler(auth.signUp))
  .post("/login", asyncHandler(auth.login))
//   .post("/get", asyncHandler(auth.getUser));

module.exports = router;
