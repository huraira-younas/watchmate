const { Server } = require("socket.io");

let io = null;

const initSocket = (server) => {
  if (!io) {
    io = new Server(server, {
      cors: { origin: "*" },
      path: "/v1/socket",
    });
  }

  return io;
};

const getIO = () => io;

module.exports = { initSocket, getIO };
