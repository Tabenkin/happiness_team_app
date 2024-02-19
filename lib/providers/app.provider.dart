import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/providers/auth_state.provider.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:happiness_team_app/services/auth.service.dart';

class AppProvider with ChangeNotifier {
  late WinsProvider _winsProvider;
  late UserProvider _userProvider;

  bool _isInitialized = false;
  bool _initilizationError = false;

  final String _appVersion = "v0.0.1";

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
    if (isLoggedIn != true) {
      _userProvider.clearUserData();
    }

    notifyListeners();
  }

  Future<void> authStartupTasks() async {
    if (isLoggedIn) {
      await _userProvider.fetchUser();
      _winsProvider.initializeWins();
    }

    await _userProvider.refreshPushNotifications();
  }

  Future<void> onAppStart() async {
    if (isInitialized == true) {
      return;
    }

    try {
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
        minimumFetchInterval: const Duration(minutes: 60),
      ));

      await remoteConfig.fetchAndActivate();
    } catch (error) {
      print("Error fetching remote config");
      print(error);
    }
  }

  String get appVersion {
    return _appVersion;
  }
}
