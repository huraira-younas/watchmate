const logger = require("../methods/logger");
const redis = require("./redis_client.js");

const parseJson = (data) => (data ? JSON.parse(data) : null);

async function flushRedis({ exclude = ["admin"] } = {}) {
  try {
    const allKeys = await redis.keys("*");
    const keysToDelete = allKeys.filter(
      (key) => !exclude.some((prefix) => key.startsWith(prefix))
    );

    if (keysToDelete.length > 0) {
      await redis.del(...keysToDelete);
      logger.info(`Redis flushed. Deleted ${keysToDelete.length} keys.`);
    } else {
      logger.info("Redis flush skipped. No keys matched for deletion.");
    }
  } catch (err) {
    logger.error("Failed to flush Redis:", err);
  }
}

//* =========== Sorted Set Methods ===========

async function getSortedSetsByPattern({
  batchSize = 100,
  scanCount = 100,
  order = "asc",
  limit = 10,
  pattern,
}) {
  const keys = [];
  let cursor = "0";

  do {
    const [nextCursor, batch] = await redis.scan(
      cursor,
      "MATCH",
      `${pattern}:*`,
      "COUNT",
      scanCount
    );
    cursor = nextCursor;
    keys.push(...batch);
  } while (cursor !== "0" && keys.length < limit);

  const limitedKeys = keys.slice(0, limit);
  if (limitedKeys.length === 0) return {};

  const formatted = {};
  for (const key of limitedKeys) {
    const totalMessages = await redis.zcard(key);
    if (totalMessages === 0) {
      formatted[key] = [];
      continue;
    }

    const roomMessages = [];
    let start = 0;
    let end = batchSize - 1;

    while (start < totalMessages) {
      let batch = [];

      if (order === "desc") {
        batch = await redis.zrevrange(key, start, end);
      } else {
        batch = await redis.zrange(key, start, end);
      }

      for (const raw of batch) {
        roomMessages.push(parseJson(raw));
      }

      start += batchSize;
      end += batchSize;
    }
    formatted[key] = roomMessages;
  }
  return formatted;
}

const addToSortedSet = async (key, value, score, expire = 0) => {
  try {
    logger.info(`Adding to Redis Sorted Set: ${key}`);
    const pipeline = redis.pipeline();
    pipeline.zadd(key, score, JSON.stringify(value));

    if (expire > 0) pipeline.expire(key, expire * 60);
    const [res] = await pipeline.exec();
    if (res) logger.info(`Added to sorted set successfully: ${res}`);
  } catch (err) {
    logger.error(`Redis Sorted Set Error (addToSortedSet): ${err.message}`);
  }
};

const getSortedSetCardinality = async (key) => {
  try {
    const count = await redis.zcard(key);
    return count;
  } catch (err) {
    logger.error(
      `Redis Sorted Set Error (getSortedSetCardinality): ${err.message}`
    );
    return 0;
  }
};

const removeFromSortedSet = async (key, value, removeByScore = false) => {
  try {
    logger.info(`Removing from Redis Sorted Set: ${key}`);
    const res = removeByScore
      ? await redis.zremrangebyscore(key, value, value)
      : await redis.zrem(key, JSON.stringify(value));

    if (res) logger.info(`Removed from sorted set successfully: ${res}`);
    return res;
  } catch (err) {
    logger.error(
      `Redis Sorted Set Error (removeFromSortedSet): ${err.message}`
    );
  }
};

const trimSortedSet = async (key, start, end) => {
  try {
    logger.info(`Trimming Redis Sorted Set: ${key}`);
    const res = await redis.zremrangebyrank(key, start, end);
    if (res) logger.info(`Trimmed sorted set successfully: ${res}`);
  } catch (err) {
    logger.error(`Redis Sorted Set Error (trimSortedSet): ${err.message}`);
  }
};

const getSortedSetRange = async (key, start = 0, end = 99, order = "asc") => {
  try {
    const data = await (order === "asc"
      ? redis.zrange(key, start, end)
      : redis.zrevrange(key, start, end));

    return data
      .map((item) => {
        try {
          return parseJson(item);
        } catch (err) {
          logger.error(`JSON parse error: ${err.message}`);
          return null;
        }
      })
      .filter(Boolean);
  } catch (err) {
    logger.error(`Redis Sorted Set Error (getSortedSetRange): ${err.message}`);
    return [];
  }
};

//* =========== List Methods ===========
const addToList = async (key, value, expire = 0) => {
  try {
    logger.info(`Adding to Redis List: ${key}`);
    const pipeline = redis.pipeline();
    pipeline.rpush(key, JSON.stringify(value));
    if (expire > 0) {
      pipeline.expire(key, expire * 60);
    }
    const [res] = await pipeline.exec();
    if (res) logger.info(`Added to list successfully: ${res}`);
  } catch (err) {
    logger.error(`Redis List Error (addToList): ${err.message}`);
  }
};

