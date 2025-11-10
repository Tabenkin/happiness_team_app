const { onSchedule } = require("firebase-functions/v2/scheduler");

import { Filter, getFirestore } from "firebase-admin/firestore";
import { getMessaging, Message } from "firebase-admin/messaging";
import { onCall } from "firebase-functions/v2/https";
import { sendEmail } from "./email.helper";
const { defineSecret } = require("firebase-functions/params");

const db = getFirestore();
const messaging = getMessaging();

const sendgridAPIKey = defineSecret("sendgrid_api_key");

export const randomWinRemindersCron = onSchedule(
  {
    schedule: "0 23 * * *",
    secrets: [sendgridAPIKey],
  },
  async () => {
    await sendRandomWinsReminder();
    return true;
  }
);

export const testRandomWinsReminder = onCall(
  { secrets: [sendgridAPIKey] },
  async () => {
    await sendRandomWinsReminder();
    return true;
  }
);

const shouldSendWinReminder = (user: any) => {
  if (user.numWins == undefined || user.numWins == 0) return false;

  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
  const sevenDaysAgoTimestamp = sevenDaysAgo.getTime();

  // If the user has not created a win in the last 7 days then we want to send a win reminder not an add win reminder 25% of the time
  if (user.lastCreatedWinTimestamp < sevenDaysAgoTimestamp) {
    return isThreeToOneOdds() != true;

    // If the user has create a win within the last 7 days then we  wan to send them a reminder of one of their wins 75% of the time
  } else {
    return isThreeToOneOdds();
  }
};

const sendRandomWinsReminder = async () => {
  const BATCH_SIZE = 100; // Process users in batches
  const FCM_BATCH_SIZE = 500; // FCM allows up to 500 messages per batch
  
  let lastDoc = null;
  let totalUsersProcessed = 0;
  let totalNotificationsSent = 0;
  let hasMore = true;

  console.log("Starting random wins reminder process...");

  while (hasMore) {
    try {
      // Query users in batches with pagination
      let query = db
        .collection("/users")
        .where(
          Filter.or(
            Filter.where("allowPushNotifications", "==", true),
            Filter.where("allowEmailNotifications", "==", true)
          )
        )
        .limit(BATCH_SIZE);

      // Add pagination cursor if we have one
      if (lastDoc) {
        query = query.startAfter(lastDoc);
      }

      const usersSnapshot = await query.get();

      if (usersSnapshot.empty) {
        console.log("No more users to process.");
        hasMore = false;
        break;
      }

      console.log(`Processing batch of ${usersSnapshot.docs.length} users...`);

      // Process users in parallel for better performance
      const userProcessingPromises = usersSnapshot.docs.map(async (userDoc) => {
        try {
          const userData = userDoc.data();
          const messages: Message[] = [];

          const sendExistingWinReminder = shouldSendWinReminder(userData);

          let notification = {};
          let data = {};

          // Prepare notification content
          if (sendExistingWinReminder != true) {
            const randomSubject = getRandomAddWinSubject();

            notification = {
              title: randomSubject,
              body: "Add a win.",
            };

            data = {
              event: "addWinReminder",
            };

            // Send email asynchronously if enabled
            if (userData.email && userData.allowEmailNotifications) {
              const body = getAddWinBody();
              // Don't await - let it run in background
              sendEmail(userData.email, randomSubject, body).catch((err) =>
                console.error(`Email error for user ${userDoc.id}:`, err)
              );
            }
          } else {
            const randomWin = await getRandomWinForUser(userDoc.id);
            
            if (!randomWin) {
              console.warn(`No win found for user ${userDoc.id}, skipping...`);
              return { messages: [], userId: userDoc.id };
            }

            const randomSubject = getRandomSubject();
            const windDate = new Date(randomWin.date);
            const winDateString = windDate.toLocaleDateString("en-US", {
              year: "numeric",
              month: "long",
              day: "numeric",
            });

            notification = {
              title: randomSubject,
              body: truncateTo2KBWithEllipsis(
                `${winDateString} - ${randomWin.notes}`
              ),
            };

            data = {
              event: "randomWinReminder",
              winId: randomWin.id,
            };

            // Send email asynchronously if enabled
            if (userData.email && userData.allowEmailNotifications) {
              const body = getEmailBody(randomWin);
              sendEmail(userData.email, randomSubject, body).catch((err) =>
                console.error(`Email error for user ${userDoc.id}:`, err)
              );
            }
          }

          // Create push notification messages
          if (userData.allowPushNotifications && userData.notificationDeviceTokens) {
            for (const device of userData.notificationDeviceTokens) {
              const message: Message = {
                notification: notification,
                data: data,
                token: device.token,
                android: {
                  priority: "high",
                  notification: {
                    sound: "default",
                  },
                },
                apns: {
                  payload: {
                    aps: {
                      sound: "default",
                      badge: 0,
                    },
                  },
                },
              };
              messages.push(message);
            }
          }

          return { messages, userId: userDoc.id };
        } catch (error) {
          console.error(`Error processing user ${userDoc.id}:`, error);
          return { messages: [], userId: userDoc.id };
        }
      });

      // Wait for all users in this batch to be processed
      const results = await Promise.all(userProcessingPromises);
      
      // Collect all messages
      const allMessages = results.flatMap((result) => result.messages);

      console.log(`Generated ${allMessages.length} messages from this batch`);

      // Send messages in FCM batches
      if (allMessages.length > 0) {
        for (let i = 0; i < allMessages.length; i += FCM_BATCH_SIZE) {
          const batch = allMessages.slice(i, i + FCM_BATCH_SIZE);
          
          try {
            const response = await messaging.sendEach(batch);
            totalNotificationsSent += response.successCount;
            
            if (response.failureCount > 0) {
              console.warn(
                `Batch had ${response.failureCount} failures out of ${batch.length} messages`
              );
              
              // Log individual failures for debugging
              response.responses.forEach((resp, idx) => {
                if (!resp.success) {
                  console.error(
                    `Message ${i + idx} failed:`,
                    resp.error?.message || "Unknown error"
                  );
                }
              });
            }
          } catch (error) {
            console.error(`Error sending FCM batch:`, error);
          }
        }
      }

      totalUsersProcessed += usersSnapshot.docs.length;

      // Update pagination cursor
      lastDoc = usersSnapshot.docs[usersSnapshot.docs.length - 1];

      // Check if we should continue
      if (usersSnapshot.docs.length < BATCH_SIZE) {
        hasMore = false;
      }

      console.log(
        `Batch complete. Total users processed: ${totalUsersProcessed}, Total notifications sent: ${totalNotificationsSent}`
      );
    } catch (error) {
      console.error("Error processing batch:", error);
      // Continue to next batch even if this one fails
      hasMore = false;
    }
  }

  console.log(
    `Random wins reminder process complete. Processed ${totalUsersProcessed} users, sent ${totalNotificationsSent} notifications.`
  );
};

