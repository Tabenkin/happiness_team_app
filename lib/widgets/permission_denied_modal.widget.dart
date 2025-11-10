import 'package:flutter/material.dart';
import 'package:happiness_team_app/widgets/Base/base_text.widget.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDeniedModal extends StatefulWidget {
  final String permission;

  const PermissionDeniedModal({
    required this.permission,
    super.key,
  });

  @override
  State<PermissionDeniedModal> createState() => _PermissionDeniedModalState();
}

class _PermissionDeniedModalState extends State<PermissionDeniedModal> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseText(
                  "Oops!",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                BaseText(
                  "We do not have permission to access your ${widget.permission}.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                BaseText(
                  "Please enable the permission in your device settings.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 16.0,
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: MyButton(
                    child: const BaseText(
                      "Open Settings",
                    ),
                    onTap: () {
                      // Open settings
                      openAppSettings();
                    },
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Center(
                  child: TextButton(
                    child: const BaseText("Dismiss"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
