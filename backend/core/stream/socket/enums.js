const namespace = "stream";

const event = {
  DOWNLOAD_YT: `${namespace}:download_yt`,
  HANDLE: `${namespace}:download`,
  GET_ALL: `${namespace}:get_all`,
  CONNECTION: "connection",
};

module.exports = { event, namespace };
