import { onCall } from "firebase-functions/v2/https";
import { sendEmail } from "./email.helper";
const { defineSecret, defineString } = require("firebase-functions/params");

const sendgridAPIKey = defineSecret("sendgrid_api_key");
const fromEmail = defineString("FROM_EMAIL");

export const sendFeedback = onCall(
  { secrets: [sendgridAPIKey] },
  async (event) => {
    const email = event.data.fromEmail;
    const message = event.data.feedback;

    const body = `
        <p>
            From: ${email}
        </p>
        <p>
            <b>Feedback:</b>
            <br/>
            ${message}
        </p>
     
    `;

    // We are sending the email to our standard "From email" address.
    await sendEmail(fromEmail.value(), "Happiness Team App Feedback", body);
  }
);
