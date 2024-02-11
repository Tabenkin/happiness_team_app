import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/models/app_user.model.dart';
import 'package:happiness_team_app/providers/app.provider.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';
import 'package:happiness_team_app/widgets/apple_signin_button.widget.dart';
import 'package:happiness_team_app/widgets/google_signin_button.widget.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:happiness_team_app/widgets/my_text_input.widget.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

@RoutePage()
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  String _email = "";
  String _password = "";
  String _confirmPassword = "";
  bool _isLogin = true;
  bool _isProcessing = false;
  String _errorMessage = "";

  late UserProvider _userProvider;
  late AppProvider _appProvider;

  final bool _isLoading = false;

  _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_email.isEmpty == true) {
      setState(() {
        _errorMessage = "You must enter an email...";
      });

      return;
    }

    if (_password.isEmpty == true) {
      setState(() {
        _errorMessage = "You must enter a password...";
      });

      return;
    }

    if (_isLogin != true && _confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "You must confirm your password...";
      });
      return;
    }

    if (_isLogin != true && _confirmPassword != _password) {
      setState(() {
        _errorMessage = "Your passwords do not match....";
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = "";
    });

    try {
      if (_isLogin) {
        var userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        _onSuccess(false, userCredential.user);
      } else {
        var userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        _onSuccess(true, userCredential.user);
      }
    } catch (error) {
      setState(() {
        _isProcessing = false;
        _displayError();
      });
    }
  }

  _newUserSetup(User? user) async {
    var email = '';
    var displayName = '';
    var id = '';

    if (user != null) {
      email = user.email ?? '';
      displayName = user.displayName ?? '';
      id = user.uid;

      for (var providerData in user.providerData) {
        if (providerData.displayName != null) {
          displayName = providerData.displayName ?? '';
        }
      }
    }

    var userDocument = AppUser(
      id: id,
      email: email,
      displayName: displayName,
      notificationDeviceTokens: [],
      allowEmailNotifications: false,
      allowPushNotifications: false,
      lastLoginTimestamp: DateTime.now(),
      createdOnTimestamp: DateTime.now(),
    );

    await userDocument.save();
    await _userProvider.fetchUser();

    _routeToWelcome();
  }

  void _onSuccess(bool isNewUser, User? user) async {
    await Provider.of<AppProvider>(context, listen: false).authStartupTasks();

    if (isNewUser == true) {
      _newUserSetup(user);
    } else {
      await _userProvider.fetchUser();
      _routeToHome();
    }
  }

  void _routeToWelcome() {
    context.router.navigate(const WelcomeRoute());
  }

  void _routeToHome() {
    context.router.navigate(const HomeRoute());
  }

  void _displayError() {
    setState(() {
      _errorMessage =
          "Error! Unable to login. Please check your email and password then try again.";
    });
  }

  _toggleAuthState() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = "";
    });
  }

  @override
  void initState() {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                    'assets/images/logo.png'), // Make sure your logo.png is added to your assets in pubspec.yaml
                const SizedBox(height: 24),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 100),
                    opacity: _errorMessage.isEmpty ? 0.0 : 1.0,
                    child: Container(
                      width: double.infinity,
                      height: _errorMessage.isEmpty ? 0 : null,
                      padding: const EdgeInsets.all(16.0),
                      margin: EdgeInsets.only(
                        top: _errorMessage.isEmpty ? 0 : 24.0,
                        bottom: _errorMessage.isEmpty ? 0 : 16.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Theme.of(context).colorScheme.error,
                      ),
                      child: Text(
                        _errorMessage,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onError,
                              fontSize: 16.0,
                              height: 1.1,
                            ),
                      ),
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      MyTextInput(
                        labelText: "Email",
                        onChanged: (value) {
                          _email = value;
                        },
                        isPassword: false,
                      ),
                      const SizedBox(height: 16),
                      MyTextInput(
                        onChanged: (value) {
                          _password = value;
                        },
                        labelText: "Password",
                        isPassword: true, // Hides the password
                      ),
                      const SizedBox(height: 16),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 50),
                          opacity: _isLogin ? 0 : 1,
                          child: Container(
                            height: _isLogin ? 0 : null,
                            margin:
                                EdgeInsets.only(bottom: _isLogin ? 0 : 16.0),
                            child: MyTextInput(
                              labelText: "Confirm Password",
                              isPassword: true,
                              onChanged: (value) {
                                _confirmPassword = value ?? '';
                              },
                              onSubmitted: (newValue) => _submit(),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              context.router
                                  .navigate(const ResetPasswordRoute());
                            },
                            child: Text(
                              "Forgot Password?",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: MyButton(
                          onTap: _submit,
                          showSpinner: _isProcessing,
                          child: Text(_isLogin ? "Sign In" : "Sign Up"),
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                          ),
                          TextButton(
                            onPressed: _toggleAuthState,
                            child: Text(
                              _isLogin ? "Sign Up" : "Sign In",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 32.0,
                      ),
                      LayoutBuilder(builder: (context, constraints) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth * 0.40,
                              child: Divider(
                                thickness: 1.0,
                                height: 1.0,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Or",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(height: 1.0),
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth * 0.40,
                              child: Divider(
                                thickness: 1.0,
                                height: 1.0,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 32),
                      if (Platform.isIOS)
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: AppleSigninButton(
                                label: _isLogin ? "Sign in" : "Sign Up",
                                onSuccess: _onSuccess,
                                onError: _displayError,
                              ),
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: GoogleSigninButton(
                          label: _isLogin ? "Sign in" : "Sign Up",
                          onSuccess: _onSuccess,
                          onError: _displayError,
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      MyButton(
                        filled: false,
                        onTap: () {
                          context.router.push(const PrivacyPolicyRoute());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyText(
                              "Privacy Policy",
                              textAlign: TextAlign.left,
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: theme.dark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
