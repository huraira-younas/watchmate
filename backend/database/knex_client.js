const config = require("./knex_config");
const knex = require("knex");

const environment = process.env.NODE_ENV || "development";
const db = knex(config[environment]);

module.exports = db;
