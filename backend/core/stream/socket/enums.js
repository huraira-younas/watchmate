const namespace = "stream";

const event = {
  DOWNLOAD_DIR: `${namespace}:download_direct`,
  DOWNLOAD_YT: `${namespace}:download_yt`,
  GET_ALL: `${namespace}:get_all`,
  CONNECTION: "connection",
};

module.exports = { event, namespace };
