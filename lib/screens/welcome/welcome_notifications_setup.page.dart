import 'package:flutter/material.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:provider/provider.dart';

class WelcomeNotificationsSetupPage extends StatefulWidget {
  final Function() onNextPage;

  const WelcomeNotificationsSetupPage({
    required this.onNextPage,
    Key? key,
  }) : super(key: key);

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

    super.initState();
  }

  _requestPushNotificationPermission() async {
    setState(() {
      _isSaving = true;
    });
    _userProvider.requestPushNotificationPermissions();

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
            MyButton(
              onTap: _requestPushNotificationPermission,
              showSpinner: _isSaving,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notification_add),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text("Enable Push Notifications"),
                ],
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            MyButton(
              filled: false,
              onTap: widget.onNextPage,
              child: const Text("skip"),
            ),
          ],
        ),
      ),
    );
  }
}
