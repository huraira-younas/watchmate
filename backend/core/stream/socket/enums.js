const namespace = "stream";

const event = {
  RESUME_DOWNLOAD: `${namespace}:resume_download`,
  PAUSE_DOWNLOAD: `${namespace}:pause_download`,
  DOWNLOAD_DIR: `${namespace}:download_direct`,
  STOP_DOWNLOAD: `${namespace}:stop_download`,
  DOWNLOAD_YT: `${namespace}:download_yt`,
  CONNECTION: "connection",
};

module.exports = { event, namespace };
