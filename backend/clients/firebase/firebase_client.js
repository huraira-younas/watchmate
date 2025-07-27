const logger = require("../../methods/logger");
const admin = require("firebase-admin");
const fs = require("fs-extra");
const path = require("path");
let firebaseApp = null;

const initFirebase = async (forceInit) => {
  if (firebaseApp && !forceInit) return { success: true, client: firebaseApp };
  firebaseApp = null;

  const CONFIG_PATH = path.join(__dirname, "./service.json");
  if (!fs.existsSync(CONFIG_PATH)) {
    return { success: false, error: "service.json file not found" };
  }

  try {
    const serviceJson = require(CONFIG_PATH);
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(serviceJson),
    });

    return { success: true, client: firebaseApp };
  } catch (err) {
    return { success: false, error: err.message };
  }
};

const getMessaging = () => {
  if (!firebaseApp) {
    const msg = "⚠️ Firebase isn't initialized, call initFirebase() first";
    return logger.error(msg);
  }

  return admin.messaging();
};

module.exports = { initFirebase, getMessaging };
