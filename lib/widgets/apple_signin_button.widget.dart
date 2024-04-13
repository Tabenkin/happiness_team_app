import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

import 'package:happiness_team_app/happiness_theme.dart';

class AppleSigninButton extends StatefulWidget {
  final String label;
  final void Function(bool, User?) onSuccess;
  final void Function() onError;

  const AppleSigninButton({
    required this.label,
    required this.onSuccess,
    required this.onError,
    Key? key,
  }) : super(key: key);

  @override
  State<AppleSigninButton> createState() => _AppleSigninButtonState();
}

class _AppleSigninButtonState extends State<AppleSigninButton> {
  bool _isProcessing = false;

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  _signinWithApple(context) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final fixDisplayNameFromApple = [
        credential.givenName ?? '',
        credential.familyName ?? '',
      ].join(' ').trim();

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
        rawNonce: rawNonce,
      );

      var response =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      var user = response.user;

      if (fixDisplayNameFromApple.isNotEmpty &&
          FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.currentUser
            ?.updateDisplayName(fixDisplayNameFromApple);
        await FirebaseAuth.instance.currentUser?.reload();
        user = FirebaseAuth.instance.currentUser;
      }

      var isNewUser = response.additionalUserInfo?.isNewUser ?? false;

      widget.onSuccess(isNewUser, user);
    } catch (error) {
      print(error);

      setState(() {
        _isProcessing = false;
      });
      widget.onError();
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return MyButton(
      showSpinner: _isProcessing,
      color: MyButtonColor.apple,
      onTap: () => _signinWithApple(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.apple,
            color: theme.onApple,
            size: 18.0,
          ),
          const SizedBox(
            width: 16,
          ),
          MyText(
            "${widget.label} with Apple",
            style: TextStyle(
              color: theme.onApple,
            ),
          ),
        ],
      ),
    );
  }
}
