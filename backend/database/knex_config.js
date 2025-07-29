const path = require("path");
require("dotenv").config();
const fs = require("fs");

const ensureDir = (dir) => {
  if (fs.existsSync(dir)) return;
  fs.mkdirSync(dir, { recursive: true });
};

const migrationsDir = path.join(process.cwd(), "database", "migrations");
const seedsDir = path.join(process.cwd(), "database", "seeds");

ensureDir(migrationsDir);
ensureDir(seedsDir);

const baseConfig = {
  client: "pg",
  connection: {
    ssl: process.env.DB_SSL === "true" ? { rejectUnauthorized: false } : false,
    port: process.env.DB_PORT?.trim() || 5432,
    password: process.env.DB_PASSWORD?.trim(),
    database: process.env.DB_DATABASE?.trim(),
    user: process.env.DB_USERNAME?.trim(),
    host: process.env.DB_HOST?.trim(),
  },
  seeds: { directory: seedsDir },
  pool: { max: 10, min: 2 },
  migrations: {
    tableName: "knex_migrations",
    directory: migrationsDir,
  },
};

module.exports = {
  development: baseConfig,
  production: baseConfig,
  both: baseConfig,
};
