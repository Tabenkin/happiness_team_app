import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';
import 'package:happiness_team_app/services/auth.service.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:share_plus/share_plus.dart';

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

    bool enableContributions =
        FirebaseRemoteConfig.instance.getBool("enable_contributions");

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
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
                    height: 8.0,
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
                    height: 8.0,
                  ),
                  if (enableContributions)
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
                  if (enableContributions)
                    const SizedBox(
                      height: 8.0,
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
                    height: 8.0,
                  ),
                  MyButton(
                    textSize: 22.0,
                    filled: false,
                    child: Row(
                      children: [
                        Icon(
                          Platform.isIOS ? Icons.ios_share : Icons.share,
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        const MyText("Share the App"),
                      ],
                    ),
                    onTap: () async {
                      final box = context.findRenderObject() as RenderBox?;

                      await Share.share(
                        "Hi!\n\nThis is the Happiness Team app I was telling you about. You enter your wins and it reminds you of how awesome you are. And since you are awesome, I thought you would like to check it out.\n\nhttps://sfbyw.app.link/SkTrc6ajZHb",
                        subject: "Check out the Happiness App!",
                        sharePositionOrigin:
                            box!.localToGlobal(Offset.zero) & box.size,
                      );

                      await FirebaseAnalytics.instance
                          .logEvent(name: "share_app");
                    },
                  ),
                  const SizedBox(
                    height: 8.0,
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
