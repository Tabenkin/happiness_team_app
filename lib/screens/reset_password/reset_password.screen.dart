import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text_input.widget.dart';
import 'package:happiness_team_app/happiness_theme.dart';

@RoutePage()
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = "";
  bool _isProcessing = false;
  String _errorMessage = "";
  String _successMessage = "";

  _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = "";
      _successMessage = "";
    });

    if (_email.isEmpty == true) {
      setState(() {
        _errorMessage = "You must enter an email...";
      });

      return;
    }

    setState(() {
      _isProcessing = true;
    });

try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
    } catch (error) {}

    setState(() {
      _isProcessing = false;
      _successMessage = "Password reset email sent.";
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: _successMessage.isEmpty ? 0.0 : 1.0,
                  child: Container(
                    width: double.infinity,
                    height: _successMessage.isEmpty ? 0 : null,
                    padding: const EdgeInsets.all(16.0),
                    margin: EdgeInsets.only(
                      top: _successMessage.isEmpty ? 0 : 24.0,
                      bottom: _successMessage.isEmpty ? 0 : 16.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: theme.success,
                    ),
                    child: Text(
                      _successMessage,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: theme.onSuccess,
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
                    const SizedBox(
                      height: 16.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: MyButton(
                        onTap: _submit,
                        showSpinner: _isProcessing,
                        child: const Text("Reset Password"),
                      ),
                    ),
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
