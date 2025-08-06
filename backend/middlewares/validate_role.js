const { AppError, asyncHandler } = require("../methods/utils");
const User = require("../database/models/user_model");

const ROLES = {
  ADMIN: "admin",
  USER: "user",
};

const validateRole = (key, roles = [ROLES.ADMIN]) =>
  asyncHandler(async (req, _, next) => {
    const userId = req.body[key] || req[key] || req.params[key];
    if (!userId) throw new AppError(`${key} is required`, 400);

    const user = await User.findById(userId);
    if (!user) throw new AppError("User not found", 400);

    if (user.role !== "owner" && !roles.includes(user.role)) {
      throw new AppError("Unauthorized: not allowed", 403);
    }

    delete user.password;
    req.user = user;
    next();
  });

module.exports = { validateRole, ROLES };
