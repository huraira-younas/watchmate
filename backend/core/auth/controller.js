const {
  AppError,
  getBaseURL,
  validateReq,
  getIpAddress,
} = require("../../methods/utils");
const { getMemberFromHash } = require("../../redis/redis_methods");
const { methods } = require("../../bullmq/queues/emails/producer");
const User = require("../../database/models/user_model");
const logger = require("../../methods/logger");
const bcrypt = require("bcryptjs");

const login = async (req, res) => {
  validateReq(req.body, ["email", "password"]);
  const { email, password } = req.body;

  const user = await User.findOne({ email });
  if (!user) throw new AppError("User not found", 400);

  const valid = await bcrypt.compare(password, user.password);
  if (!valid) throw new AppError("Invalid Password", 400);

  delete user.password;
  res.json(user);
};

const signUp = async (req, res) => {
  validateReq(req.body, ["email", "password"]);
  const { email, password, name, profileURL, isSocial = false } = req.body;

  const existingUser = await User.findOne({ email });
  if (!isSocial && existingUser) {
    throw new AppError(`${email} is already in use`, 400);
  }

  let user = existingUser;
  if (!isSocial || !user) {
    const hashedPassword = await bcrypt.hash(password, 10);
    const ipAddress = getIpAddress(req);

    user = await User.insert({
      data: {
        username: email.split("@")[0],
        password: hashedPassword,
        profileURL,
        ipAddress,
        email,
        name,
      },
    });
  }

  if (!user) throw new AppError("Failed to register user", 400);

  delete user.password;
  res.json(user);
};

const getUser = async (req, res) => {
  validateReq(req.body, ["uid"]);
  const { uid } = req.body;

  const user = await User.findById(uid);
  if (!user) throw new AppError("User not found", 400);

  delete user.password;
  res.json(user);
};

const resetPassword = async (req, res) => {
  const { oldPassword, newPassword, email, method } = req.body;
  if (!newPassword || !email) {
    throw new AppError("newPassword and email is required", 400);
  }

  if (method === "reset" && !oldPassword) {
    throw new AppError("oldPassword is required", 400);
  }

  const user = await User.findOne({ email });
  if (!user) throw new AppError("User not found", 400);

  if (method === "reset") {
    const isValid = await bcrypt.compare(oldPassword, user.password);
    if (!isValid) throw new AppError("Invalid Old Password", 400);
  }

  const hashedPassword = await bcrypt.hash(newPassword, 10);
  await User.findOneAndUpdate({
    data: { password: hashedPassword },
    query: { email },
    returnNew: false,
  });

  methods.sendResetMail({
    baseURL: getBaseURL(req),
    name: user.name,
    email,
  });

  res.json({ message: "Password reset successfully" });
};

const verifyCode = async (req, res) => {
  const { code, email } = req.body;
  const key = `code:${email}`;

  const data = await getMemberFromHash(key);
  if (!data?.code) {
    throw new AppError("Code expired please request new code", 400);
  }

  if (data.code.toString() !== code) {
    throw new AppError("Invalid Code", 400);
  }

  res.json({ message: "Code verified successfully" });
};

const updateUser = async (req, res) => {
  validateReq(req.body, ["id"], ["deviceId", "role", "ban"]);
  const { id, ...updates } = req.body;

  const userExists = await User.findById(id);
  if (!userExists) throw new AppError("User not found", 400);
  const ipAddress = getIpAddress(req);

  const user = await User.findByIdAndUpdate({
    data: { ...updates, ipAddress },
    userId: id,
  });

  delete user.password;
  res.json(user);
};

const sendCode = async (req, res) => {
  const { email, method = "reset" } = req.body;
  if (!email) throw new AppError("Email is required", 400);

  let user;
  if (method === "reset") {
    user = await User.findOne({ email });
    if (!user) throw new AppError("User does not exists", 400);
  }

  const code = Math.floor(100000 + Math.random() * 900000);
  const baseURL = getBaseURL(req);

  logger.info(`Code: ${code}`);

  await methods.sendCode({ email, code, name: user?.name || "User", baseURL });
  res.json({ message: "Code sent successfully" });
};

const fetch = async (_, res) => res.json(await User.find({}));

module.exports = {
  resetPassword,
  updateUser,
  verifyCode,
  sendCode,
  getUser,
  signUp,
  fetch,
  login,
};
