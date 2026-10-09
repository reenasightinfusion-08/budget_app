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

// Recipients should see "Budgie", never the raw Gmail address, whatever SMTP_FROM holds.
const resolveFrom = () => {
  const configured = (process.env.SMTP_FROM || '').trim();
  const address = (configured.match(/<([^>]+)>/) || [])[1] || (configured.includes('@') ? configured : smtpUser);
  return { name: APP_NAME, address };
};

const BRAND = '#2C5FA0';
const INK = '#101A2B';
const MUTED = '#5B6778';

const buildHtml = (heading, intro, code) => `
<div style="background:#EDF1F6;padding:32px 16px;font-family:Arial,Helvetica,sans-serif;">
  <div style="max-width:480px;margin:0 auto;">
    <div style="text-align:center;padding-bottom:16px;">
      <span style="display:inline-block;background:${BRAND};color:#ffffff;font-size:20px;font-weight:bold;letter-spacing:1px;padding:10px 22px;border-radius:999px;">${APP_NAME}</span>
    </div>
    <div style="background:#ffffff;border-radius:16px;padding:32px 28px;text-align:center;">
      <h2 style="margin:0 0 12px;font-size:22px;color:${INK};">${heading}</h2>
      <p style="margin:0 0 24px;font-size:15px;line-height:22px;color:${MUTED};">${intro}</p>
      <div style="display:inline-block;background:#EBF0F6;border-radius:12px;padding:14px 26px;font-size:34px;font-weight:bold;letter-spacing:8px;color:${BRAND};">${code}</div>
      <p style="margin:24px 0 0;font-size:13px;color:${MUTED};">This code expires in 15 minutes.</p>
    </div>
    <p style="margin:16px 8px 0;text-align:center;font-size:12px;line-height:18px;color:#97A2B2;">
      Didn’t request this? You can safely ignore this email.<br>© ${APP_NAME}
    </p>
  </div>
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
  const subject = isVerify ? `Verify your email — ${APP_NAME}` : `Reset your password — ${APP_NAME}`;
  const heading = isVerify ? 'Verify your email' : 'Reset your password';
  const intro = isVerify
    ? 'Enter this code in the app to confirm your email and finish setting up your Budgie account.'
    : 'Enter this code in the app to choose a new password for your Budgie account.';

  try {
    const info = await transport.sendMail({
      from: resolveFrom(),
      to: email,
      subject,
      text: `Your code is ${code}. It expires in 15 minutes.`,
      html: buildHtml(heading, intro, code),
    });
    console.log(`[mailer] Sent ${purpose} email to ${email}: ${info.messageId}`);
    return true;
  } catch (err) {
    console.error(`[mailer] Error sending ${purpose} email to ${email}:`, err.message);
    return false;
  }
}

module.exports = { sendCode };
