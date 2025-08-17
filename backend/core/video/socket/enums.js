const namespace = "video";

const event = {
  PARTY_MESSAGE: `${namespace}:party_message`,
  REACT_MESSAGE: `${namespace}:react_message`,
  CREATE_PARTY: `${namespace}:create_party`,
  VIDEO_ACTION: `${namespace}:video_action`,
  LEAVE_PARTY: `${namespace}:leave_party`,
  CLOSE_PARTY: `${namespace}:close_party`,
  JOIN_PARTY: `${namespace}:join_party`,
  CONNECTION: "connection",
};

module.exports = { event, namespace };
