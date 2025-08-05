const namespace = "stream";

const event = {
  DOWNLOAD_YT: `${namespace}:download_yt`,
  HANDLE: `${namespace}:download`,
  CONNECTION: "connection",
};

module.exports = { event, namespace };
