const { defineSecret } = require("firebase-functions/params");

const sendgridAPIKey = defineSecret("sendgrid_api_key");
const fromEmail = "no-reply@readwithmesalon.com";

export const sendEmail = async (to: string, subject: string, body: string) => {
  const sgMail = require("@sendgrid/mail");
  sgMail.setApiKey(sendgridAPIKey.value());

  const msg = {
    to: to,
    from: fromEmail, // Use the email address or domain you verified above
    subject: subject,
    html: body,
  };

  await sgMail.send(msg);
};
