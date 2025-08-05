const { getVersionAndChangelogs } = require("./methods/file_helpers");
const logger = require("./methods/logger");
const fs = require("fs-extra");
const path = require("path");

async function readModules(mPath, app, io) {
  try {
    const moduleNames = await fs.readdir(mPath);
    const loadPromises = moduleNames.map(async (moduleName) => {
      const modulePath = path.join(mPath, moduleName);

      const eventsPath = path.join(modulePath, "socket/events.js");
      const configPath = path.join(modulePath, "config.json");
      const routesPath = path.join(modulePath, "routes.js");

      try {
        const stat = await fs.stat(modulePath);
        if (!stat.isDirectory()) return;

        await Promise.all([
          loadRoutes(moduleName, routesPath, configPath, app),
          loadEvents(moduleName, eventsPath, io),
        ]);
      } catch (err) {
        logger.warn(`➡️  Skipping ${moduleName}: ${err.message}`);
      }
    });

    await Promise.all(loadPromises);
  } catch (err) {
    logger.error(`❌ Error loading modules: ${err.message}`);
  }
}

async function loadRoutes(moduleName, routesPath, configPath, app) {
  try {
    const routeStat = await fs.exists(routesPath);
    if (!routeStat) throw new Error(`Routes not found`);

    const endpoint = `/v1/api/${moduleName}`;
    const routes = require(routesPath);

    app.use(endpoint, routes);
    app.get(`${endpoint}/`, async (_, res) =>
      res.json(await getVersionAndChangelogs(configPath))
    );

    logger.info(`✔️  Routes Loaded for Module: ${moduleName}`);
  } catch (err) {
    logger.warn(`❌ Module ${moduleName}: ${err.message}`);
  }
}

async function loadEvents(moduleName, eventsPath, io) {
  try {
    const eventStat = await fs.exists(eventsPath);
    if (!eventStat) throw new Error(`Events not found`);

    const namespace = io.of(`/${moduleName}`);
    const event = require(eventsPath);
    event(namespace);

    logger.info(`🦋 Events Loaded for Module: ${moduleName}`);
  } catch (err) {
    if (err.message.includes("Events not found")) return;
    logger.warn(`❌ Module ${moduleName}: ${err.message}`);
  }
}

async function loadModules(app, io) {
  const BASE = process.cwd();

  const corePath = path.join(BASE, "core");
  await readModules(corePath, app, io);
}

module.exports = loadModules;
