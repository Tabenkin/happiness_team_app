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
      backgroundColor: Theme.of(context).colorScheme.background,
      surfaceTintColor: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/icon.png",
                    width: 150,
                  ),
                  const SizedBox(
                    height: 32.0,
                  ),
                  MyText(
                    "Tools",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
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
                        MyText("Wins"),
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
                    color: theme.medium,
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
                        MyText("Settings"),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.router.push(const SettingsRoute());
                    },
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  MyButton(
                    textSize: 22.0,
                    filled: false,
                    child: const Row(
                      children: [
                        Icon(Icons.feedback),
                        SizedBox(
                          width: 8.0,
                        ),
                        MyText("Feedback"),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.router.push(const FeedBackRoute());
                    },
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  MyButton(
                    textSize: 22.0,
                    filled: false,
                    child: const Row(
                      children: [
                        Icon(Icons.volunteer_activism),
                        SizedBox(
                          width: 8.0,
                        ),
                        MyText("Support Us"),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.router.push(const ContributeRoute());
                    },
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  MyButton(
                    textSize: 22.0,
                    filled: false,
                    child: const Row(
                      children: [
                        Icon(Icons.event),
                        SizedBox(
                          width: 8.0,
                        ),
                        MyText("Workshops"),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.router.push(const WorkshopsRoute());
                    },
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  MyButton(
                    textSize: 22.0,
                    filled: false,
                    color: MyButtonColor.error,
                    onTap: () {
                      AuthService.logout();
                      context.router.replace(const AuthRoute());
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.logout),
                        const SizedBox(
                          width: 8.0,
                        ),
                        MyText(
                          "Logout",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
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
