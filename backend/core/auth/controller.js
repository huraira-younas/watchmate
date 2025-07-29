const { methods } = require("../../bullmq/queues/emails/producer");
const {
  AppError,
  getBaseURL,
  validateReq,
  getIpAddress,
} = require("../../methods/utils");
const User = require("../../database/models/user_model");
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

module.exports = { login, signUp };
