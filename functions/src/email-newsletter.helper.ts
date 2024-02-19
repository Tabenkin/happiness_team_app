const { onSchedule } = require("firebase-functions/v2/scheduler");
import { onCall } from "firebase-functions/v2/https";

const { defineSecret } = require("firebase-functions/params");
const sendgridAPIKey = defineSecret("sendgrid_api_key");

import { getFirestore } from "firebase-admin/firestore";
import { sendEmail } from "./email.helper";

const db = getFirestore();

export const winNotificationEmailsCron = onSchedule(
  {
    schedule: "0 0 1 * *",
    secrets: [sendgridAPIKey],
  },
  async () => {
    await sendWinNotificationEmailsCron();

    return true;
  }
);

export const testWinNotificationEmailsCron = onCall(
  { secrets: [sendgridAPIKey] },
  async () => {
    await sendWinNotificationEmailsCron();
    return true;
  }
);

const sendWinNotificationEmailsCron = async () => {
  const usersSnapshot = await db
    .collection("/users")
    .where("allowEmailNotifications", "==", true)
    .where("numWins", ">=", 10)
    .get();

  if (usersSnapshot.docs.length === 0) return;

  for (const userDoc of usersSnapshot.docs) {
    const userData = userDoc.data();

    const email = userData.email;

    if (!email || email == "") continue;

    const userWinsSnapshot = await db
      .collection(`/users/${userDoc.id}/wins`)
      .get();
    const userWins = userWinsSnapshot.docs.map((doc) => doc.data());

    // get 5 random wins from the user's wins
    const randomWins = userWins
      .sort(() => Math.random() - Math.random())
      .slice(0, 5);

    const subject = "Take a moment to reflect on some of your wins";
    const body = getEmailBody(randomWins);

    console.log("Sending email to", email, "with subject", subject);

    await sendEmail(email, subject, body);
  }
};

