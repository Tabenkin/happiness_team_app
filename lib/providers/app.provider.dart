import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:happiness_team_app/services/auth.service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class AppProvider with ChangeNotifier {
  late WinsProvider _winsProvider;
  late UserProvider _userProvider;

  bool _isInitialized = false;
  bool _initilizationError = false;

  final String _appVersion = "v1.2.0";

  AppProvider({
    required WinsProvider winsProvider,
    required UserProvider userProvider,
  }) {
    _userProvider = userProvider;
    _winsProvider = winsProvider;
  }

  bool get isLoggedIn {
    return FirebaseAuth.instance.currentUser != null;
  }

  bool get isInitialized {
    return _isInitialized;
  }

  _onAuthStateChanges(_) async {
    var isPurchasesConfigured = await Purchases.isConfigured;

    if (isPurchasesConfigured != true) {
      await _initPurchases();
    }

    if (isLoggedIn != true) {
      _userProvider.clearUserData();
      await Purchases.logOut();
    } else {
      await Purchases.logIn(AuthService.currentUid);
    }

    notifyListeners();
  }

  Future<void> authStartupTasks() async {
    var isPurchasesConfigured = await Purchases.isConfigured;

    if (isPurchasesConfigured != true) {
      await _initPurchases();
    }

    if (isLoggedIn) {
      await _userProvider.fetchUser();

      await Purchases.logIn(AuthService.currentUid);

      _winsProvider.initializeWins();
      await _userProvider.refreshPushNotifications();
    }
  }

  Future<void> onAppStart() async {
    if (isInitialized == true) {
      return;
    }

    try {
      await _initPurchases();

      await authStartupTasks();

      await AuthService.onAuthStateChanges.first;

      AuthService.onAuthStateChanges.listen(_onAuthStateChanges);

      _initRemoteConfig();

      _isInitialized = true;
    } catch (error) {
      print("Initialization error?");
      print(error);
      _initilizationError = true;
    }

    notifyListeners();
  }

  _initRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: const Duration(minutes: 1),
      ));

      await remoteConfig.fetchAndActivate();
    } catch (error) {
      print("Error fetching remote config");
      print(error);
    }
  }

  _initPurchases() async {
    try {
      if (Platform.isIOS) {
        await Purchases.configure(
          PurchasesConfiguration("appl_YccipzXFyttqqVGAKTUFMaaqHDq"),
        );
      }

      if (Platform.isAndroid) {
        await Purchases.configure(
          PurchasesConfiguration("goog_OcLYzvELbOLOhrnxcNkvvBkZouG"),
        );
      }
    } catch (error) {
      print("Error initializin purchases");
      print(error);
    }
  }

  String get appVersion {
    return _appVersion;
  }
}
