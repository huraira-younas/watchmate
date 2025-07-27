const { flushRedis } = require("../redis/redis_methods");
const User = require("./models/user_model");
const logger = require("../methods/logger");
const mysqldump = require("mysqldump");
const { v4: uuidv4 } = require("uuid");
const db = require("./knex_client");
const bcrypt = require("bcryptjs");
const path = require("path");
const fs = require("fs");

async function dropTables(tables = []) {
  try {
    if (!Array.isArray(tables) || tables.length === 0) {
      logger.warn("⚠️ No tables specified for dropping.");
      return;
    }

    await db.transaction(async (trx) => {
      await trx.raw("SET FOREIGN_KEY_CHECKS = 0");

      let tablesToDrop = tables;
      if (tables.length === 1 && tables[0].toLowerCase() === "all") {
        const res = await trx("information_schema.tables")
          .select("table_name")
          .where("table_schema", trx.raw("DATABASE()"));
        flushRedis({ exclude: [] });
        tablesToDrop = res.map((t) => t.TABLE_NAME || t.table_name);
      }

      logger.warn(`🗑️  Dropping tables: ${tablesToDrop.join(", ")}`);

      await Promise.all(
        tablesToDrop.map((table) =>
          trx.schema.dropTableIfExists(table).then(() => {
            logger.info(`✅ Dropped table: ${table}`);
          })
        )
      );

      await trx.raw("SET FOREIGN_KEY_CHECKS = 1");
    });
  } catch (error) {
    const query = `❌ Error dropping tables: ${tables.join(", ")}`;
    logger.error(`${query} - ${error.message}`);
  }
}

async function insertAdmin() {
  if (!process.env.ADMIN_EMAIL) return;
  const exists = await db("users").where({ role: "owner" }).first();
  if (exists) return;

  const pass = process.env.ADMIN_PASSWORD;
  const hashedPassword = await bcrypt.hash(pass, 10);
  const username = process.env.ADMIN_EMAIL?.split("@")[0];
  const id = uuidv4();

  const trx = await db.transaction();
  try {
    await trx("users")
      .insert({
        fullName: process.env.ADMIN_NAME,
        phone: process.env.ADMIN_PHONE,
        email: process.env.ADMIN_EMAIL,
        password: hashedPassword,
        role: "owner",
        username,
        id,
      })
      .onConflict("email")
      .merge(["fullName", "password", "phone", "role"]);

    await trx.commit();
  } catch (err) {
    await trx.rollback();
    throw err;
  }
}

async function initializeDB() {
  try {
    await _createDatabase();

    const resetTables = process.env.RESET?.split(",") || [];
    if (resetTables.length !== 0) {
      await dropTables(resetTables);
    }

    await _initializeTables();
    await db.migrate.latest();
    await insertAdmin();
    db.seed.run();

    logger.info("🚀 MySQL is running and connected!");
    return true;
  } catch (error) {
    logger.error(`❌ MySQL connection failed: ${error.message}`);
    return false;
  }
}

async function _createDatabase() {
  try {
    await db.raw(`CREATE DATABASE IF NOT EXISTS ??`, [process.env.DB_DATABASE]);
    await db.raw(
      `ALTER DATABASE ?? CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`,
      [process.env.DB_DATABASE]
    );

    logger.info(`✅ Database ${process.env.DB_DATABASE} is ready!`);
  } catch (error) {
    logger.error(`❌ Error creating database: ${error.message}`);
  }
}

const _initializeTables = async () => {
  const tablesDir = path.join(__dirname, "tables");
  try {
    logger.info("🚀 Scanning tables directory...");
    const tableFiles = fs.readdirSync(tablesDir);
    const tables = [];

    for (const file of tableFiles) {
      const tableModule = require(path.join(tablesDir, file));

      if (typeof tableModule.createTable === "function") {
        tables.push({
          dependencies: tableModule.dependencies || [],
          module: tableModule,
          name: file,
        });
      } else {
        logger.warn(`⚠️  Skipping ${file} (No createTable function found)`);
      }
    }

    const sortedTables = topologicalSort(tables);
    const tSorted = sortedTables.map((e) => e.name);
    console.table(tSorted);

    logger.info("📌 Creating tables in proper order...");
    for (const table of sortedTables) {
      await table.module.createTable();
      logger.info(`💊 Table setup completed for ${table.name}`);
    }

    logger.info("🎉 All required tables have been initialized!");
  } catch (error) {
    logger.error(`❌ Error initializing tables: ${error.message}`);
  }
};

const topologicalSort = (tables) => {
  const visited = new Set();
  const sorted = [];

  const visit = (table) => {
    if (visited.has(table.name)) return;
    visited.add(table.name);

    table.dependencies.forEach((dep) => {
      const depTable = tables.find((t) => t.name.includes(dep));
      if (depTable) visit(depTable);
    });

    sorted.push(table);
  };

  tables.forEach(visit);
  return sorted;
};

async function dumpDB() {
  await mysqldump({
    connection: {
      database: process.env.DB_DATABASE?.trim(),
      password: process.env.DB_PASSWORD?.trim(),
      user: process.env.DB_USERNAME?.trim(),
      host: process.env.DB_HOST?.trim(),
    },
    dumpToFile: "./backup.sql",
  });

  logger.info("✅ MySQL dump complete.");
}

module.exports = { initializeDB, dropTables, dumpDB };
