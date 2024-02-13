import {
  onDocumentCreated,
  onDocumentDeleted,
} from "firebase-functions/v2/firestore";

import { getFirestore } from "firebase-admin/firestore";

// Initialize Firebase Admin SDK

const db = getFirestore();

export const addWin = onDocumentCreated(
  "/users/{userId}/wins",
  async (event) => {
    await updateWinCount(event.params.userId);
  }
);

export const removeWin = onDocumentDeleted(
  "/users/{userId}/wins",
  async (event) => {
    await updateWinCount(event.params.userId);
  }
);

const updateWinCount = async (userId: string) => {
  const userWinsRef = db.collection(`/users/${userId}/wins`).count();

  // Count the number of wins
  const snapshot = await userWinsRef.get();
  const numWins = snapshot.data().count;

  // Reference to the user document
  const userRef = db.doc(`/users/${userId}`);

  // Update the user's numWins field
  return userRef.update({
    numWins: numWins,
  });
};