const replaceItemInList = async (key, index, newItem) => {
  try {
    const pipeline = redis.pipeline();
    pipeline.lset(key, index, JSON.stringify(newItem));
    await pipeline.exec();

    logger.info(`Replaced item at index ${index} in Redis List: ${key}`);
    return true;
  } catch (err) {
    logger.error(`Redis List Error (replaceItemInList): ${err.message}`);
    return false;
  }
};

const getListRange = async (key, start = 0, end = 99) => {
  try {
    const data = await redis.lrange(key, start, end);
    return data
      .map((item) => {
        try {
          return parseJson(item);
        } catch (err) {
          logger.error(`JSON parse error: ${err.message}`);
          return null;
        }
      })
      .filter(Boolean);
  } catch (err) {
    logger.error(`Redis List Error (getListRange): ${err.message}`);
    return [];
  }
};

const removeItemFromList = async (key, item) => {
  try {
    await redis.lrem(key, 0, JSON.stringify(item));
    logger.info(`Removed From Redis List: ${key}`);
  } catch (err) {
    logger.error(`Redis List Error (Remove Item): ${err.message}`);
  }
};

const trimList = async (key, start, end) => {
  try {
    await redis.ltrim(key, start, end);
    logger.info(`Trimmed Redis List: ${key}`);
  } catch (err) {
    logger.error(`Redis List Error (trimList): ${err.message}`);
  }
};

const setRoomLock = async (lockKey) => {
  const lock = await redis.set(lockKey, "locked", "NX", "EX", 5);
  return lock === "OK";
};

const releaseRoomLock = async (lockKey) => {
  await redis.del(lockKey);
};

const addToHash = async (key, value, expire = 1) => {
  try {
    logger.info(`Setting to redis: ${key}`);
    const pipeline = redis.pipeline();
    pipeline.hset(key, "data", JSON.stringify(value));
    if (expire > 0) {
      pipeline.expire(key, expire * 60);
    }
    const [res] = await pipeline.exec();
    if (res) {
      logger.info(`Data set successfully ${res}`);
    }
  } catch (err) {
    logger.error(`Redis Error: ${err}`);
  }
};

const getMemberFromHash = async (key) => {
  try {
    const data = await redis.hget(key, "data");
    return parseJson(data);
  } catch (err) {
    logger.error(`Error getting data: ${err.message}`);
    return null;
  }
};

const getTimeToLive = async (key) => {
  logger.info(`Getting time to live: ${key}`);
  return await redis.ttl(key);
};

const getSpecificList = async (pattern, keys) => {
  try {
    const pipeline = redis.pipeline();
    keys.forEach((key) => pipeline.hget(`${pattern}:${key}`, "data"));
    const results = await pipeline.exec();
    const data = results.map(([err, res]) => parseJson(res));
    return data.length ? data : null;
  } catch (err) {
    logger.error(`Error getting data: ${err.message}`);
    return null;
  }
};

const getHashList = async (keyPattern, start = 0, end = -1) => {
  try {
    const keys = await redis.keys(`*${keyPattern}*`);
    if (!keys.length) return null;

    const validStart = Math.max(0, start);
    const validEnd =
      end === -1 ? keys.length - 1 : Math.min(keys.length - 1, end);
    const selectedKeys = keys.slice(validStart, validEnd + 1);

    const pipeline = redis.pipeline();
    selectedKeys.forEach((key) => pipeline.hget(key, "data"));
    const results = await pipeline.exec();

    const data = results.map(([err, res]) => (err ? null : parseJson(res)));
    return data.length ? data.filter((item) => item !== null) : null;
  } catch (err) {
    logger.error(`Error getting data: ${err.message}`);
    return null;
  }
};

const countFieldsInHash = async (key) => {
  try {
    const keys = await redis.keys(`*${key}*`);
    return keys.length;
  } catch (err) {
    logger.error(`Error counting fields in hash: ${err.message}`);
    throw err;
  }
};

const setHashList = async (field, values, expire = 60) => {
  if (values?.length === 0) return;

  try {
    logger.info(`Setting list to redis: ${field}`);
    const pipeline = redis.pipeline();
    values.forEach((value) => {
      const key = `${field}:${value._id}`;
      pipeline
        .hset(key, "data", JSON.stringify(value))
        .expire(key, expire * 60);
    });

    await pipeline.exec();
    logger.info(`Data set successfully for ${values.length} items`);
  } catch (err) {
    logger.error(`Error setting data: ${err.message}`);
  }
};

