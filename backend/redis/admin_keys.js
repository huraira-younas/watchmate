const _validator = (name, key) => {
  const v = `admin:${name}`;
  if (key) return `${v}:${key}`;
  return v;
};

const Keys = {
  settings: (key) => _validator("settings", key),
  captchas: (key) => _validator("captchas", key),
  dataset: (key) => _validator("dataset", key),
  announcements: "admin:announcements",
  queueConfig: "admin:queue_config",
  jobConfig: "admin:job_config",
};

module.exports = Keys;
