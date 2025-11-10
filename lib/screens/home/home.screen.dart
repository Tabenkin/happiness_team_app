import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/components/winning_wheel/winning_wheel_animation.widget.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/providers/user.provider.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:happiness_team_app/screens/home/grouped_wins_grid.dart';
import 'package:happiness_team_app/screens/home/grouped_wins_list.widget.dart';
import 'package:happiness_team_app/screens/home/grouping_header.widget.dart';
import 'package:happiness_team_app/screens/home/main_drawer.dart';
import 'package:happiness_team_app/screens/home/monthly_grouped_wins.dart';
import 'package:happiness_team_app/screens/home/push_notification_reminder.widget.dart';
import 'package:happiness_team_app/screens/home/win_progress.dart';
import 'package:happiness_team_app/services/auth.service.dart';
import 'package:happiness_team_app/widgets/Base/base_text.widget.dart';
import 'package:happiness_team_app/widgets/my_animated_add_icon.widget.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliver_tools/sliver_tools.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late WinsProvider _winsProvider;

  StreamSubscription? _randomWinTriggerSubscription;
  StreamSubscription? _addWinTriggerSubscription;

  bool _animateShareButton = false;

  void _addWin() {
    _editWin(
      Win(
        date: DateTime.now(),
        notes: "",
        userId: AuthService.currentUid,
        lastViewedTimestamp: 0,
        images: [],
      ),
    );
  }

  void _editWin(Win win) {
    WinsProvider.showWinForm(context, win);
  }

  late AnimationController _initialTransformController;
  late AnimationController _rotationAnimationController;
  late AnimationController _finalTransformController;

  final List<Color> circleColors = [
    const Color(0xFFA4DDF8), // Light Blue
    const Color(0xFFF7941D), // Orange
    const Color(0xFFA73A36), // Red
    const Color(0xFF0C5363), // Dark Blue
  ];

  bool _shouldMoveForward = true;
  bool _showCross = false;

  _onTriggerAnimation() {
    // If any of the animation controller are active then block the function from running
    if (_initialTransformController.isAnimating ||
        _rotationAnimationController.isAnimating ||
        _finalTransformController.isAnimating) {
      return;
    }

    if (_shouldMoveForward == true) {
      _forward();
      _shouldMoveForward = false;
    } else {
      _reverse();
      _shouldMoveForward = true;
    }
  }

  Win? _win;
  Map<int, int> circleDepths = {0: 1, 1: 1, 2: 1, 3: 2};

  _getRandomWin() {
    var wins = Provider.of<WinsProvider>(context, listen: false).wins.value;
    if (wins.isNotEmpty && _win == null) {
      var randomIndex = Random().nextInt(wins.length);
      _win = wins[randomIndex];
    }
  }

