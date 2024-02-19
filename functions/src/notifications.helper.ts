const { onSchedule } = require("firebase-functions/v2/scheduler");

import { getFirestore } from "firebase-admin/firestore";
import { getMessaging, Message } from "firebase-admin/messaging";
import { onCall } from "firebase-functions/v2/https";

const db = getFirestore();
const messaging = getMessaging();

export const randomWinRemindersCron = onSchedule(
  "every 7 days",
  async () => {
    await sendRandomWinsReminder();

    return true;
  }
);

export const testRandomWinsReminder = onCall(async () => {
  await sendRandomWinsReminder();
  return true;
});

const sendRandomWinsReminder = async () => {
  // Query /users collection for users who allow push notifications and have more than 10 wins
  const usersSnapshot = await db
    .collection("/users")
    .where("allowPushNotifications", "==", true)
    .get();

  if (usersSnapshot.empty) {
    console.log("No matching users found.");
    return;
  }

  var allMessages = [];

  for (var userDoc of usersSnapshot.docs) {
    var userData = userDoc.data();

    // Create a timestamp representing 7 days ago
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const sevenDaysAgoTimestamp = sevenDaysAgo.getTime();

    var sendNotification = false;
    var notification = {};
    var data = {};

    if (userData.lastCreatedWinTimestamp < sevenDaysAgoTimestamp) {
      notification = {
        title: "Take a moment",
        body: "Don't forget to add your wins to the app.",
      };

      data = {
        event: "addWinReminder",
      };

      sendNotification = true;
    }

    if (
      userData.lastCreatedWinTimestamp > sevenDaysAgoTimestamp &&
      userData.numWins > 10
    ) {
      notification = {
        title: "Take a moment",
        body: "Reflect on one of your wins.",
      };

      data = {
        event: "randomWinReminder",
      };

      sendNotification = true;
    }

    if (sendNotification != true) continue;

    for (var device of userData.notificationDeviceTokens) {
      var token = device.token;
      const message: Message = {
        notification: notification,

        data: data,
        token: token,
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

      allMessages.push(message);
    }
  }

  if (allMessages.length == 0) {
    return;
  }

  try {
    await messaging.sendEach(allMessages);
  } catch (error) {
    console.log("Error?", error);
  }
};
