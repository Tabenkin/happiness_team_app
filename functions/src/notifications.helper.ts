const { onSchedule } = require("firebase-functions/v2/scheduler");

import { getFirestore } from "firebase-admin/firestore";
import { getMessaging, Message } from "firebase-admin/messaging";

const db = getFirestore();
const messaging = getMessaging();

export const randomPinRemindersCron = onSchedule(
  "every 5 minutes",
  async () => {
    // Query /users collection for users who allow push notifications and have more than 10 wins
    const usersSnapshot = await db
      .collection("/users")
      .where("allowPushNotifications", "==", true)
      .where("numWins", ">", 10)
      .get();

    if (usersSnapshot.empty) {
      console.log("No matching users found.");
      return null;
    }

    const devices = usersSnapshot.docs.map((userDoc) => {
      const notificationDevices = userDoc
        .data()
        .notificationDeviceTokens.map((a: any) => a.token);

      return notificationDevices;
    });

    //flatten devices
    const allDevices = devices.flat();

    var allPromises = [];

    // Send a message to the devices
    for (var device of allDevices) {
      const message: Message = {
        notification: {
          title: "You're on a roll!",
          body: "Keep up the good work!",
        },
        token: device,
      };

      try {
        allPromises.push(messaging.send(message));
        console.log("Message sent successfully.");
      } catch (error) {
        console.error("Error sending message:", error);
      }
    }

    return Promise.all(allPromises);
  }
);