// Assuming this is a class member variable
  int lastRandomIndex =
      2; // Initialize with an invalid index to ensure a color is selected the first time

  void updateCircleDepths(Map circleDepths, List circleColors) {
    int newRandomIndex;
    Random random = Random();

    // Ensure a new color is chosen each time
    do {
      newRandomIndex = random.nextInt(circleColors.length);
    } while (newRandomIndex == lastRandomIndex);

    // Update the lastRandomIndex with the newRandomIndex
    lastRandomIndex = newRandomIndex;

    // Assign depth based on the new random index
    circleDepths.forEach((key, value) {
      circleDepths[key] = (key == newRandomIndex) ? 2 : 1;
    });
  }

  _resetDepths() {
    setState(() {
      circleDepths = {0: 1, 1: 1, 2: 1, 3: 2};
    });
  }

  _forward() {
    _getRandomWin();

    _initialTransformController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rotationAnimationController.forward();
      }
    });

    _rotationAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          updateCircleDepths(circleDepths, circleColors);
        });

        _rotationAnimationController.reverse();
      }

      if (status == AnimationStatus.dismissed) {
        _finalTransformController.forward();
      }
    });

    _finalTransformController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showCross = true;
        });
      }

      _finalTransformController.removeStatusListener((listener) {});
      _rotationAnimationController.removeListener(() {});
      _initialTransformController.removeStatusListener((listener) {});
    });

    _initialTransformController.forward();
  }

  _reverse() {
    _win = null;
    _initialTransformController.reverse();
    _finalTransformController.reverse();

    _initialTransformController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _showCross = false;
        });

        // Ok here is where I can reset the depths I think?
        _resetDepths();
      }

      _finalTransformController.removeStatusListener((listener) {});
    });
  }

  _checkShowNotificaitonReminder() {
    var user = Provider.of<UserProvider>(context, listen: false).currentUser;

    if (user.allowPushNotifications == true) return;
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        DialogHelper.showBottomSheetModal(
          context,
          child: const PushNotificationReminder(),
        );
      },
    );
  }

  @override
  void initState() {
    _initialTransformController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _finalTransformController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _winsProvider = Provider.of<WinsProvider>(context, listen: false);

    _randomWinTriggerSubscription =
        _winsProvider.streamRandomWinTriggers.listen((winId) {
      if (winId == null) return;

      var winIndex =
          _winsProvider.wins.value.indexWhere((element) => element.id == winId);

      if (winIndex < 0) return;

      _win = _winsProvider.wins.value[winIndex];

      _onTriggerAnimation();
      _winsProvider.clearRandomWinEvents();
    });

    _addWinTriggerSubscription =
        _winsProvider.streamAddWinTriggers.listen((event) {
      if (event == null) return;

      Future.delayed(const Duration(milliseconds: 750), () {
        _addWin();
      });
      _winsProvider.clearAddWinEvents();
    });

    _checkShowNotificaitonReminder();

    _animateShareButton =
        Provider.of<UserProvider>(context, listen: false).remindUserToShare;

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndShowRatings());

    super.initState();
  }

  _checkAndShowRatings() {
    var rateMyApp = RateMyApp(
      preferencesPrefix: 'happinessTeamApp_',
      minDays: 7,
      minLaunches: 5,
      googlePlayIdentifier: "com.team.happinessTeamApp",
      appStoreIdentifier: "6477689152",
    );

    rateMyApp.init().then((_) async {
      if (rateMyApp.shouldOpenDialog) {
        await rateMyApp.showRateDialog(
          context,
          title: "Enjoying the app?",
          message: "Please leave a rating!",
          dialogStyle: const DialogStyle(
            titleAlign: TextAlign.center,
            messageAlign: TextAlign.center,
          ),
          ignoreNativeDialog: Platform.isAndroid,
          // starRatingOptions: const StarRatingOptions(),
          onDismissed: () {
            rateMyApp.save().then((_) {});
          },
        );
      }
    });
  }

  _shareApp() async {
    final box = context.findRenderObject() as RenderBox?;

    await Share.share(
      "Hi!\n\nThis is the Happiness Team app I was telling you about. You enter your wins and it reminds you of how awesome you are. And since you are awesome, I thought you would like to check it out.\n\nhttps://sfbyw.app.link/SkTrc6ajZHb",
      subject: "Check out the Happiness App!",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );

    await FirebaseAnalytics.instance.logEvent(name: "share_win");

    setState(() {
      _animateShareButton = false;
    });
  }

  @override
  void dispose() {
    _randomWinTriggerSubscription?.cancel();
    _addWinTriggerSubscription?.cancel();
    _initialTransformController.dispose();
    _rotationAnimationController.dispose();
    _finalTransformController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _winsProvider.wins,
      builder: (context, wins, child) {
        return Scaffold(
          drawer: const MainDrawer(),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (wins.length >= 10)
                WinningWheel(
                  initialTransformController: _initialTransformController,
                  rotationAnimationController: _rotationAnimationController,
                  finalTransformController: _finalTransformController,
                  circleColors: circleColors,
                  circleDepths: circleDepths,
                  win: _win,
                  onAddWin: _addWin,
                  onTriggerAnimation: _onTriggerAnimation,
                ),
              if (wins.length >= 10)
                const SizedBox(
                  height: 16,
                ),
              if (wins.isNotEmpty)
                FloatingActionButton(
                  heroTag: const ValueKey("add-win"),
                  key: GlobalKey(),
                  onPressed: _showCross == true ? _onTriggerAnimation : _addWin,
                  shape: const CircleBorder(),
                  elevation: 1.0,
                  child: MyAnimatedAddIcon(
                    showCross: _showCross == true,
                  ),
                ),
              const SizedBox(
                height: 8.0,
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surface,
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Divider(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(vertical: 16.0),
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/icon.png",
                    width: 30,
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  MyText(
                    "Your Wins",
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              const GroupingHeader(),
              ValueListenableBuilder(
                valueListenable: _winsProvider.selectedTab,
                builder: (context, selectedTab, child) {
                  var groupedWins = _winsProvider.yearMonthDayWins.value;

                  var availableTabs = _winsProvider.tabs.value;

                  if (availableTabs.length > 1) {
                    var selectedTabString = availableTabs[selectedTab];

                    if (selectedTabString == "Years") {
                      groupedWins = _winsProvider.yearWins.value;

                      return GroupedWinsGrid(groupedWins: groupedWins);
                    } else if (selectedTabString == "Months") {
                      groupedWins = _winsProvider.yearMonthWins.value;

                      return MonthlyGroupedWins(
                        yearMonthMap: _winsProvider.yearMonthMap.value,
                        yearMonthWins: groupedWins,
                      );
                    }
                  }

                  return MultiSliver(
                    pushPinnedChildren: true,
                    children: [
                      GroupedWinsList(
                        groupedWins: groupedWins,
                        onEditWin: _editWin,
                      )
                    ],
                  );
                },
              ),
              if (wins.length < 10)
                SliverToBoxAdapter(
                  child: WinProgress(
                    wins: wins,
                  ),
                ),
              if (wins.isEmpty)
                SliverToBoxAdapter(
                  child: Card(
                    margin: const EdgeInsets.all(32.0),
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyText(
                              "Add your first win!",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: MyButton(
                                onTap: _addWin,
                                child: const BaseText("Add Win"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 200),
              ),
            ],
          ),
        );
      },
    );
  }
}
