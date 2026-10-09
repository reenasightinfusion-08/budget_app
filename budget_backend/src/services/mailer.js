const nodemailer = require('nodemailer');

const APP_NAME = 'Budgie';

const smtpUser = process.env.SMTP_USER;
const smtpPass = (process.env.SMTP_PASS || '').replace(/\s+/g, '');
const hasSmtp = Boolean(smtpUser && smtpPass);

const transport = hasSmtp
  ? nodemailer.createTransport(
      process.env.SMTP_HOST
        ? {
            host: process.env.SMTP_HOST,
            port: Number(process.env.SMTP_PORT || 587),
            secure: Number(process.env.SMTP_PORT) === 465,
            auth: { user: smtpUser, pass: smtpPass },
          }
        : { service: 'gmail', auth: { user: smtpUser, pass: smtpPass } },
    )
  : null;

const resolveFrom = () => {
  const from = (process.env.SMTP_FROM || '').trim();
  return from.includes('@') ? from : `"${APP_NAME}" <${smtpUser}>`;
};

const buildHtml = (subject, actionText, code) => `
  <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 24px; border: 1px solid #e0e0e0; border-radius: 12px; background-color: #ffffff;">
    <h2 style="color: #1a1a1a; margin-top: 0;">${subject}</h2>
    <p style="color: #555555; font-size: 16px;">Use this code to ${actionText}:</p>
    <div style="text-align: center; margin: 30px 0;">
      <span style="display: inline-block; font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #2b5ea7; background: #e8f0fb; padding: 12px 24px; border-radius: 8px;">${code}</span>
    </div>
    <p style="color: #777777; font-size: 14px; margin-bottom: 4px;">This code expires in 15 minutes.</p>
    <p style="color: #999999; font-size: 12px; margin-top: 20px; border-top: 1px solid #eeeeee; padding-top: 12px;">If you did not request this code, you can safely ignore this email.</p>
  </div>`;

/**
 * Emails a 6-digit code. Returns true only when an email was really sent;
 * false means SMTP is not configured or sending failed (the error is logged).
 */
async function sendCode(email, code, purpose) {
  if (!transport) {
    console.log(`[mailer] SMTP not configured (${purpose}) code for ${email}: ${code}`);
    return false;
  }

  const isVerify = purpose === 'verify';
  const subject = isVerify ? `Verify your ${APP_NAME} account` : `Reset your ${APP_NAME} password`;
  const actionText = isVerify ? 'verify your email address' : 'reset your password';

  try {
    const info = await transport.sendMail({
      from: resolveFrom(),
      to: email,
      subject,
      text: `Your code is ${code}. It expires in 15 minutes.`,
      html: buildHtml(subject, actionText, code),
    });
    console.log(`[mailer] Sent ${purpose} email to ${email}: ${info.messageId}`);
    return true;
  } catch (err) {
    console.error(`[mailer] Error sending ${purpose} email to ${email}:`, err.message);
    return false;
  }
}

module.exports = { sendCode };
