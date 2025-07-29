const Transport = require("winston-transport");
const nodemailer = require("nodemailer");
const dayjs = require("dayjs");

const transporter = nodemailer.createTransport({
  secure: process.env.MAILER_SECURE,
  host: process.env.MAILER_HOST,
  port: process.env.MAILER_PORT,
  auth: {
    user: process.env.MAILER_USER,
    pass: process.env.MAILER_PASS,
  },
});

class EmailOnErrorTransport extends Transport {
  log(info, callback) {
    const env = process.env.NODE_ENV.toLowerCase();
    const APPNAME = process.env.APP_NAME;

    if (info.level === "error" && env === "production") {
      const html = `
        <div style="font-family:Arial,sans-serif;padding:20px;">
          <h2 style="color:#e74c3c;">🚨 Error Notification</h2>
          <p><strong>Time:</strong> ${dayjs().format("YYYY-MM-DD A")}</p>
          <p><strong>Message:</strong></p>
          <pre style="background:#f4f4f4;padding:10px;border-left:4px solid #e74c3c;">${
            info.message
          }</pre>
        </div>
      `;

      transporter.sendMail(
        {
          from: `"${APPNAME} Logger Bot" <${process.env.MAILER_USER}>`,
          to: "raohuraira331.rb@gmail.com",
          subject: "🚨 Server Error Alert",
          html,
        },
        (err) => {
          if (err) console.error("❌ Email failed:", err.message);
          else console.log("📧 Error email sent");
        }
      );
    }

    callback();
  }
}

module.exports = { transporter, EmailOnError: new EmailOnErrorTransport() };