const getRandomWinForUser = async (userId: string): Promise<any> => {
  try {
    const winCollectionRef = db.collection(`/users/${userId}/wins`);
    
    // Use count aggregation
    const winAggregateQuery = winCollectionRef.count();
    const winAggregationSnapsht = await winAggregateQuery.get();
    const numWins = winAggregationSnapsht.data().count;

    if (numWins === 0) {
      return null;
    }

    const randomWinIndex = Math.floor(Math.random() * numWins);

    const randomWinQuery = winCollectionRef
      .orderBy("date", "desc")
      .offset(randomWinIndex)
      .limit(1);

    const randomWinSnapshot = await randomWinQuery.get();

    if (randomWinSnapshot.empty) {
      console.warn(`No wins found for user ${userId} despite count=${numWins}`);
      return null;
    }

    const randomWin = randomWinSnapshot.docs[0];

    return {
      id: randomWin.id,
      ...randomWin.data(),
    };
  } catch (error) {
    console.error(`Error fetching random win for user ${userId}:`, error);
    return null;
  }
};

const getRandomSubject = () => {
  const subjects = [
    "You are awesome because …",
    "Remember when you did this?",
    "You rock! 🎸🔥Here’s why",
    "You do amazing things, like this",
    "A blast from your awesome past",
    "You’re the hero of this win",
    "You nailed it! Now you get to relive the moment.",
    "If you did this, what else could you do?",
    "Be in awe of YOU. 😎",
    "Your potential is endless. Look at what you did!",
    "This was so awesome!",
    "Keep shining like this 🌟",
    "What do you think of this win?",
    "Oyah. You did whaaaaa? 🔥",
    "Smile. This was your win.",
    "I can do great things. Like this.",
  ];
  const randomIndex = Math.floor(Math.random() * subjects.length);
  return subjects[randomIndex];
};

