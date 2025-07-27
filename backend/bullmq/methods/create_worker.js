const logger = require("../../methods/logger");
const { Worker } = require("bullmq");
let workers = new Map();

const _handleComplete = (job) => {
  logger.info(`✅ Job ${job.name}: ${job.id} completed`);
};

const _handleFailed = (job, err) => {
  const msg = `Job ${job.name}: ${job?.id}`;
  logger.error(`❌ ${msg} failed: ${err.message}`);
};

const _handleProgress = (job, progress) => {
  logger.info(`📈 ${job.name}: ${job.id} progress: ${progress}`);
};

const _handleStalled = (jobId) => {
  logger.warn(`😵 Job ${jobId} stalled and will be retried`);
};

const _handleDrained = (name) => () => {
  logger.info(`🚰 Queue ${name} has been drained`);
};

const _handlePaused = (name) => () => {
  logger.info(`⏸️ Worker ${name} paused`);
};

const _handleResumed = (name) => () => {
  logger.info(`▶️ Worker ${name} resumed`);
};

const _handleError = (name) => (err) => {
  logger.error(`💥 Worker ${name} error: ${err.message}`);
};

const _handleClosing = (name) => () => {
  logger.info(`🔒 Worker ${name} is closing...`);
};

const _handleClosed = (name) => () => {
  logger.info(`🧹 Worker ${name} has been closed`);
};

async function closeWorkers({ name }) {
  const worker = workers.get(name);
  
  if (!worker) return logger.warn(`🤷 ${name}: No worker found to close`);
  worker?.close(true);

  workers.delete(name);
}

async function createWorker({ connection, handlers, name }) {
  await workers.get(name)?.close(true);

  const worker = new Worker(name, handlers.jobHandler, {
    removeOnComplete: { age: 60 * 5, count: 20 },
    removeOnFail: { age: 60 * 10 },
    concurrency: 10,
    connection,
  });

  const onDrained = handlers?.handleDrained || _handleDrained(name);
  const onResumed = handlers?.handleResumed || _handleResumed(name);
  const onClosing = handlers?.handleClosing || _handleClosing(name);
  const onComplete = handlers?.handleComplete || _handleComplete;
  const onProgress = handlers?.handleProgress || _handleProgress;
  const onPaused = handlers?.handlePaused || _handlePaused(name);
  const onClosed = handlers?.handleClosed || _handleClosed(name);
  const onStalled = handlers?.handleStalled || _handleStalled;
  const onError = handlers?.handleError || _handleError(name);
  const onFailed = handlers?.handleFailed || _handleFailed;

  worker.on("completed", onComplete);
  worker.on("progress", onProgress);
  worker.on("stalled", onStalled);
  worker.on("drained", onDrained);
  worker.on("resumed", onResumed);
  worker.on("closing", onClosing);
  worker.on("paused", onPaused);
  worker.on("failed", onFailed);
  worker.on("closed", onClosed);
  worker.on("error", onError);

  logger.info(`✅ ${name}: Worker is running`);

  workers.set(name, worker);
  return worker;
}

module.exports = { createWorker, closeWorkers };
