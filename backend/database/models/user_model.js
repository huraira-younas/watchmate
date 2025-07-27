const { v4: uuidv4 } = require("uuid");
const db = require("../knex_client");
const dayjs = require("dayjs");

const User = {
  _userDevices: "user_devices",
  _users: "users",

  _formatDob(dob) {
    if (!dob) return null;
    return dayjs(dob).format("YYYY-MM-DD HH:mm:ss");
  },

  //? -- User Devices Methods ---

  async addDevice(data) {
    delete data.lastUsedAt;
    delete data.createdAt;
    const id = uuidv4();

    const res = await db(this._userDevices)
      .insert({ ...data, id })
      .onConflict(["userId", "token"])
      .merge({ lastUsedAt: db.fn.now() });

    const devices = await db(this._userDevices)
      .where({ userId: data.userId })
      .orderBy("lastUsedAt", "asc")
      .select("id");

    if (devices.length > 3) {
      const toDelete = devices.slice(0, devices.length - 3).map((d) => d.id);
      await db(this._userDevices).whereIn("id", toDelete).del();
    }

    return !!res ? devices[devices.length - 1] : false;
  },

  async deleteDevice(userId, deviceId) {
    const res = await db(this._userDevices)
      .where({ userId, id: deviceId })
      .del();

    return !!res;
  },

  async getDevice(userId, deviceId) {
    return await db(this._userDevices).where({ userId, id: deviceId }).first();
  },

  async getDevices(userId, fields = ["*"], limit = 3) {
    const res = await db(this._userDevices)
      .where({ userId })
      .select(fields)
      .orderBy("createdAt", "asc")
      .limit(limit);

    return res;
  },

  //? -- User Methods --

  async insert({ data, returnNew = true, fields = ["*"] }) {
    const id = uuidv4();
    delete data.createdAt;
    delete data.updatedAt;

    await db(this._users).insert({
      ...data,
      dob: this._formatDob(data.dob),
      id,
    });
    return returnNew ? await this.findById(id, fields) : null;
  },

  async insertEmail(data) {
    const id = uuidv4();
    await db(this._userContacts)
      .insert({ ...data, id })
      .onConflict()
      .ignore();
  },

  async findByIdAndDelete(userId) {
    return !!(await db(this._users).where({ id: userId }).del());
  },

  async findById(userId, fields = ["*"]) {
    const user = await db(this._users)
      .where({ id: userId })
      .select(fields)
      .first();

    if (user) {
      const bl = await Blacklist.findOne({ userId }, ["id"]);
      user.ban = bl?.id;
    }
    return user || null;
  },

  async findOne(query, fields = ["*"]) {
    const user = await db(this._users).where(query).select(fields).first();
    if (user) {
      const bl = await Blacklist.findOne({ userId: user.id }, ["id"]);
      user.ban = bl?.id;
    }

    return user || null;
  },

  async findOneIn(queries = [], fields = ["*"]) {
    if (queries.length === 0) return null;
    let query = db(this._users).select(fields);

    queries.forEach((condition, index) => {
      const key = Object.keys(condition)[0];
      const value = condition[key];

      if (index === 0) {
        query = query.where(key, value);
      } else {
        query = query.orWhere(key, value);
      }
    });

    const user = await query.first();
    if (user) {
      const bl = await Blacklist.findOne({ userId: user.id }, ["id"]);
      user.ban = bl?.id;
    }

    return user || null;
  },

  async findOneAndUpdate({ query, data, returnNew = true, fields = ["*"] }) {
    delete data.createdAt;
    delete data.updatedAt;

    if (data.dob) {
      data.dob = this._formatDob(data.dob);
    }

    const updated = await db(this._users)
      .update({
        ...data,
        updatedAt: db.fn.now(),
      })
      .where(query);

    return !!updated && returnNew ? await this.findOne(query, fields) : false;
  },

  async findByIdAndUpdate({ userId, data, returnNew = true, fields = ["*"] }) {
    delete data.createdAt;
    delete data.updatedAt;

    if (data.dob) {
      data.dob = this._formatDob(data.dob);
    }

    const updated = await db(this._users)
      .update({
        ...data,
        updatedAt: db.fn.now(),
      })
      .where({ id: userId });

    return !!updated && returnNew ? await this.findById(userId, fields) : false;
  },

  async aggregateNearbyUsers({
    fields = ["*"],
    coordinates,
    limit = 3,
    radius,
  }) {
    const [lng, lat] = coordinates;
    const point = `POINT(${lng} ${lat})`;
    const axis = "ST_GeomFromText(?, 4326)";
    const distanceQuery = `ST_Distance_Sphere(a.coordinates, ${axis})`;

    const users = await db("users as u")
      .join("addresses as a", "u.id", "a.userId")
      .select(
        db.raw(`${distanceQuery} as distance`, [point]),
        "a.text as addressText",
        ...fields.map((field) => `u.${field}`)
      )
      .whereRaw(`${distanceQuery} <= ?`, [point, radius])
      .orderBy("distance")
      .limit(limit);

    const [{ totalCount }] = await db("users as u")
      .join("addresses as a", "u.id", "a.userId")
      .count("* as totalCount")
      .whereRaw(`${distanceQuery} <= ?`, [point, radius]);

    return { users, totalCount };
  },

  _excludeQuery(query) {
    return query
      .leftJoin("blacklist as b", "users.id", "b.userId")
      .whereNull("b.userId");
  },

  async searchUsersByFullName(name, userId) {
    const un = "user_neighborhoods";
    const baseQuery = db("users")
      .where("users.disabled", false)
      .andWhereNot("users.id", userId)
      .leftJoin(un, function () {
        this.on(`${un}.userId`, "users.id").andOn(
          `${un}.isPrimary`,
          db.raw("true")
        );
      })
      .leftJoin("neighborhoods", "neighborhoods.id", `${un}.neighborhoodId`)
      .where(`${un}.isPrimary`, true)
      .andWhereRaw("LOWER(users.fullName) LIKE ?", [`%${name.toLowerCase()}%`])
      .select(
        "neighborhoods.name as neighborhood",
        "users.profileURL",
        "users.fullName",
        "users.username",
        "users.id"
      );

    return this._excludeQuery(baseQuery);
  },

  async find({ params = {}, search, disabled, fields = ["users.*"] }) {
    let query = db(this._users)
      .where("users.disabled", disabled)
      .select(fields);

    if (search) {
      query.where((qb) => {
        qb.where("users.email", "like", `%${search}%`).orWhere(
          "users.fullName",
          "like",
          `%${search}%`
        );
      });
    }

    if (params.excludeBL) query = this._excludeQuery(query);
    if (params.offset) query = query.offset(params.offset);
    if (params.limit) query = query.limit(params.limit);

    return await query;
  },

  async findWhereNotIn({
    fields = ["users.*"],
    excludedValues,
    params = {},
    column,
  }) {
    let query = db(this._users)
      .whereNotIn(column, excludedValues)
      .select(fields);

    if (params.excludeBL) query = this._excludeQuery(query);
    if (params.offset) query = query.offset(params.offset);
    if (params.limit) query = query.limit(params.limit);

    return await query;
  },

  async findWhere({ conditions, params = {}, fields = ["users.*"] }) {
    let query = db(this._users).select(fields).where(conditions);

    if (params.excludeBL) query = this._excludeQuery(query);
    if (params.offset) query = query.offset(params.offset);
    if (params.limit) query = query.limit(params.limit);

    return await query;
  },

  async findWhereIn({ column, values, fields = ["users.*"] }) {
    let query = db(this._users).whereIn(column, values).select(fields);
    return await query;
  },

  async count(conditions = {}, params = {}) {
    const { search, ...rest } = conditions;
    const query = db(this._users).where(rest);

    if (search) {
      query.where((qb) => {
        qb.where("users.email", "like", `%${search}%`).orWhere(
          "users.fullName",
          "like",
          `%${search}%`
        );
      });
    }

    if (params.excludeBL) this._excludeQuery(query);
    const res = await query.count("* as total");
    return res[0]?.total || 0;
  },
};

module.exports = User;
