/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { initializeApp } from "firebase-admin/app";
initializeApp();

import * as WinHelpers from "./wins.helper";

export const addWin = WinHelpers.addWin;
export const removeWin = WinHelpers.removeWin;

import * as NotificationHelpers from "./notifications.helper";

export const randomWinRemindersCron =
  NotificationHelpers.randomWinRemindersCron;
// export const testRandomWinsReminder =
//   NotificationHelpers.testRandomWinsReminder;

import * as FeedbackHelpers from "./feedback.helper";
export const sendFeedback = FeedbackHelpers.sendFeedback;

import * as AccountManagementHelpers from "./account-management.helper";
export const onDeleteAccount = AccountManagementHelpers.onDeleteAccount;
