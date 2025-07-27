const { createWorker, closeWorkers } = require("./methods/create_worker");
const { createQueue, closeQueues } = require("./methods/create_queue");
const connection = require("../redis/redis_client");
const logger = require("../methods/logger");
const fs = require("fs-extra");
const path = require("path");

const _createQueue = async (PRODUCER_PATH, name) => {
  if (await fs.pathExists(PRODUCER_PATH)) {
    const { handlers, init } = require(PRODUCER_PATH);
    if (typeof init === "function") {
      const queue = await createQueue({ connection, handlers, name });
      await init(queue);

      logger.info(`✅ ${name}: Producer is running`);
    } else logger.warn(`⚠️  ${name}: Producer init isn't a function`);
  } else logger.info(`✅ ${name}: Queue not found`);
};

const _createWorker = async (WORKER_PATH, name) => {
  if (await fs.pathExists(WORKER_PATH)) {
    const handlers = require(WORKER_PATH);
    await createWorker({ connection, handlers, name });
  } else logger.info(`✅ ${name}: Worker not found`);
};

const _handleCreation = async (QUEUE_DIR, queueName) => {
  const QUEUE_PATH = path.join(QUEUE_DIR, queueName);
  const isDir = await fs.stat(QUEUE_PATH).then((stat) => stat.isDirectory());

  if (!isDir) return;
  const PRODUCER_PATH = path.join(QUEUE_PATH, "producer.js");
  const WORKER_PATH = path.join(QUEUE_PATH, "worker.js");

  await _createQueue(PRODUCER_PATH, queueName);
  await _createWorker(WORKER_PATH, queueName);
};

const initializeQueues = async (resetQueue) => {
  const QUEUE_DIR = path.join(__dirname, "queues");
  const queueFolders = await fs.readdir(QUEUE_DIR);

  const promises = [];
  if (resetQueue) {
    promises.push([
      closeWorkers({ name: resetQueue }),
      closeQueues({ name: resetQueue }),
    ]);
  }

  await Promise.all(promises);

  for (const queueName of queueFolders) {
    if (resetQueue) {
      if (queueName !== resetQueue) continue;
      logger.info(`🛫 Restarting Queue: ${queueName}`);
      await _handleCreation(QUEUE_DIR, queueName);
      return;
    }
    await _handleCreation(QUEUE_DIR, queueName);
  }
};

module.exports = initializeQueues;
