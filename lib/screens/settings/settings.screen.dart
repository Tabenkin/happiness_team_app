import 'package:auto_route/auto_route.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/providers/auth_state.provider.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/widgets/Base/base_button.widget.dart';
import 'package:happiness_team_app/widgets/Base/base_text.widget.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:happiness_team_app/widgets/my_text_input.widget.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

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

  var _isDeleting = false;

  _deleteAccount() async {
    var resposne = await DialogHelper.showConfirmDialog(context,
        title: "Are you sure?",
        message:
            "Are you sure you would like to delete your account? This cannot be undone.");

    if (resposne == true) {
      try {
        setState(() {
          _isDeleting = true;
        });

        await FirebaseFunctions.instance.httpsCallable("onDeleteAccount")();
        _logout();
      } catch (error) {
        print("Some error? $error");

        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  _logout() {
    Provider.of<AuthStateProvider>(context, listen: false).logout(context);
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
        title: const BaseText('Settings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Divider(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
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
                  const BaseText("Enable email notifications?"),
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
                  const MyText("Allow push notifiations?"),
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
                child: BaseButton(
                  width: double.infinity,
                  onPressed: _saveUser,
                  showSpinner: _isSaving,
                  child: const BaseText("Save"),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              SizedBox(
                width: double.infinity,
                child: MyButton(
                  showSpinner: _isDeleting,
                  onTap: _deleteAccount,
                  color: MyButtonColor.error,
                  filled: false,
                  child: MyText(
                    "Delete Account",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
