const archiver = require("archiver");
const logger = require("./logger");
const AdmZip = require("adm-zip");
const fs = require("fs-extra");
const path = require("path");

/**
 * Creates a zip from a directory
 * @param {string} zipPath - Destination .zip file path
 * @param {string} dirPath - Directory to zip
 */
async function createZip(zipPath, dirPath) {
  try {
    await fs.ensureDir(path.dirname(zipPath));

    const output = fs.createWriteStream(zipPath);
    const archive = archiver("zip", { zlib: { level: 9 } });

    return new Promise((resolve, reject) => {
      output.on("close", () => {
        logger.info(`✅ ZIP created: ${zipPath} (${archive.pointer()} bytes)`);
        resolve(zipPath);
      });

      output.on("error", (err) => {
        logger.error(`❌ ZIP stream error: ${err.message}`);
        reject(err);
      });

      archive.pipe(output);
      archive.directory(dirPath, false);
      archive.finalize();
    });
  } catch (error) {
    logger.error(`❌ ZIP creation failed: ${error.message}`);
    throw error;
  }
}

/**
 * Extracts a zip file to a destination.
 * Deletes any folder named "app" or "dashboard" at any nesting level.
 *
 * @param {string} zipPath - Path to .zip file
 * @param {string} destPath - Folder to extract into
 */
const extractZip = (zipPath, destPath) => {
  try {
    if (!fs.existsSync(zipPath)) {
      throw new Error("Zip file does not exist.");
    }

    const zip = new AdmZip(zipPath);
    zip.extractAllTo(destPath, true);
    logger.info(`📦 Extracted zip to: ${destPath}`);

    fs.rmSync(zipPath, { force: true });
    logger.info(`🗑️ Deleted zip successfully.`);
  } catch (err) {
    logger.error(`❌ Extraction failed: ${err.message}`);
    throw err;
  }
};

module.exports = { createZip, extractZip };
