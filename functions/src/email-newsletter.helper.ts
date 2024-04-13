// export const winNotificationEmailsCron = onSchedule(
//   {
//     schedule: "0 0 1 * *",
//     secrets: [sendgridAPIKey],
//   },
//   async () => {
//     await sendWinNotificationEmailsCron();

//     return true;
//   }
// );

// export const testWinNotificationEmailsCron = onCall(
//   { secrets: [sendgridAPIKey] },
//   async () => {
//     await sendWinNotificationEmailsCron();
//     return true;
//   }
// );

// const sendWinNotificationEmailsCron = async () => {
//   const usersSnapshot = await db
//     .collection("/users")
//     .where("allowEmailNotifications", "==", true)
//     .where("numWins", ">=", 10)
//     .get();

//   if (usersSnapshot.docs.length === 0) return;

//   for (const userDoc of usersSnapshot.docs) {
//     const userData = userDoc.data();

//     const email = userData.email;

//     if (!email || email == "") continue;

//     const userWinsSnapshot = await db
//       .collection(`/users/${userDoc.id}/wins`)
//       .get();
//     const userWins = userWinsSnapshot.docs.map((doc) => doc.data());

//     // get 5 random wins from the user's wins
//     const randomWins = userWins
//       .sort(() => Math.random() - Math.random())
//       .slice(0, 5);

//     const subject = "Take a moment to reflect on some of your wins";
//     const body = getEmailBody(randomWins);

//     console.log("Sending email to", email, "with subject", subject);

//     await sendEmail(email, subject, body);
//   }
// };
