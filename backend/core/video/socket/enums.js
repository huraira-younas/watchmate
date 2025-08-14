const namespace = "video";

const event = {
  PARTY_MESSAGE: `${namespace}:party_message`,
  CREATE_PARTY: `${namespace}:create_party`,
  LEAVE_PARTY: `${namespace}:leave_party`,
  JOIN_PARTY: `${namespace}:join_party`,
  CONNECTION: "connection",
};

module.exports = { event, namespace };
