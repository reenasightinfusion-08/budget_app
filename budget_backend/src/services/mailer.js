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
const BRAND_DARK = '#12305A';
const INK = '#101A2B';
const MUTED = '#5B6778';
const FONT = "-apple-system,'Segoe UI',Roboto,Helvetica,Arial,sans-serif";

// One unbroken text node so a double-tap or long-press on mobile selects the whole code.
const codeBlock = (code) =>
  `<div style="display:inline-block;padding:18px 20px 18px 30px;background:#EEF3FA;border:1px solid #D5E1F2;border-radius:16px;font-family:'SF Mono',Menlo,Consolas,'Courier New',monospace;font-size:40px;line-height:44px;font-weight:700;letter-spacing:10px;color:${BRAND_DARK};-webkit-user-select:all;user-select:all;">${code}</div>`;

const buildHtml = (heading, intro, code) => `
<!doctype html>
<html>
<body style="margin:0;padding:0;background:#EDF1F6;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#EDF1F6;padding:32px 12px;font-family:${FONT};">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:500px;background:#ffffff;border-radius:20px;overflow:hidden;">
        <tr>
          <td align="center" style="background:${BRAND};padding:32px 24px 28px;">
            <div style="display:inline-block;width:56px;height:56px;line-height:56px;border-radius:16px;background:rgba(255,255,255,0.18);font-size:30px;text-align:center;">&#128038;</div>
            <div style="margin-top:12px;font-size:26px;font-weight:700;letter-spacing:0.5px;color:#ffffff;">${APP_NAME}</div>
            <div style="margin-top:4px;font-size:13px;color:#C9DBF3;">Your money, made simple</div>
          </td>
        </tr>
        <tr>
          <td align="center" style="padding:36px 28px 8px;">
            <h1 style="margin:0 0 12px;font-size:24px;line-height:30px;color:${INK};font-weight:700;">${heading}</h1>
            <p style="margin:0;font-size:15px;line-height:23px;color:${MUTED};">${intro}</p>
          </td>
        </tr>
        <tr>
          <td align="center" style="padding:28px 12px 8px;">
            ${codeBlock(code)}
          </td>
        </tr>
        <tr>
          <td align="center" style="padding:20px 28px 32px;">
            <span style="display:inline-block;padding:6px 14px;border-radius:999px;background:#FDF1DA;color:#8A5A00;font-size:13px;font-weight:600;">Expires in 15 minutes</span>
          </td>
        </tr>
        <tr>
          <td style="padding:0 28px 28px;">
            <div style="border-top:1px solid #E3E9F0;padding-top:20px;font-size:13px;line-height:20px;color:${MUTED};text-align:center;">
              Never share this code with anyone. ${APP_NAME} will never ask you for it.<br>
              Didn&rsquo;t request this? You can safely ignore this email.
            </div>
          </td>
        </tr>
      </table>
      <div style="padding:18px 8px 0;font-size:12px;color:#97A2B2;text-align:center;">&copy; ${APP_NAME}</div>
    </td></tr>
  </table>
</body>
</html>`;

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
