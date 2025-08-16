const enums = require("./utils/job_enums");
let queue = null;

const init = async (que) => {
  await queue?.close();
  queue = que;
  
  sendServerMail();
};

const _withConfig = async (name, data) => {
  queue?.add(name, data);
};

const sendResetMail = (data) => _withConfig(enums.RESET_PASSWORD, data);
const sendCode = (data) => _withConfig(enums.SEND_CODE, data);

const getQueue = () => queue;

module.exports = {
  handlers: {
    handleCompleted: undefined,
    handleProgress: undefined,
    handleWaiting: undefined,
    handleActive: undefined,
    handleFailed: undefined,
  },
  methods: { sendResetMail, sendCode },
  getQueue,
  init,
};
