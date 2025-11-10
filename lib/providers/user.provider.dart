import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/helpers/functions.helpers.dart';
import 'package:happiness_team_app/models/app_user.model.dart';
import 'package:happiness_team_app/models/notification_device.model.dart';
import 'package:happiness_team_app/services/auth.service.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;
  String? _deviceId;

  static Stream<AppUser> get streamUserDoc {
    var uid = AuthService.currentUid;
    return FirebaseFirestore.instance.doc("/users/$uid").snapshots().map(
          (snapshot) => AppUser.fromMap(fromSnapshot(snapshot)),
        );
  }

  StreamSubscription<AppUser>? _userSubscription;
  StreamSubscription<String>? _deviceTokenSubscription;

  Future<void> fetchUser() async {
    var uid = AuthService.currentUid;
    var userRef = FirebaseFirestore.instance.doc("/users/$uid");
    var snapshot = await userRef.get();

    if (snapshot.exists == true) {
      _user = AppUser.fromMap(fromSnapshot(snapshot));
    } else {
      _user = AppUser(
        id: uid,
        email: '',
        displayName: '',
        notificationDeviceTokens: [],
        allowEmailNotifications: false,
        allowPushNotifications: false,
        createdOnTimestamp: DateTime.now(),
        lastLoginTimestamp: DateTime.now(),
      );

      await _user?.save();
    }

    await initializeUserClaims();

    _deviceId = await _getId();

    if (_userSubscription != null) {
      _userSubscription!.cancel();
    }

    _userSubscription = userRef.snapshots().map((event) {
      return AppUser.fromMap(fromSnapshot(event));
    }).listen(_onUserUpdated);

    _user!.lastLoginTimestamp = DateTime.now();
    await _user!.save();

    if (_deviceTokenSubscription != null) {
      _deviceTokenSubscription!.cancel();
    }

    _deviceTokenSubscription =
        FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await assignDeviceToken(token);
    });
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return '${androidDeviceInfo.model}:${androidDeviceInfo.id}'; // unique ID on Android
    }
    return null;
  }

  // After some trial an error, I discovered that if we don't request permission and call getToken on every app start, then push notifications stop working
  // After the user taps the first one.
  Future<void> refreshPushNotifications() async {
    var user = _user;

    if (user == null) return;

    if (user.allowPushNotifications != true) return;

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
    );

    var token = await FirebaseMessaging.instance.getToken();

    var apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print("apns token? $apnsToken");

    print("refreshed token? $token");

    if (token == null) return;

    assignDeviceToken(token);
  }

  Future<void> requestPushNotificationPermissions() async {
    if (_user == null) return;

    _user!.allowPushNotifications = true;

    await _user!.save();

    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get the token each time the application launches
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await assignDeviceToken(token);
      }
    }
  }

  Future<void> assignDeviceToken(String token) async {
    var user = _user;
    var deviceId = _deviceId;

    if (user == null) return;

    if (deviceId == null) return;

    var matchingDeviceIndex = user.notificationDeviceTokens
        .indexWhere((element) => element.deviceId == deviceId);

    if (matchingDeviceIndex < 0) {
      user.notificationDeviceTokens.add(NotificationDevice(
        deviceId: deviceId,
        token: token,
      ));
      await user.save();
    } else {
      user.notificationDeviceTokens[matchingDeviceIndex].token = token;
      await user.save();
    }
  }

  _onUserUpdated(AppUser user) {
    _user = user;
  }

  Future<void> initializeUserClaims() async {
    var idTokenResult =
        await FirebaseAuth.instance.currentUser!.getIdTokenResult(true);
  }

  Future<AppUser> getCurrentUserDocument() async {
    if (_user != null) {
      return _user!;
    }

    await fetchUser();

    return getCurrentUserDocument();
  }

  AppUser get currentUser {
    return _user!;
  }

  String? get deviceId {
    return _deviceId;
  }

  AppUser? get user {
    return _user;
  }

  bool get remindUserToShare {
    var user = _user;

    if (user == null) return true;

    var lastAskedToShareTimestamp = user.lastAskedToShareTimestamp;

    if (lastAskedToShareTimestamp == null) {
      user.lastAskedToShareTimestamp = DateTime.now();
      user.save();

      return true;
    }

    // Generate an umber between 5 and 8
    Random random = Random();
    var days = 5 + random.nextInt((8 - 5) + 1);

    var isBefore = lastAskedToShareTimestamp
        .isBefore(DateTime.now().subtract(Duration(days: days)));

    if (isBefore) {
      user.lastAskedToShareTimestamp = DateTime.now();
      user.save();

      return true;
    }

    return false;
  }

  clearUserData() {
    _user = null;
  }
}
