import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';
import 'package:happiness_team_app/services/auth.service.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/images/icon.png",
                    width: 150,
                  ),
                  const SizedBox(
                    height: 32.0,
                  ),
                  Text(
                    "Tools",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  MyButton(
                    filled: false,
                    textSize: 22.0,
                    child: const Row(
                      children: [
                        Icon(Icons.emoji_events),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text("Wins"),
                      ],
                    ),
                    onTap: () {
                      // Close the drawer
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Divider(
                    color: theme.light,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  MyButton(
                    textSize: 22.0,
                    filled: false,
                    child: const Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text("Settings"),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.router.push(const SettingsRoute());
                    },
                  ),
                  MyButton(
                    textSize: 22.0,
                    filled: false,
                    color: MyButtonColor.error,
                    onTap: () {
                      AuthService.logout();
                      context.router.replace(const AuthRoute());
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text("Logout"),
                      ],
                    ),
                  ),
                  const SizedBox()
                ],
              ),
              Column(
                children: [
                  MyButton(
                    filled: false,
                    onTap: () {
                      context.router.push(const PrivacyPolicyRoute());
                    },
                    child: Row(
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
