import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/happiness_theme.dart';

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
              clientId:
                  "274381462997-5ikvkn9igit2our3cg7octfp80sljqmn.apps.googleusercontent.com")
          .signIn();

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
      setState(() {
        _isProcessing = false;
      });

      print("Error google signing $error");

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
          Text("${widget.label} with Google"),
        ],
      ),
    );
  }
}
