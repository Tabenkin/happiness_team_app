# happiness_team_app

# Apple

## Identifiers

1. In developer.apple.com, navigate to **Identifiers** and click the **+** button
2. Choose **App IDs**
3. Choose **App**
4. For the **Description** enter **Happiness Team App**
5. For the **Bundle ID** enter **com.team.happinessTeamApp**
6. Enable the following capabilities
   - Push Notifications
   - Sign In with Apple
     - Copy **https://happinessteamwinningwheel.firebaseapp.com/__/auth/handler** as the callback url
7. Click **Continue** then **Register**

## Signin With Apple

1. In developer.apple.com, navigate to **Identifiers** and click the **+** button
2. Choose **Services IDs**
3. In the **Description** enter **Happiness Team - Apple Signin**
4. In the **Identifier** enter **com.team.happinessTeamApp.appleSignin**
5. Click **Continue** then **Register**
6. Click the newly created service Id to enable it
7. Enable **Sign In With Apple**
8. Click **Configure**
9. Select **Happiness Team App** as the **Primary App ID**

### Create a Key

1. In developer.apple.com, navigate to **Keys** and click the **+** button
2. For the key name enter **Happiness Team App**
3. Enable **Sign in with Apple**
4. Click **Configure** and choose the Happiness Team App as the primary app
5. Click **Continue**
6. Download the key and keep the .p8 file somewhere safe
7. Navigate to Firebase console and navigate to the **Authentication** tool
8. Choose **Sign In Providers** and edit the Apple provider
9. Enter the **Service Id** created in the previous step
10. Expand the OAuth code flow configration and enter the Key id and contents of the .p8 file then save

### Signing & Capabilities

1. In xCode, click **Runner**
2. Navigate to **\*Signing & Capabilities**
3. Click **+Capability** and select **Push Notifications**, **Sign in with Apple** and **Background Modes**
4. Configure your Firebase project with APNs Authentication Key:
    - Go back to the Firebase Console, navigate to the "Project settings" (the gear icon next to your project name), and select the "Cloud Messaging" tab.
    - Under the "iOS app configuration" section, you'll need to upload your APNs Authentication Key. This is required for Firebase to communicate with APNs on behalf of your app.
    - To get the APNs Authentication Key, you need to go to the Apple Developer Member Center, navigate to "Certificates, Identifiers & Profiles" > "Keys", and create a key with the "Apple Push Notifications service (APNs)" enabled. Download this key and upload it to Firebase.

# Push Notifications Setup

## General

# Android

This article is helpful for android specific setup:
https://docs.flutter.dev/deployment/android

1. Run this command to generate the upload-keystore
- Note this should only need to be done once

```
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
        -keysize 2048 -validity 10000 -alias upload

```

2. Keystore credentials and details are located in /android/key.properties


# Auto Route
flutter packages pub run build_runner watch

or 

flutter packages pub run build_runner build                    

# Branch.io Configuration

1. In the branch.io configuration page, the Apple App Prefix is Joseph's TeamId and should be replaced if the app is transferred to another developer.

2. TODO: Replace the app store listing with Happiness Team app (currently set to Read With Me for basic functionality)

# Google Signin Android

You need to register your debug and release SHA-1 and SHA-256 values in the Firebase Android project settings. Here's how you can obtain those using Android Studio:

1. Open Android Studio and load your project.
2. In the right sidebar, you will find the Gradle tab. Click on it.
3. You'll see a panel open with the structure of your project's Gradle scripts.
4. Navigate through the list following this path: YourProject -> Tasks -> android -> signingReport.
5. Double click on signingReport. This will run the task.
6. After a while, you'll see the results in the Run tab located at the bottom of Android Studio.
7. Copy the SHA1 and SHA-256 values to the firebase console
- Navigate to Project Settings
- Select the android app
- Click "Add fingerprint"


keytool -list -v -alias upload -keystore ./upload-keystore.jks

A1fw^5pnU&RJBso!