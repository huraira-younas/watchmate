class SocketParams {
  constructor({ event, io, socket, data }) {
    this.socket = socket;
    this.event = event;
    this.data = data;
    this.io = io;
  }
}

class SocketError extends Error {
  constructor(message, statusCode = 500) {
    super(message);
    this.status = `${statusCode}`.startsWith("4") ? "fail" : "error";
    this.statusCode = statusCode;
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

class SocketResponse {
  constructor({ message, data, code = 200 }) {
    this.message = message;
    this.data = data;
    this.code = code;
  }
}

function validateEvent(fields, requiredFields, exclude = []) {
  if (exclude.includes("*")) {
    for (const key of Object.keys(fields)) {
      if (!requiredFields.includes(key)) delete fields[key];
    }
  } else if (exclude.length > 0) {
    for (const key of exclude) delete fields[key];
  }

  const missing = requiredFields.filter(
    (field) => fields[field] === undefined || fields[field] === null
  );

  if (missing.length) {
    throw new SocketError(
      `Missing required fields: ${missing.join(", ")}`,
      400
    );
  }
}

module.exports = {
  SocketResponse,
  validateEvent,
  SocketParams,
  SocketError,
};
