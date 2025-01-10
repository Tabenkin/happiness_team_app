const { defineSecret, defineString } = require("firebase-functions/params");

const sendgridAPIKey = defineSecret("sendgrid_api_key");
const fromEmail = defineString("FROM_EMAIL");

export const sendEmail = async (to: string, subject: string, body: string) => {
  const sgMail = require("@sendgrid/mail");

  sgMail.setApiKey(sendgridAPIKey.value());

  const msg = {
    to: to,
    from: `Happiness Team <${fromEmail.value()}>`,
    subject: subject,
    html: body,
  };

  await sgMail.send(msg);
};
