const {
  addToHash,
  getMemberFromHash,
} = require("../../../../redis/redis_methods");
const { validateReq } = require("../../../../methods/utils");
const expire = require("../../../../redis/redis_expire");
const nodemailer = require("nodemailer");
const fs = require("fs-extra");
const path = require("path");

const MAIL_PATH = path.join(__dirname, "../mail_templates");
const APPNAME = process.env.APP_NAME || "Ovadey";
let node_client = null;

const _getSignature = async () => {
  return `Team ${APPNAME}`;
};

const useNodeMailer = async (from, mailData) => {
  const secure = process.env.MAILER_SECURE;
  const user = process.env.MAILER_USER;
  const pass = process.env.MAILER_PASS;
  const host = process.env.MAILER_HOST;
  const port = process.env.MAILER_PORT;

  if (!node_client) {
    node_client = nodemailer.createTransport({
      auth: { user, pass },
      secure: secure,
      from: user,
      port: port,
      host,
    });
  }

  await node_client.sendMail({ ...mailData, from: `"${from}" <${user}>` });
};

const sendEmailCode = async (data) => {
  validateReq(data, ["email", "code", "name", "baseURL"]);
  const { email, code, name, baseURL } = data;

  const file = path.join(MAIL_PATH, "code", "code.html");
  let emailHtml = fs.readFileSync(file, "utf8");

  const signin_link = `${baseURL}/app/auth/signup`;
  const help_center = `${baseURL}/app/help-center`;
  const signature = await _getSignature();

  emailHtml = emailHtml
    .replace(/\$\{signin_link\}/g, signin_link)
    .replace(/\$\{help_center\}/g, help_center)
    .replace(/\$\{signature\}/g, signature)
    .replace(/\$\{username\}/g, name)
    .replace(/\$\{code\}/g, code);

  const msg = `Your verification code is: ${code}`;
  await useNodeMailer("Envato Admin", {
    html: emailHtml,
    subject: msg,
    text: msg,
    to: email,
  });

  await addToHash(`code:${email}`, { email, code }, expire.code);
};

const sendPassResetEmail = async (data) => {
  validateReq(data, ["email", "baseURL", "name"]);
  const { email, baseURL, name } = data;

  const file = path.join(MAIL_PATH, "reset_password", "reset_password.html");
  let emailHtml = fs.readFileSync(file, "utf8");

  const help_center = `${baseURL}/app/help-center`;
  const signature = await _getSignature();

  emailHtml = emailHtml
    .replace(/\$\{username\}/g, name || "Neighbor")
    .replace(/\$\{help_center\}/g, help_center)
    .replace(/\$\{signature\}/g, signature);

  await useNodeMailer("Envato Admin", {
    text: "Your password has been reset",
    subject: `Reset Password`,
    html: emailHtml,
    to: email,
  });
};

module.exports = {
  sendPassResetEmail,
  sendEmailCode,
};
