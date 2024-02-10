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

## Apple


# Auto Route
flutter packages pub run build_runner watch