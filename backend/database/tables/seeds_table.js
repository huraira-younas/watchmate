const logger = require("../../methods/logger");
const db = require("../knex_client");

async function createTable() {
  const trx = await db.transaction();
  try {
    if (!(await trx.schema.hasTable("seeds"))) {
      await trx.schema.createTable("seeds", (table) => {
        table.timestamp("ran_at").defaultTo(trx.fn.now());
        table.string("name").primary();
      });

      logger.warn("✅ Seeds table created!");
    }

    await trx.commit();
  } catch (error) {
    await trx.rollback();
    logger.error(`❌ Error creating seeds table: ${error.message}`);
  }
}

module.exports = { createTable, dependencies: [] };
