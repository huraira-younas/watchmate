const {
  validateEvent,
  SocketResponse,
} = require("../../../methods/socket/socket_methods.js");
const User = require("../../../database/models/user_model");
const R2Client = require("../../../clients/r2_client.js");
const logger = require("../../../methods/logger");

const createParty = async ({ event, socket, data }) => {
  
};

module.exports = { createParty };
