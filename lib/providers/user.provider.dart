import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/helpers/functions.helpers.dart';
import 'package:happiness_team_app/models/app_user.model.dart';
import 'package:happiness_team_app/models/notification_device.model.dart';
import 'package:happiness_team_app/services/auth.service.dart';
import 'package:platform_device_id/platform_device_id.dart';

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

    _deviceId = await PlatformDeviceId.getDeviceId ?? '';

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


  // After some trial an error, I discovered that if we don't request permission and call getToken on every app start, then push notifications stop working
  // After the user taps the first one.
  Future<void> refreshPushNotifications() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
    );

    await FirebaseMessaging.instance.getToken();
  }

  Future<void> requestPushNotificationPermissions() async {
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

  clearUserData() {
    _user = null;
  }
}
