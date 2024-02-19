import {
  onDocumentCreated,
  onDocumentDeleted,
} from "firebase-functions/v2/firestore";

import { getFirestore } from "firebase-admin/firestore";

// Initialize Firebase Admin SDK

const db = getFirestore();

export const addWin = onDocumentCreated(
  "/users/{userId}/wins/{winId}",
  async (event) => {
    await updateWinCount(event.params.userId, true);
  }
);

export const removeWin = onDocumentDeleted(
  "/users/{userId}/wins/{winId}",
  async (event) => {
    await updateWinCount(event.params.userId, false);
  }
);

const updateWinCount = async (
  userId: string,
  setLastCreatedWinTime: boolean
) => {
  const userWinsRef = db.collection(`/users/${userId}/wins`).count();

  // Count the number of wins
  const snapshot = await userWinsRef.get();
  const numWins = snapshot.data().count;

  // Reference to the user document
  const userRef = db.doc(`/users/${userId}`);

  var userData = {
    numWins: numWins,
  } as any;

  if (setLastCreatedWinTime) {
    userData.lastCreatedWinTimestamp = new Date().getTime();
  }

  // Update the user's numWins field
  return userRef.update(userData);
};
