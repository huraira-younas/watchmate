const {
  getHashList,
  deleteFromHash,
  getMemberFromHash,
} = require("../../redis/redis_methods");
const { methods } = require("../../bullmq/queues/emails/producer");
const { AppError, getBaseURL } = require("../../methods/utils");
const User = require("../../database/models/user_model");
const { v4: uuidv4 } = require("uuid");

const _verifyToken = async (token) => {
  if (!token) {
    throw new AppError("Token is required", 400);
  }

  const key = `invitation:${token}`;
  const data = await getMemberFromHash(key);
  if (!data) {
    throw new AppError("Invite is expired, Please request for new invite", 400);
  }

  return data;
};

const _deleteInvitesFromRedis = async (email) => {
  const invited = await getHashList("invitation");
  const prevInvites = [];

  invited?.forEach((e) => {
    if (e.email === email) {
      const delKey = `invitation:${e.token}`;
      prevInvites.push(deleteFromHash(delKey));
    }
  });

  if (prevInvites.length !== 0) {
    await Promise.all(prevInvites);
  }
};

const _updateRole = async (email, role) => {
  if (role === "owner") {
    throw new AppError("You can't add another owner");
  }

  await User.findOneAndUpdate({
    returnNew: false,
    query: { email },
    data: { role },
  });

  await _deleteInvitesFromRedis(email);
};

const _checkValidity = async (id, roles = ["admin"]) => {
  const admin = await User.findById(id);
  if (!admin) {
    throw new AppError("Admin not exists", 400);
  }

  if (!roles.includes(admin.role)) {
    throw new AppError("Only admin can do this operation", 400);
  }

  return admin;
};

const adminInvite = async (req, res) => {
  const { role = "admin", userEmail, adminId } = req.body;

  const admin = await _checkValidity(adminId, ["owner"]);
  const user = await User.findOne({ email: userEmail });
  if (!user) {
    throw new AppError(`User with ${userEmail} not exists`, 400);
  }

  if (user.role !== "user") {
    throw new AppError("User is already invited", 400);
  }

  await _deleteInvitesFromRedis(user.email);

  const newToken = uuidv4();
  const data = {
    profileURL: user.profileURL,
    adminName: admin.fullName,
    baseURL: getBaseURL(req),
    fullName: user.fullName,
    email: user.email,
    token: newToken,
    role,
  };

  methods.sendAdminInvite(data, req);
  return res.json(data);
};

const verifyToken = async (req, res) => {
  const { token, method = "accept" } = req.body;
  const data = await _verifyToken(token);

  if (method === "accept") {
    await _updateRole(data.email, data.role);
  }

  res.json(data);
};

const getAdmins = async (_, res) => {
  const admins = await User.findWhereNotIn({
    fields: ["profileURL", "fullName", "email", "role"],
    excludedValues: ["user", "owner"],
    column: "role",
  });

  const invited = await getHashList("invitation");
  res.json({ admins, invited: invited || [] });
};

const deleteInvite = async (req, res) => {
  const { adminId, email, token, method = "invite" } = req.body;
  await _checkValidity(adminId, ["owner"]);

  if (!email) {
    throw new AppError("Email is required");
  }

  if (token) {
    const key = `invitation:${token}`;
    await deleteFromHash(key);
  }

  await _updateRole(email, "user");
  const message =
    method === "invite"
      ? "Invite deleted successfully"
      : "User removed successfully";

  res.json({ message });
};

const updateRole = async (req, res) => {
  const { adminId, email, role } = req.body;

  await _checkValidity(adminId, ["owner"]);
  const user = await User.findOne({ email });
  if (!user) {
    throw new AppError(`User with ${email} not exists`, 400);
  }

  if (user.role === role) {
    throw new AppError(`User role is already ${role}`, 400);
  }

  await _updateRole(user.email, role);
  res.json({ message: "Role updated successfully" });
};

module.exports = {
  deleteInvite,
  adminInvite,
  verifyToken,
  updateRole,
  getAdmins,
};
