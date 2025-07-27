const prefix = "auth";

const events = {
  DISCONNECT_USER: `${prefix}:disconnect_user`,
  CONNECT_USER: `${prefix}:connect_user`,
  CONNECTION: "connection",
};

module.exports = events;
