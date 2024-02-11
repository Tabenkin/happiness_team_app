import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:happiness_team_app/widgets/my_text_input.widget.dart';
import 'package:provider/provider.dart';

class WelcomeInfoPage extends StatefulWidget {
  final Function() onNextPage;

  const WelcomeInfoPage({
    required this.onNextPage,
    Key? key,
  }) : super(key: key);

  @override
  State<WelcomeInfoPage> createState() => _WelcomeInfoPageState();
}

class _WelcomeInfoPageState extends State<WelcomeInfoPage> {
  late UserProvider _userProvider;

  bool _isSaving = false;

  String _errorMessage = "";

  _saveUser() async {
    if (_userProvider.currentUser.displayName.isEmpty) {
      setState(() {
        _errorMessage = "Display name is required.";
      });

      return;
    }

    setState(() {
      _isSaving = true;
    });

    await _userProvider.currentUser.save();

    if (_userProvider.currentUser.allowPushNotifications) {
      // ok here we want to enable push notification and do the prompt to get permission to to that.
      _requestPushNotificationPermission();
      return;
    }

    setState(() {
      _isSaving = false;
    });

    widget.onNextPage();
  }

  _requestPushNotificationPermission() async {
    _userProvider.requestPushNotificationPermissions();

    setState(() {
      _isSaving = false;
    });

    widget.onNextPage();
  }

  @override
  void initState() {
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Center(
                child: Image.asset(
                  'assets/images/icon.png',
                  width: 120,
                  alignment: Alignment.center,
                ),
              ),
            ),
            const SizedBox(
              height: 24.0,
            ),
            MyText(
              "Welcome to the Happiness Team!",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 16.0,
            ),
            const MyText(
                "We need a little it of info to finish your account setup."),
            const SizedBox(
              height: 16.0,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: _errorMessage.isEmpty ? 0.0 : 1.0,
                child: Column(
                  children: [
                    Container(
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
                      child: Center(
                        child: Text(
                          _errorMessage,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onError,
                                fontSize: 16.0,
                                height: 1.1,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MyTextInput(
              labelText: "Display Name",
              initialValue: _userProvider.currentUser.displayName,
              onChanged: (value) {
                _userProvider.currentUser.displayName = value;
              },
            ),
            const SizedBox(
              height: 16.0,
            ),
            const MyText("Would you like to receive emails?"),
            const SizedBox(
              height: 8.0,
            ),
            Switch(
              value: _userProvider.currentUser.allowEmailNotifications,
              onChanged: (newValue) {
                setState(
                  () {
                    _userProvider.currentUser.allowEmailNotifications =
                        newValue;
                  },
                );
              },
            ),
            const SizedBox(
              height: 16.0,
            ),
            const Text("Would you like to receive emails?"),
            const SizedBox(
              height: 8.0,
            ),
            Switch(
              value: _userProvider.currentUser.allowPushNotifications,
              onChanged: (newValue) {
                setState(
                  () {
                    _userProvider.currentUser.allowPushNotifications = newValue;
                  },
                );
              },
            ),
            const SizedBox(
              height: 16.0,
            ),
            SizedBox(
              width: double.infinity,
              child: MyButton(
                onTap: _saveUser,
                showSpinner: _isSaving,
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
