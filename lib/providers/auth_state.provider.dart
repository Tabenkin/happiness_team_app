import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';

class AuthStateProvider with ChangeNotifier {
  bool _isInitialized = false;

  bool get isLoggedIn {
    return FirebaseAuth.instance.currentUser != null;
  }

  initializeListeners() async {
    if (_isInitialized == true) {
      return;
    }

    print("Initializingauth state changes");

    FirebaseAuth.instance.authStateChanges().listen((user) {
      print("Notifying listeners of auth state changes...");
      notifyListeners();
    });

    _isInitialized = true;
  }

  logout(BuildContext context) {
    try {
      FirebaseAuth.instance.signOut();
    } catch (error) {}

    context.router.replace(const AuthRoute());
  }
}
