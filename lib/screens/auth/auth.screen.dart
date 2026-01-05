import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/components/win_list/win_content.widget.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/models/app_user.model.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/providers/app.provider.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';
import 'package:happiness_team_app/services/wins.service.dart';
import 'package:happiness_team_app/widgets/apple_signin_button.widget.dart';
import 'package:happiness_team_app/widgets/google_signin_button.widget.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:happiness_team_app/widgets/my_text_input.widget.dart';
import 'package:provider/provider.dart';

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
        var userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        _onSuccess(false, userCredential.user);
      } else {
        var userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
      allowEmailNotifications: true,
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

  StreamSubscription? _viewSharedWinTriggerSubscription;

  @override
  void initState() {
    print("AuthScreen initState");
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);


    _viewSharedWinTriggerSubscription?.cancel();

    _viewSharedWinTriggerSubscription = Provider.of<WinsProvider>(context, listen: false)
        .streamViewSharedWinTriggers
        .listen((winId) async {
      if (winId == null) return;

      // Consume the event immediately so it doesn't trigger again on rebuilds
      Provider.of<WinsProvider>(context, listen: false).clearViewSharedWinEvents();

      // Await 100 ms
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      DialogHelper.showBottomSheetModal(
        context,
        child: FutureBuilder(
            future: WinsService.fetchSharedWin(winId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var win = snapshot.data as Win;

              return WinContent(win: win);
            }),
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    _viewSharedWinTriggerSubscription?.cancel();
    super.dispose();
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
                      child: MyText(
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
                            margin: EdgeInsets.only(bottom: _isLogin ? 0 : 16.0),
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
                              context.router.navigate(const ResetPasswordRoute());
                            },
                            child: MyText(
                              "Forgot Password?",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Theme.of(context).colorScheme.primary),
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
                          child: MyText(
                            _isLogin ? "Sign In" : "Sign Up",
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const MyText(
                            "Don't have an account?",
                          ),
                          TextButton(
                            onPressed: _toggleAuthState,
                            child: MyText(
                              _isLogin ? "Sign Up" : "Sign In",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Theme.of(context).colorScheme.primary),
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
                              child: MyText(
                                "Or",
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.0),
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
