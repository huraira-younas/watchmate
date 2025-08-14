const {
  validateEvent,
  SocketResponse,
  SocketError,
} = require("../../../methods/socket/socket_methods.js");
const {
  addToHash,
  deleteFromHash,
  getMemberFromHash,
} = require("../../../redis/redis_methods.js");
const User = require("../../../database/models/user_model");
const expire = require("../../../redis/redis_expire.js");
const Keys = require("../../../redis/admin_keys.js");
const logger = require("../../../methods/logger");

const createParty = async ({ event, socket, data }) => {
  validateEvent(data, ["userId", "partyId"]);
  const { partyId, userId } = data;

  const key = Keys.partyKey(partyId);
  socket.partyId = partyId;

  const party = { owner: userId, partyId, joinee: [userId] };
  await addToHash(key, party, expire.party_room);
  socket.join(partyId);

  logger.info(`Party created: ${partyId}`);
  socket.emit(
    event,
    new SocketResponse({
      message: "Created Party Successfully",
      data: party,
    })
  );
};

const leaveParty = async ({ event, socket, io, data }) => {
  validateEvent(data, ["userId", "partyId"]);
  const { partyId, userId } = data;

  const key = Keys.partyKey(partyId);
  const party = await getMemberFromHash(key);
  if (!party) return;

  party.joinee = party.joinee.filter((r) => r !== userId);
  const user = await User.findById(userId, ["name", "profileURL", "id"]);
  if (party.joinee.length === 0) {
    await deleteFromHash(key);
  }

  const message = `${user.name} leaved party: ${partyId}`;
  delete socket.partyId;
  socket.leave(partyId);
  logger.info(message);

  io.to(partyId).emit(
    event,
    new SocketResponse({
      message,
      data: {
        profileURL: user.profileURL ?? "",
        joined: party.joinee.length,
        message: `Left the party`,
        name: user.name,
        userId: user.id,
      },
    })
  );
};

const joinParty = async ({ event, socket, io, data }) => {
  validateEvent(data, ["userId", "partyId"]);
  const { partyId, userId } = data;

  const key = Keys.partyKey(partyId);
  const party = await getMemberFromHash(key);
  if (!party) throw new SocketError("Watch party not found", 400);

  const promises = [User.findById(userId, ["name", "profileURL", "id"])];

  if (!party.joinee.includes(userId)) {
    promises.push(addToHash(key, party, expire.party_room));
    party.joinee.push(userId);
  }

  const [user] = await Promise.all(promises);

  const message = `${user.name} joined party: ${partyId}`;
  socket.partyId = partyId;
  socket.join(partyId);
  logger.info(message);

  io.to(partyId).emit(
    event,
    new SocketResponse({
      message,
      data: {
        profileURL: user.profileURL ?? "",
        joined: party.joinee.length,
        message: `Joined the party`,
        name: user.name,
        userId: user.id,
      },
    })
  );
};

const sendMessage = async ({ event, socket, io, data }) => {
  validateEvent(data, ["message", "partyId"]);
  const { partyId, message } = data;

  const key = Keys.partyKey(partyId);
  const party = await getMemberFromHash(key);
  if (!party) throw new SocketError("Watch party not found", 400);
  
  logger.info(`Message: ${message}`);
  socket.partyId = partyId;
  io.to(partyId).emit(
    event,
    new SocketResponse({
      message: "Recieved a message",
      data: message,
    })
  );
};

module.exports = { createParty, leaveParty, joinParty, sendMessage };
