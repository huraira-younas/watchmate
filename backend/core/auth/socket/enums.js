const namespace = "auth";

const event = {
  DISCONNECT_USER: `${namespace}:disconnect_user`,
  CONNECT_USER: `${namespace}:connect_user`,
  CONNECTION: "connection",
};

module.exports = { event, namespace };
