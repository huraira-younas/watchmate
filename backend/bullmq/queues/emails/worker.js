const logger = require("../../../methods/logger");
const enums = require("./utils/job_enums");
const _ = require("./utils/methods");

const jobs = {
  [enums.RESET_PASSWORD]: (data) => _.sendPassResetEmail(data),
  [enums.SERVER_MAIL]: (data) => _.sendServerMail(data),
  [enums.SEND_CODE]: (data) => _.sendEmailCode(data),
};

const jobHandler = async (job) => {
  try {
    logger.info(`👌 Processing job ${job.id}`);
    const jobFun = jobs[job.name];
    if (typeof jobFun !== "function") {
      throw new Error(`Invalid Job: ${job.name}`);
    }

    await jobFun(job.data);
  } catch (err) {
    logger.error(`⚠️  Failed job ${job.id}: ${err.message}`);
    throw err;
  }
};

module.exports = {
  handleComplete: undefined,
  handleProgress: undefined,
  handleDrained: undefined,
  handleResumed: undefined,
  handleClosing: undefined,
  handleStalled: undefined,
  handlePaused: undefined,
  handleClosed: undefined,
  handleFailed: undefined,
  handleError: undefined,
  jobHandler,
};
