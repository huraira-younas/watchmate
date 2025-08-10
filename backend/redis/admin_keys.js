const _validator = (pre, name, key) => {
  const v = `${pre}:${name}`;
  if (key) return `${v}:${key}`;
  return v;
};

const Keys = {
  socketKey: (name, key) => _validator("socket", name, key),
  queueConfig: "admin:queue_config",
  jobConfig: "admin:job_config",
};

module.exports = Keys;