const deleteFromHash = async (key) => {
  try {
    const deleted = await redis.hdel(key, "data");
    if (deleted) {
      logger.info(`Data deleted successfully`);
    } else {
      logger.info(`No data found for ${key} to delete`);
    }
  } catch (err) {
    logger.error(`Error deleting data: ${err.message}`);
  }
};

const deleteFromHashByPattern = async (keyPattern) => {
  try {
    const keys = await redis.keys(`*${keyPattern}*`);
    if (!keys.length) {
      logger.info(`No keys found matching pattern: ${keyPattern}`);
      return;
    }
    const pipeline = redis.pipeline();
    keys.forEach((key) => pipeline.del(key));
    await pipeline.exec();

    logger.info(`Deleted keys matching pattern: ${keyPattern}`);
  } catch (err) {
    logger.error(`Error deleting keys by pattern: ${err.message}`);
    throw err;
  }
};

const countKeysByPattern = async (pattern) => {
  let cursor = "0";
  let totalCount = 0;

  try {
    do {
      const result = await redis.scan(cursor, "MATCH", pattern, "COUNT", 1000);
      cursor = result[0];
      const keys = result[1];

      totalCount += keys.length;
    } while (cursor !== "0");

    return totalCount;
  } catch (err) {
    logger.error(`Error counting keys by pattern: ${err.message}`);
    throw err;
  }
};

// ----------------------------------------------------------------
//? Set methods
const addToSet = async (key, value, expire) => {
  try {
    logger.info(`Adding to set in redis: ${key}`);
    await redis.sadd(key, JSON.stringify(value));

    const pipeline = redis.pipeline();
    pipeline.sadd(key, JSON.stringify(value));
    
    if (expire > 0) pipeline.expire(key, expire * 60);

    const [res] = await pipeline.exec();
    if (res) logger.info(`Data set successfully ${res}`);
  } catch (err) {
    logger.error(`Redis Error: ${err}`);
  }
};

const removeFromSet = async (key, value) => {
  try {
    logger.info(`Removing from set in redis: ${key}`);
    await redis.srem(key, JSON.stringify(value));
  } catch (err) {
    logger.error(`Redis Error: ${err}`);
  }
};

const getMembersFromSet = async (key) => {
  try {
    logger.info(`Getting members from set in redis: ${key}`);
    const members = await redis.smembers(key);
    return members.map((member) => parseJson(member));
  } catch (err) {
    logger.error(`Redis Error: ${err}`);
  }
};

const isMemberOfSet = async (key, value) => {
  redis.sismember(key, value, (err, reply) => {
    if (err) {
      logger.error(`Error checking value in set: ${err}`);
      return false;
    }
    if (reply === 1) {
      logger.info(`${valueToCheck} exists in the set ${key}`);
      return true;
    } else {
      logger.info(`${valueToCheck} does not exist in the set ${key}`);
      return false;
    }
  });
};

const countMembersInSet = async (key) => {
  try {
    logger.info(`Counting members in set: ${key}`);
    return await redis.scard(key);
  } catch (err) {
    logger.error(`Error counting members in set: ${err.message}`);
    throw err;
  }
};

const getRangeFromRedis = async (key, count = 4) => {
  const allMembers = [];
  let cursor = "0";

  do {
    const { items, cursor: nextCursor } = await fetchRange(key, count, cursor);
    allMembers.push(...items);
    cursor = nextCursor;
  } while (cursor !== "0");

  return allMembers.map((item) => parseJson(item));
};

const fetchRange = async (key, count, cursor) => {
  try {
    const [nextCursor, items] = await redis.sscan(key, cursor, "COUNT", count);

    return { items, cursor: nextCursor };
  } catch (err) {
    logger.error(`Redis Error while scanning ${key}: ${err}`);
    throw err;
  }
};

module.exports = {
  //* ==== Sorted Set ====
  getSortedSetCardinality,
  getSortedSetsByPattern,
  removeFromSortedSet,
  getSortedSetRange,
  addToSortedSet,
  trimSortedSet,

  //* ==== Hast List ====
  removeItemFromList,
  replaceItemInList,
  getListRange,
  getHashList,
  setHashList,

  deleteFromHashByPattern,
  countKeysByPattern,
  getRangeFromRedis,
  countMembersInSet,
  getMemberFromHash,
  countFieldsInHash,
  getMembersFromSet,
  getSpecificList,
  releaseRoomLock,
  deleteFromHash,
  removeFromSet,
  isMemberOfSet,
  getTimeToLive,
  setRoomLock,
  addToList,
  addToHash,
  trimList,
  addToSet,

  flushRedis,
};
