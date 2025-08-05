const { spawn } = require("child_process");
const logger = require("./logger");
const fs = require("fs-extra");
const path = require("path");

const getDirectoryName = (filePath) => {
  return path.dirname(filePath);
};

async function copyDirectory(sourceDir, destinationDir) {
  try {
    await fs.copy(sourceDir, destinationDir);
    logger.info(`Directory copied from ${sourceDir} to ${destinationDir}`);
  } catch (error) {
    logger.error(`Error copying directory: ${error.message}`);
    throw error;
  }
}

async function removePaths(paths) {
  paths.forEach((dir) => {
    if (fs.existsSync(dir)) {
      logger.info(`🗑️  Deleting existing folder: ${dir}`);
      fs.rmSync(dir, { recursive: true, force: true }, (err) => {
        if (err) logger.error(`Error removing ${dir}: ${err.message}`);
      });
    }
  });
}

const walkAndUpdateFiles = async (src, dest, rootSrc = src) => {
  const entries = await fs.readdir(src, { withFileTypes: true });

  for (const entry of entries) {
    const sourcePath = path.join(src, entry.name);
    const relativePath = path.relative(rootSrc, sourcePath);
    const targetPath = path.join(dest, relativePath);

    if (entry.isDirectory()) {
      await fs.ensureDir(targetPath);
      logger.info(`📁 Entering directory: ${relativePath}`);

      await walkAndUpdateFiles(sourcePath, dest, rootSrc);
    } else if (entry.isFile()) {
      logger.info(`📝 Overwriting file: ${relativePath}`);
      await fs.copy(sourcePath, targetPath, { overwrite: true });
    }
  }
};

async function updateManifest({ distDir, name, desc }) {
  const filePath = path.join(distDir, "manifest.webmanifest");

  try {
    const data = await fs.readFile(filePath, "utf8");
    let manifest = JSON.parse(data);

    manifest.description = desc;
    manifest.short_name = name;
    manifest.name = name;

    await fs.writeFile(filePath, JSON.stringify(manifest, null, 2));
    logger.info(`✅ Manifest updated with name: ${name}`);
  } catch (err) {
    logger.error(`❌ Error updating manifest: ${err.message}`);
  }
}

async function updateOrCreateConfig(filePath, { appName, appTitle }) {
  try {
    await fs.ensureDir(path.dirname(filePath));

    const config = (await fs.pathExists(filePath))
      ? { ...(await fs.readJson(filePath)), appName, appTitle }
      : { appName, appTitle };

    await fs.writeJson(filePath, config, { spaces: 2 });
    logger.info(`Config updated: ${filePath}`);
  } catch (error) {
    logger.error(`Error updating/creating config: ${error}`);
  }
}

async function updateEnvFile(data, prefix) {
  const ENV_PATH = path.join(process.cwd(), "/.env");
  try {
    const exists = await fs
      .stat(ENV_PATH)
      .then(() => true)
      .catch(() => false);

    if (!exists) {
      logger.info("Creating new .env file... ✅");
      await fs.writeFile(ENV_PATH, "", "utf8");
    }

    const envVars = new Map(
      (await fs.readFile(ENV_PATH, "utf8").catch(() => ""))
        .split("\n")
        .filter((line) => line.includes("="))
        .map((line) => line.split("=").map((v) => v.trim()))
    );

    Object.entries(data).forEach(([key, value]) =>
      envVars.set(`${prefix}_${key.toUpperCase()}`, value)
    );

    await fs.writeFile(
      ENV_PATH,
      [...envVars].map(([k, v]) => `${k}=${v}`).join("\n"),
      "utf8"
    );

    logger.info(".env file updated successfully! ✅");
  } catch (error) {
    logger.error(`Error updating .env file ❌: ${error.message}`);
  }
}

const getVersionAndChangelogs = async (filePath) => {
  try {
    const fullPath = path.resolve(filePath);
    const fileContent = await fs.readFile(fullPath, "utf-8");
    const parsed = JSON.parse(fileContent);
    const { versions } = parsed;

    if (!versions) return { versions: { "1.0.0": [] } };

    return parsed;
  } catch (err) {
    return "Error reading version and changelogs:", err.message;
  }
};

const getServerConfig = async () => {
  const version = process.env.SERVER_VERSION || "v1.0.0";
  const BASE = path.join(process.cwd(), "..", "scripts", "core", version);
  const CONFIG_PATH = path.join(BASE, "scripts", "config.json");

  if (!fs.existsSync(CONFIG_PATH)) return { version, data: null };

  const fileContent = await fs.readFile(CONFIG_PATH, "utf-8");
  return { version, data: JSON.parse(fileContent) };
};

const runNpmInstall = (cwd) => {
  logger.warn("System is installing dependencies");
  const timeoutMs = 30000;
  return new Promise((resolve, reject) => {
    const child = spawn("npm", ["install"], {
      stdio: "ignore",
      shell: true,
      cwd,
    });

    const timer = setTimeout(() => {
      child.kill("SIGTERM");

      child.kill("SIGTERM");
      setTimeout(() => child.kill("SIGKILL"), 5000);

      reject(new Error("npm install timed out"));
    }, timeoutMs);

    child.on("error", (err) => {
      clearTimeout(timer);
      child.kill("SIGTERM");
      reject(err);
    });

    child.on("close", (code) => {
      clearTimeout(timer);
      if (code === 0) resolve();
      else reject(new Error(`npm install exited with code ${code}`));
    });
  });
};

module.exports = {
  getVersionAndChangelogs,
  updateOrCreateConfig,
  walkAndUpdateFiles,
  getDirectoryName,
  getServerConfig,
  updateManifest,
  updateEnvFile,
  runNpmInstall,
  copyDirectory,
  removePaths,
};
