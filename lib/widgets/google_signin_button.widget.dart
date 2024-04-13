import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';

class GoogleSigninButton extends StatefulWidget {
  final String label;
  final void Function(bool, User?) onSuccess;
  final void Function() onError;

  const GoogleSigninButton({
    required this.label,
    required this.onSuccess,
    required this.onError,
    Key? key,
  }) : super(key: key);

  @override
  State<GoogleSigninButton> createState() => _GoogleSigninButtonState();
}

class _GoogleSigninButtonState extends State<GoogleSigninButton> {
  bool _isProcessing = false;

  _signinWithGoogle(BuildContext context) async {
    try {
      setState(() {
        _isProcessing = true;
      });

      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: Platform.isAndroid ? "274381462997-a7f2gseuup3ta6033fkbokgove2umto2.apps.googleusercontent.com" : null,
      ).signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth?.accessToken == null || googleAuth?.idToken == null) {
        throw Exception("Google signin failed");
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      var response =
          await FirebaseAuth.instance.signInWithCredential(credential);
      var isNewUser = response.additionalUserInfo?.isNewUser ?? false;

      widget.onSuccess(isNewUser, response.user);
    } catch (error) {
      print("Error signing in with Google: $error");
      print(error);

      setState(() {
        _isProcessing = false;
      });

      widget.onError();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return MyButton(
      showSpinner: _isProcessing,
      filled: true,
      color: MyButtonColor.google,
      onTap: () => _signinWithGoogle(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.google,
            color: theme.onGoogle,
            size: 18.0,
          ),
          const SizedBox(
            width: 16,
          ),
          MyText(
            "${widget.label} with Google",
            style: TextStyle(
              color: theme.onGoogle,
            ),
          ),
        ],
      ),
    );
  }
}
