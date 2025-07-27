const logger = require("./logger");
const dayjs = require("dayjs");
const path = require("path");
const fs = require("fs");

function triggerRestart() {
  try {
    const restartFilePath = path.join(process.cwd(), "tmp/restart.txt");
    logger.info("🔁 Restarting Server...");

    if (fs.existsSync(restartFilePath)) {
      fs.unlinkSync(restartFilePath);
    }

    const now = dayjs().format("DD-MM | hh:mm A");
    fs.writeFileSync(restartFilePath, `Restarted ${now}`);
    logger.info(`✅ Restart file written: ${now}`);
    
  } catch (error) {
    logger.error(`❌ Error triggering restart: ${error.message}`);
  }
}

module.exports = triggerRestart;
