import { getFirestore } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";

import { onCall } from "firebase-functions/v2/https";
const db = getFirestore();
const auth = getAuth();

export const onDeleteAccount = onCall(async (event) => {
  const uid = event.auth?.uid;

  if (!uid) {
    throw new Error("Unauthorized");
  }

  // Delete user data
  await db.collection("users").doc(uid).delete();
  await auth.deleteUser(uid);
});
