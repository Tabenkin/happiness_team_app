import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_route/auto_route.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';

class AuthStateListener extends StatefulWidget {
  final Widget child;

  const AuthStateListener({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends State<AuthStateListener> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      print("Auth state is changing?");

      if (user == null) {
        context.router.replace(const AuthRoute());
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
