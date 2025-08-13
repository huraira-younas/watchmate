const namespace = "video";

const event = {
  CREATE_PARTY: `${namespace}:create_party`,
  CLOSE_PARTY: `${namespace}:close_party`,
  CONNECTION: "connection",
};

module.exports = { event, namespace };
