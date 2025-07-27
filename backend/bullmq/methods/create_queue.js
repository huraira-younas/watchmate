const { Queue, QueueEvents } = require("bullmq");
const logger = require("../../methods/logger");

let queuesEvents = new Map();
let queues = new Map();

const defaultHandlers = {
  progress: ({ jobId, data }, ts) => logger.info(`👨‍💻 Job ${jobId} progress: ${data} at ${ts}`),
  failed: ({ jobId, failedReason }) => logger.warn(`⚠️ Job ${jobId} failed: ${failedReason}`),
  active: ({ jobId, prev }) => logger.info(`🐥 Job ${jobId} is now active (was ${prev})`),
  waiting: ({ jobId }) => logger.info(`🫸 Queue job ${jobId} is waiting`),
  completed: ({ jobId }) => logger.info(`✅ Job ${jobId} completed`),
};

async function _resetQueue(name, queue) {
  try {
    logger.info(`🔁 Draining queue: ${name}`);
    await queue.drain(true);

    logger.info(`🧹 Cleaning queue: ${name}`);
    await queue.clean(0, 0, "completed");
    await queue.clean(0, 0, "failed");

    logger.info(`💣 Obliterating queue: ${name}`);
    await queue.obliterate({ force: true });

    logger.info(`🙌 Closing queue: ${name}`);
    await queue.close();

    logger.info(`✅ Queue "${name}" reset and closed.`);
  } catch (err) {
    logger.error(`❗ Failed to reset/close queue "${name}": ${err.message}`);
  }
}

async function closeQueues({ name }) {
  const qe = queuesEvents.get(name);
  const queue = queues.get(name);

  if (!queue) return logger.warn(`🤷 ${name}: No queue found to reset`);

  const tasks = [qe?.close(), _resetQueue(name, queue)];
  await Promise.allSettled(tasks);

  queuesEvents.delete(name);
  queues.delete(name);
}

async function createQueue({ name, connection, handlers = {} }) {
  await Promise.all([
    queuesEvents.get(name)?.close(),
    queues.get(name)?.close(),
  ]);

  const queue = new Queue(name, { connection });
  const queueEvents = new QueueEvents(name, { connection });
  const allHandlers = { ...defaultHandlers, ...handlers };

  for (const event of [
    "completed",
    "progress",
    "waiting",
    "failed",
    "active",
  ]) {
    queueEvents.on(event, allHandlers[event]);
  }

  queues.set(name, queue);
  queuesEvents.set(name, queueEvents);

  return queue;
}

module.exports = {
  createQueue,
  closeQueues,
};
