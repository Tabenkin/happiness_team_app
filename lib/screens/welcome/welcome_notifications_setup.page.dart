import 'package:flutter/material.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/widgets/Base/base_text.widget.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:provider/provider.dart';

class WelcomeNotificationsSetupPage extends StatefulWidget {
  final Function() onNextPage;

  const WelcomeNotificationsSetupPage({
    required this.onNextPage,
    super.key,
  });

  @override
  State<WelcomeNotificationsSetupPage> createState() =>
      _WelcomeNotificationsSetupPageState();
}

class _WelcomeNotificationsSetupPageState
    extends State<WelcomeNotificationsSetupPage> {
  late UserProvider _userProvider;
  bool _isSaving = false;

  @override
  void initState() {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _userProvider.currentUser.allowPushNotifications = true;

    super.initState();
  }

  _next() {
    if (_userProvider.currentUser.allowPushNotifications == true) {
      _requestPushNotificationPermission();
    } else {
      _confirmNotificationPermission();
    }
  }

  _confirmNotificationPermission() async {
    var response = await DialogHelper.showConfirmDialog(
      context,
      title: "Are you sure?",
      message:
          "Woah. Hold on there, partner! Are you sure? This app works best when it can remind you of your awesome wins. 🤠",
    );

    if (response == false) {
      return;
    }

    widget.onNextPage();
  }

  _requestPushNotificationPermission() async {
    setState(() {
      _isSaving = true;
    });
    await _userProvider.requestPushNotificationPermissions();

    setState(() {
      _isSaving = false;
    });

    widget.onNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
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
              "Enable Push Notifications",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 32.0,
            ),
            const MyText(
              "To get the most out of the Happiness Team app, we encourage you to enable push notifications. We want to send you reminders to reflect on your wins.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 32.0,
            ),
            Row(
              children: [
                Switch(
                  value:
                      _userProvider.currentUser.allowPushNotifications == true,
                  onChanged: (_) {
                    setState(
                      () {
                        _userProvider.currentUser.allowPushNotifications =
                            !_userProvider.currentUser.allowPushNotifications;
                      },
                    );
                  },
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Flexible(
                  child: MyText(
                    "Enable Push Notifications",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 32.0,
            ),
            MyButton(
              onTap: _next,
              showSpinner: _isSaving,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BaseText("Next"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
