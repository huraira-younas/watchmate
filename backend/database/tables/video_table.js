const logger = require("../../methods/logger");
const db = require("../knex_client");

async function createTable() {
  const trx = await db.transaction();
  try {
    await trx.schema.hasTable("videos").then(async (exists) => {
      if (!exists) {
        await trx.schema.createTable("videos", (table) => {
          table.string("visibility").defaultTo("public").notNullable();
          table.string("type").defaultTo("youtube").notNullable();
          table.string("thumbnailURL").notNullable();
          table.string("videoURL").notNullable();
          table.integer("height").notNullable();
          table.integer("width").notNullable();
          table.string("title").notNullable();
          table.uuid("id").primary();
          
          table.integer("duration").notNullable().defaultTo(0);
          table.bigInteger("likes").notNullable().defaultTo(0);
          table.bigInteger("size").notNullable().defaultTo(0);

          table
            .uuid("userId")
            .notNullable()
            .references("id")
            .inTable("users")
            .onDelete("CASCADE");

          table.boolean("deleted").defaultTo(false).notNullable().index();
          table.timestamp("createdAt").defaultTo(trx.fn.now()).index();
          table.timestamp("updatedAt").defaultTo(trx.fn.now());
        });
        logger.warn("✅ Videos table created!");
      }
    });

    await trx.commit();
  } catch (error) {
    await trx.rollback();
    logger.error(`❌ Error creating Videos table: ${error.message}`);
  }
}

module.exports = { createTable, dependencies: ["user"] };
