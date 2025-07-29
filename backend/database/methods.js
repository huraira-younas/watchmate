const { flushRedis } = require("../redis/redis_methods");
const logger = require("../methods/logger");
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
      let tablesToDrop = tables;
      if (tables.length === 1 && tables[0].toLowerCase() === "all") {
        const res = await trx.raw(`
          SELECT table_name FROM information_schema.tables 
          WHERE table_schema = 'public' AND table_type='BASE TABLE';
        `);
        flushRedis({ exclude: [] });
        tablesToDrop = res.rows.map((t) => t.table_name);
      }

      logger.warn(`🗑️  Dropping tables: ${tablesToDrop.join(", ")}`);

      for (const table of tablesToDrop) {
        await trx.schema.dropTableIfExists(table);
        logger.info(`✅ Dropped table: ${table}`);
      }
    });
  } catch (error) {
    logger.error(`❌ Error dropping tables: ${error.message}`);
  }
}

async function insertAdmin() {
  if (!process.env.ADMIN_EMAIL) return;

  const exists = await db("users").where({ role: "owner" }).first();
  if (exists) return;

  const hashedPassword = await bcrypt.hash(process.env.ADMIN_PASSWORD, 10);
  const username = process.env.ADMIN_EMAIL?.split("@")[0];
  const id = uuidv4();

  const trx = await db.transaction();
  try {
    await trx("users")
      .insert({
        id,
        email: process.env.ADMIN_EMAIL,
        name: process.env.ADMIN_NAME,
        password: hashedPassword,
        role: "owner",
        username,
      })
      .onConflict("email")
      .merge(["name", "password", "role"]);

    await trx.commit();
  } catch (err) {
    await trx.rollback();
    logger.error(`❌ Admin insert failed: ${err.message}`);
  }
}

async function initializeDB() {
  try {
    const resetTables = process.env.RESET?.split(",") || [];
    if (resetTables.length > 0) await dropTables(resetTables);

    await _initializeTables();
    await db.migrate.latest();
    await insertAdmin();
    await db.seed.run();

    logger.info("🚀 PostgreSQL is running and connected!");
    return true;
  } catch (error) {
    logger.error(`❌ PostgreSQL setup failed: ${error.message}`);
    return false;
  }
}

async function _initializeTables() {
  const tablesDir = path.join(__dirname, "tables");

  try {
    logger.info("🚀 Scanning tables directory...");
    const tableFiles = fs.readdirSync(tablesDir);

    const tables = tableFiles
      .map((file) => {
        const tableModule = require(path.join(tablesDir, file));
        if (typeof tableModule.createTable === "function") {
          return {
            dependencies: tableModule.dependencies || [],
            module: tableModule,
            name: file,
          };
        }
        logger.warn(`⚠️  Skipping ${file} (No createTable function)`);
        return null;
      })
      .filter(Boolean);

    const sortedTables = topologicalSort(tables);
    console.table(sortedTables.map((e) => e.name));

    for (const table of sortedTables) {
      await table.module.createTable();
      logger.info(`💊 Table setup completed for ${table.name}`);
    }

    logger.info("🎉 All tables initialized successfully!");
  } catch (error) {
    logger.error(`❌ Error initializing tables: ${error.message}`);
  }
}

function topologicalSort(tables) {
  const visited = new Set();
  const sorted = [];

  function visit(table) {
    if (visited.has(table.name)) return;
    visited.add(table.name);

    table.dependencies.forEach((dep) => {
      const depTable = tables.find((t) => t.name.includes(dep));
      if (depTable) visit(depTable);
    });

    sorted.push(table);
  }

  tables.forEach(visit);
  return sorted;
}

async function dumpDB() {
  logger.warn("⚠️ pg_dump is not supported via Node. Run it via CLI or CI.");
}

module.exports = {
  initializeDB,
  dropTables,
  dumpDB,
};
