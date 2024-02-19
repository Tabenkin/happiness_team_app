import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happiness_team_app/models/notification_device.model.dart';

class AppUser {
  String id;
  String email;
  String displayName;
  NotificationDevices notificationDeviceTokens;
  bool allowEmailNotifications;
  bool allowPushNotifications;
  DateTime createdOnTimestamp;
  DateTime lastLoginTimestamp;

  // Generate constructors, toMap and fromMap functions

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.notificationDeviceTokens,
    required this.allowEmailNotifications,
    required this.allowPushNotifications,
    required this.createdOnTimestamp,
    required this.lastLoginTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'notificationDeviceTokens':
          notificationDeviceTokens.map((e) => e.toMap()).toList(),
      'allowEmailNotifications': allowEmailNotifications,
      'allowPushNotifications': allowPushNotifications,
      'createdOnTimestamp': createdOnTimestamp.millisecondsSinceEpoch,
      'lastLoginTimestamp': lastLoginTimestamp.millisecondsSinceEpoch,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      notificationDeviceTokens: map['notificationDeviceTokens'] != null
          ? (map['notificationDeviceTokens'] as List<dynamic>)
              .map((e) => NotificationDevice.fromMap(e))
              .toList()
          : [],
      allowEmailNotifications: map['allowEmailNotifications'],
      allowPushNotifications: map['allowPushNotifications'],
      createdOnTimestamp:
          DateTime.fromMillisecondsSinceEpoch(map['createdOnTimestamp']),
      lastLoginTimestamp:
          DateTime.fromMillisecondsSinceEpoch(map['lastLoginTimestamp']),
    );
  }

  save() async {
    await FirebaseFirestore.instance.doc("/users/$id").set(
          toMap(),
          SetOptions(merge: true),
        );
  }
}
