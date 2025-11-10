import 'package:auto_route/auto_route.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/widgets/Base/base_text.widget.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text_input.widget.dart';
import 'package:happiness_team_app/widgets/my_textarea.widget.dart';
import 'package:provider/provider.dart';

@RoutePage()
class FeedBackScreen extends StatefulWidget {
  const FeedBackScreen({
    super.key,
  });

  @override
  State<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  final bool _isSendingFeedback = false;

  String _feedback = "";
  String _email = "";

  onShareFeedback() async {
    if (_email.isEmpty) {
      DialogHelper.showSimpleErrorToast(
          context, "Oops! You forgot to enter your email.");
      return;
    }

    if (_feedback.isEmpty) {
      DialogHelper.showSimpleErrorToast(
          context, "Oops! You forgot to enter your feedback.");
      return;
    }

    await FirebaseFunctions.instance.httpsCallable("sendFeedback")({
      'fromEmail': _email,
      'feedback': _feedback,
    });

    _showFeedbackSentDialog();
  }

  _showFeedbackSentDialog() {
    DialogHelper.showSimpleSuccessToast(
      context,
      "Thank you for your feedback!",
    );

    Navigator.of(context).pop();
  }

  late UserProvider _userProvider;

  @override
  void initState() {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _email = _userProvider.user?.email ?? "";
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
        title: const BaseText('Feedback'),
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
            children: [
              BaseText(
                "Have something to say? We love feedback.",
                style: Theme.of(context).textTheme.headlineMedium,
                maxTextScale: 1.0,
              ),
              const SizedBox(
                height: 16.0,
              ),
              MyTextInput(
                labelText: "",
                placeholder: "Enter Email...",
                initialValue: _email,
                onChanged: (newValue) {
                  _email = newValue;
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              MyTextArea(
                labelText: "",
                placeholder: "Enter Feedback...",
                onChanged: (newValue) {
                  _feedback = newValue;
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              SizedBox(
                width: double.infinity,
                child: MyButton(
                  onTap: onShareFeedback,
                  showSpinner: _isSendingFeedback,
                  child: const BaseText("Submit Feedback"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