const getEmailBody = (wins: any) => {
  var winsContent = "";

  var index = 0;

  for (var win of wins) {
    // Convert win.date which is a timestamp to a strirng like May 3rd, 2024

    const dateString = timestampToDateString(win.date);
    var border = "";

    if (index < wins.length - 1) {
      border = "border-bottom: 1px dashed #ddd;";
    }

    winsContent += `
        
    <table class="module" role="module" data-type="code" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; ${border}" data-muid="8e041543-6bee-4681-b50f-0bbbd2447ae1">
    <tbody>
      <tr>
        <td height="100%" valign="top" role="module-content"><div style="padding-top: 16px; padding-bottom: 16px;">
  <p>
  ${win.notes}
  </p>
  <p style="font-style: italic;">
  ${dateString}
  </p>

</div></td>
      </tr>
    </tbody>
  </table>
        
        `;

    index++;
  }

  const body = `
 <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html data-editor-version="2" class="sg-campaigns" xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1">
      <!--[if !mso]><!-->
      <meta http-equiv="X-UA-Compatible" content="IE=Edge">
      <!--<![endif]-->
      <!--[if (gte mso 9)|(IE)]>
      <xml>
        <o:OfficeDocumentSettings>
          <o:AllowPNG/>
          <o:PixelsPerInch>96</o:PixelsPerInch>
        </o:OfficeDocumentSettings>
      </xml>
      <![endif]-->
      <!--[if (gte mso 9)|(IE)]>
  <style type="text/css">
    body {width: 600px;margin: 0 auto;}
    table {border-collapse: collapse;}
    table, td {mso-table-lspace: 0pt;mso-table-rspace: 0pt;}
    img {-ms-interpolation-mode: bicubic;}
  </style>
<![endif]-->
      <style type="text/css">
    body, p, div {
      font-family: arial,helvetica,sans-serif;
      font-size: 14px;
    }
    body {
      color: #000000;
    }
    body a {
      color: #1188E6;
      text-decoration: none;
    }
    p { margin: 0; padding: 0; }
    table.wrapper {
      width:100% !important;
      table-layout: fixed;
      -webkit-font-smoothing: antialiased;
      -webkit-text-size-adjust: 100%;
      -moz-text-size-adjust: 100%;
      -ms-text-size-adjust: 100%;
    }
    img.max-width {
      max-width: 100% !important;
    }
    .column.of-2 {
      width: 50%;
    }
    .column.of-3 {
      width: 33.333%;
    }
    .column.of-4 {
      width: 25%;
    }
    ul ul ul ul  {
      list-style-type: disc !important;
    }
    ol ol {
      list-style-type: lower-roman !important;
    }
    ol ol ol {
      list-style-type: lower-latin !important;
    }
    ol ol ol ol {
      list-style-type: decimal !important;
    }
    @media screen and (max-width:480px) {
      .preheader .rightColumnContent,
      .footer .rightColumnContent {
        text-align: left !important;
      }
      .preheader .rightColumnContent div,
      .preheader .rightColumnContent span,
      .footer .rightColumnContent div,
      .footer .rightColumnContent span {
        text-align: left !important;
      }
      .preheader .rightColumnContent,
      .preheader .leftColumnContent {
        font-size: 80% !important;
        padding: 5px 0;
      }
      table.wrapper-mobile {
        width: 100% !important;
        table-layout: fixed;
      }
      img.max-width {
        height: auto !important;
        max-width: 100% !important;
      }
      a.bulletproof-button {
        display: block !important;
        width: auto !important;
        font-size: 80%;
        padding-left: 0 !important;
        padding-right: 0 !important;
      }
      .columns {
        width: 100% !important;
      }
      .column {
        display: block !important;
        width: 100% !important;
        padding-left: 0 !important;
        padding-right: 0 !important;
        margin-left: 0 !important;
        margin-right: 0 !important;
      }
      .social-icon-column {
        display: inline-block !important;
      }
    }
  </style>
      <!--user entered Head Start--><!--End Head user entered-->
    </head>
    <body>
      <center class="wrapper" data-link-color="#1188E6" data-body-style="font-size:14px; font-family:arial,helvetica,sans-serif; color:#000000; background-color:#FFFFFF;">
        <div class="webkit">
          <table cellpadding="0" cellspacing="0" border="0" width="100%" class="wrapper" bgcolor="#FFFFFF">
            <tr>
              <td valign="top" bgcolor="#FFFFFF" width="100%">
                <table width="100%" role="content-container" class="outer" align="center" cellpadding="0" cellspacing="0" border="0">
                  <tr>
                    <td width="100%">
                      <table width="100%" cellpadding="0" cellspacing="0" border="0">
                        <tr>
                          <td>
                            <!--[if mso]>
    <center>
    <table><tr><td width="600">
  <![endif]-->
                                    <table width="100%" cellpadding="0" cellspacing="0" border="0" style="width:100%; max-width:600px;" align="center">
                                      <tr>
                                        <td role="modules-container" style="padding:0px 0px 0px 0px; color:#000000; text-align:left;" bgcolor="#FFFFFF" width="100%" align="left"><table class="module preheader preheader-hide" role="module" data-type="preheader" border="0" cellpadding="0" cellspacing="0" width="100%" style="display: none !important; mso-hide: all; visibility: hidden; opacity: 0; color: transparent; height: 0; width: 0;">
    <tr>
      <td role="module-content">
        <p></p>
      </td>
    </tr>
  </table><table class="wrapper" role="module" data-type="image" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed;" data-muid="bebabcb5-7d38-4786-8e8b-a1eb9f0622b3">
    <tbody>
      <tr>
        <td style="font-size:6px; line-height:10px; padding:0px 0px 0px 0px;" valign="top" align="center">
          <img class="max-width" border="0" style="display:block; color:#000000; text-decoration:none; font-family:Helvetica, arial, sans-serif; font-size:16px; width:200px; margin: auto; !important; width:100%; height:auto !important;" width="600" alt="" data-proportionally-constrained="true" data-responsive="true" src="http://cdn.mcauto-images-production.sendgrid.net/cf1e7c82f54f2009/925a610a-30e2-409f-bc33-d0b66f818fcd/3657x917.png">
        </td>
      </tr>
    </tbody>
  </table><table class="module" role="module" data-type="text" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed;" data-muid="5a8ae04b-4641-4a3c-80de-1cf33d071e84">
    <tbody>
      <tr>
        <td style="padding:18px 0px 18px 0px; line-height:22px; text-align:inherit;" height="100%" valign="top" bgcolor="" role="module-content"><div><div style="font-family: inherit">Take a moment to reflect on some of your wins.</div><div></div></div></td>
      </tr>
    </tbody>
  </table>
  <div style="height: 2px; background-color: #a73a36;">&nbsp;</div>
  ${winsContent}
  <div style="height: 2px; background-color: #a73a36;">&nbsp;</div>
  </table>
      </center>
    </body>
  </html>
  `;

  return body;
};

const timestampToDateString = (timestamp: number) => {
  const date = new Date(timestamp);
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  const formattedDate = `${months[date.getMonth()]} ${getOrdinalNum(
    date.getDate()
  )}, ${date.getFullYear()}`;

  return formattedDate;
};

const getOrdinalNum = (n: number) => {
  return (
    n +
    (n > 0
      ? ["th", "st", "nd", "rd"][(n > 3 && n < 21) || n % 10 > 3 ? 0 : n % 10]
      : "")
  );
};
