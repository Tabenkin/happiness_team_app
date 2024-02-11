import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text_input.widget.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserProvider _userProvider;

  bool _isSaving = false;

  _saveUser() async {
    setState(() {
      _isSaving = true;
    });

    await _userProvider.user?.save();

    if (_userProvider.user?.allowPushNotifications ?? false) {
      await _userProvider.requestPushNotificationPermissions();
    }

    setState(() {
      _isSaving = false;
    });

    _onSavedSuccess();
  }

  _onSavedSuccess() {
    DialogHelper.showSimpleSuccessToast(context, "Settings saved!");
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                height: 16.0,
              ),
              MyTextInput(
                labelText: "Email",
                initialValue: _userProvider.user?.email,
                onChanged: (newValue) {
                  _userProvider.user?.email = newValue;
                },
              ),
              const SizedBox(
                height: 32.0,
              ),
              MyTextInput(
                labelText: "Display Name",
                initialValue: _userProvider.user?.displayName,
                onChanged: (newValue) {
                  _userProvider.user?.displayName = newValue;
                },
              ),
              const SizedBox(
                height: 32.0,
              ),
              // Toggle with labe "Enable email notifications?"
              Row(
                children: [
                  const Text("Enable email notifications?"),
                  const Spacer(),
                  Switch(
                    value: _userProvider.user?.allowEmailNotifications ?? false,
                    onChanged: (newValue) {
                      setState(() {
                        _userProvider.user?.allowEmailNotifications = newValue;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 32.0,
              ),
              //Toggle with label Allow push notifiations?
              Row(
                children: [
                  const Text("Allow push notifiations?"),
                  const Spacer(),
                  Switch(
                    value: _userProvider.user?.allowPushNotifications ?? false,
                    onChanged: (newValue) {
                      setState(() {
                        _userProvider.user?.allowPushNotifications = newValue;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 32.0,
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
      ),
    );
  }
}