const getRandomAddWinSubject = () => {
  const subjects = [
    "What have you won today?",
    "Surely you were awesome today!",
    "The more wins you add, the more you will be rewarded.",
    "Today's victories are waiting for you!",
    "Unlock today's achievements now!",
    "Celebrate your success: Record a win!",
    "Your daily wins boost is here!",
    "How did you triumph today?",
    "Add today’s success story!",
    "Elevate your win streak today!",
    "Your achievements deserve recognition.",
    "Highlight today’s top win!",
    "Boost your rewards with another win!",
    "Victory awaits: Log your wins!",
    "Your success journey continues today.",
    "Make today’s win count!",
    "Your wins bring more rewards!",
    "Every win today is a step forward.",
    "What’s your biggest win today?",
    "Today’s success: Ready for recording.",
    "Celebrate every win, big or small.",
    "Your achievements are your rewards.",
    "Record today’s win and elevate!",
    "Keep your win streak alive!",
    "Your daily dose of victory is here.",
    "Spotlight on today’s achievements.",
    "More wins, more rewards!",
    "Today’s wins are tomorrow’s rewards.",
    "Unlock the power of your achievements.",
    "Let’s celebrate today’s wins together.",
    "Your path to success: Log your wins.",
    "Today's effort, tomorrow's reward.",
    "Achieve more, reward more!",
    "Today's wins, tomorrow's treasures.",
    "Victory is within reach – claim it!",
    "Your wins matter: Make them count.",
    "Elevate your day with every win.",
    "Success is a habit: Build it today.",
    "Every win today shapes your tomorrow.",
    "Celebrate today’s victories, big and small.",
    "Achievements unlocked: Add yours now!",
    "Your daily achievements await recognition.",
    "Make your wins count more today.",
    "Boost your day with a win!",
    "Today's achievements, tomorrow's pride.",
    "Your success stories start with today’s wins.",
    "Let today’s wins inspire your tomorrow.",
    "Capture today’s wins, elevate your journey.",
    "Today’s wins are your stepping stones.",
    "Record your success, boost your journey.",
    "Achieve today, be rewarded tomorrow.",
  ];

  const randomIndex = Math.floor(Math.random() * subjects.length);
  return subjects[randomIndex];
};

const isThreeToOneOdds = () => {
  return Math.random() < 0.75;
};

const truncateTo2KBWithEllipsis = (str: string) => {
  const maxBytes = 2048;
  let encodedStr = new TextEncoder().encode(str);

  if (encodedStr.length <= maxBytes) {
    return str; // Return original string if it's within the limit
  }

  // Ensure there's enough space for the ellipsis
  let limit = maxBytes;

  // Truncate string until its encoded form fits within the limit minus space for "..."
  while (encodedStr.length > limit) {
    str = str.substring(0, str.length - 1);
    encodedStr = new TextEncoder().encode(str + "...");
  }

  return str + "...";
};

const getAddWinBody = () => {
  const randomMessage = getRandomAddWinSubject();

  var content = `
    <p style='font-size:18px; margin-top: 32px; margin-bottom:32px;'>
      ${randomMessage} <a href='https://sfbyw.app.link/PA8LWNSiZHb'>Add a win</a>.
    </p>
  `;

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
           <img class="max-width" border="0" style="display:block; color:#000000; text-decoration:none; font-family:Helvetica, arial, sans-serif; font-size:16px; margin-bottom: 16px !important; margin: auto; !important; height:auto !important;" width="400" alt="" data-proportionally-constrained="true" data-responsive="true" src="http://cdn.mcauto-images-production.sendgrid.net/cf1e7c82f54f2009/925a610a-30e2-409f-bc33-d0b66f818fcd/3657x917.png">
         </td>
       </tr>
     </tbody>
   </table>
   <div style="height: 2px; background-color: #a73a36;">&nbsp;</div>
     ${content}
   <div style="height: 2px; background-color: #a73a36;">&nbsp;</div>
   </table>
       </center>
     </body>
   </html>
   `;

  return body;
};

const getEmailBody = (win: any) => {
  var winsContent = "";

  const dateString = timestampToDateString(win.date);
  var border = "";

  winsContent += `
      
  <table class="module" role="module" data-type="code" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed; ${border}" data-muid="8e041543-6bee-4681-b50f-0bbbd2447ae1">
  <tbody>
    <tr>
      <td height="100%" valign="top" role="module-content"><div style="padding-top: 16px; padding-bottom: 16px;">
<p style="margin-bottom: 8px !important; font-size: 18px;">
${win.notes}
</p>
<p style="font-style: italic;">
${dateString}
</p>
</div></td>
    </tr>
    <tr>
    <td style="padding-bottom:16px;">
    The more wins you add, the more you will be rewarded. <a href='https://sfbyw.app.link/PA8LWNSiZHb'>Add a win in the app</a>.
    </td>
    </tr>
  </tbody>
</table>
      
      `;

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
          <img class="max-width" border="0" style="display:block; color:#000000; text-decoration:none; font-family:Helvetica, arial, sans-serif; font-size:16px; margin-bottom: 16px !important; margin: auto; !important; height:auto !important;" width="400" alt="" data-proportionally-constrained="true" data-responsive="true" src="http://cdn.mcauto-images-production.sendgrid.net/cf1e7c82f54f2009/925a610a-30e2-409f-bc33-d0b66f818fcd/3657x917.png">
        </td>
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
