const logger = require("../../methods/logger");
const db = require("../knex_client");

async function createTable() {
  const trx = await db.transaction();
  try {
    await trx.schema.hasTable("users").then(async (exists) => {
      if (!exists) {
        await trx.schema.createTable("users", (table) => {
          table.string("role").defaultTo("user").notNullable();
          table.string("username").notNullable().unique();
          table.string("email").notNullable().unique();
          table.string("password").notNullable();
          table.string("profileURL").nullable();
          table.string("ipAddress").nullable();
          table.string("coverURL").nullable();
          table.string("gender").nullable();
          table.string("name").nullable();
          table.string("bio").nullable();
          table.uuid("id").primary();

          table.boolean("disabled").defaultTo(false).notNullable().index();
          table.timestamp("createdAt").defaultTo(trx.fn.now()).index();
          table.timestamp("updatedAt").defaultTo(trx.fn.now());
        });
        logger.warn("✅ Users table created!");
      }
    });

    await trx.schema.hasTable("user_devices").then(async (exists) => {
      if (!exists) {
        await trx.schema.createTable("user_devices", (table) => {
          table.uuid("id").primary();

          table
            .uuid("userId")
            .notNullable()
            .references("id")
            .inTable("users")
            .onDelete("CASCADE");

          table.string("token").notNullable();
          table.string("browser").nullable();
          table.string("type").nullable();
          table.string("os").nullable();

          table.timestamp("lastUsedAt").defaultTo(trx.fn.now());
          table.timestamp("createdAt").defaultTo(trx.fn.now());
          table.unique(["userId", "token"]);

          table.index("lastUsedAt");
        });

        logger.warn("✅ User devices table created!");
      }
    });

    await trx.commit();
  } catch (error) {
    await trx.rollback();
    logger.error(`❌ Error creating user table: ${error.message}`);
  }
}

module.exports = { createTable, dependencies: [] };
