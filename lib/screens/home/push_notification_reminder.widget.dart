import 'package:flutter/material.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:provider/provider.dart';

class PushNotificationReminder extends StatefulWidget {
  const PushNotificationReminder({
    Key? key,
  }) : super(key: key);

  @override
  State<PushNotificationReminder> createState() =>
      _PushNotificationReminderState();
}

class _PushNotificationReminderState extends State<PushNotificationReminder> {
  late UserProvider _userProvider;

  bool _isSaving = false;

  _requestPushNotificationPermission() async {
    setState(() {
      _isSaving = true;
    });
    await _userProvider.requestPushNotificationPermissions();

    setState(() {
      _isSaving = false;
    });

    _showSuccessToast();

    _dismiss();
  }

  _showSuccessToast() {
    DialogHelper.showSimpleSuccessToast(context, "Push notifications enabled!");
  }

  _dismiss() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Divider(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "This app is sad because you haven’t enabled push notifications. Turn them on?",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
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
            ],
          ),
        ),
      ),
    );
  }
}
