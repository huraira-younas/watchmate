const { v4: uuidv4 } = require("uuid");
const db = require("../knex_client");

const Video = {
  _videos: "videos",

  async insert({ data, returnNew = true, fields = ["*"] }) {
    const id = data.id || uuidv4();
    delete data.createdAt;
    delete data.updatedAt;

    await db(this._videos).insert({ ...data, id });
    return returnNew ? await this.findById(id, fields) : null;
  },

  async findByIdAndDelete(id) {
    return !!(await db(this._videos).where({ id }).del());
  },

  async findById(id, fields = ["*"]) {
    const vid = await db(this._videos).where({ id }).select(fields).first();
    return vid || null;
  },

  async findOne(query, fields = ["*"]) {
    const vid = await db(this._videos).where(query).select(fields).first();
    return vid || null;
  },

  async findOneIn(queries = [], fields = ["*"]) {
    if (queries.length === 0) return null;
    const query = db(this._videos).select(fields);

    queries.forEach((condition, index) => {
      const key = Object.keys(condition)[0];
      const value = condition[key];

      if (index === 0) query.where(key, value);
      else query.orWhere(key, value);
    });

    const vid = await query.first();
    return vid || null;
  },

  async findOneAndUpdate({ query, data, returnNew = true, fields = ["*"] }) {
    delete data.createdAt;
    delete data.updatedAt;

    const updated = await db(this._videos)
      .update({
        ...data,
        updatedAt: db.fn.now(),
      })
      .where(query);

    return !!updated && returnNew ? await this.findOne(query, fields) : false;
  },

  async findByIdAndUpdate({ id, data, returnNew = true, fields = ["*"] }) {
    delete data.createdAt;
    delete data.updatedAt;

    const updated = await db(this._users)
      .update({
        ...data,
        updatedAt: db.fn.now(),
      })
      .where({ id });

    return !!updated && returnNew ? await this.findById(id, fields) : false;
  },

  async pagination({ limit, cursor, conditions, search, fields = ["*"] }) {
    let query = db(this._videos).select(fields);

    if (conditions) query.where(conditions);
    if (search) {
    }

    if (cursor) query.andWhere("createdAt", "<", cursor);
    query.orderBy("createdAt", "desc").limit(limit + 1);

    const results = await query;
    const hasMore = results.length > limit;

    return {
      cursor: hasMore ? results[limit - 1].createdAt : null,
      results: results.slice(0, limit),
      hasMore,
    };
  },
};

module.exports = Video;
