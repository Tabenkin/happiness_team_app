import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:happiness_team_app/components/win_form/win_form_container.widget.dart';
import 'package:happiness_team_app/components/win_list/animated_win_list.widget.dart';
import 'package:happiness_team_app/components/winning_wheel/winning_wheel_animation.widget.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/providers/auth_state.provider.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:happiness_team_app/components/win_list/win_card.widget.dart';
import 'package:happiness_team_app/screens/home/win_progress.dart';
import 'package:happiness_team_app/services/auth.service.dart';
import 'package:happiness_team_app/widgets/my_animated_add_icon.widget.dart';
import 'package:happiness_team_app/widgets/my_button.widget.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  void _addWin() {
    _editWin(
      Win(
        date: DateTime.now(),
        notes: "",
        userId: AuthService.currentUid,
        lastViewedTimestamp: 0,
      ),
    );
  }

  void _editWin(Win win) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: WinFormContainer(
              win: win,
            ),
          );
        });
  }

  late AnimationController _initialTransformController;
  late AnimationController _rotationAnimationController;
  late AnimationController _finalTransformController;

  final List<Color> circleColors = [
    const Color(0xFFA4DDF8), // Light Blue
    const Color(0xFFFAAC3E), // Orange
    const Color(0xFFA73A36), // Red
    const Color(0xFF136478), // Dark Blue
  ];

  bool _shouldMoveForward = true;
  bool _showCross = false;

  _onTriggerAnimation() {
    if (_shouldMoveForward == true) {
      _forward();
      _shouldMoveForward = false;
    } else {
      _reverse();
      _shouldMoveForward = true;
    }
  }

  Win? _win;
  Map<int, int> circleDepths = {0: 1, 1: 1, 2: 1, 3: 1};

  _getRandomWin() {
    var wins = Provider.of<WinsProvider>(context, listen: false).wins.value;
    if (wins.isNotEmpty) {
      var randomIndex = Random().nextInt(wins.length);
      _win = wins[randomIndex];
    }
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
          int randomIndex = Random().nextInt(circleColors.length);
          circleDepths.forEach((key, value) {
            circleDepths[key] = (key == randomIndex) ? 2 : 1;
          });
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
    _initialTransformController.reverse();
    _finalTransformController.reverse();

    _initialTransformController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _showCross = false;
        });
      }

      _finalTransformController.removeStatusListener((listener) {});
    });
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

    super.initState();
  }

  @override
  void dispose() {
    _initialTransformController.dispose();
    _rotationAnimationController.dispose();
    _finalTransformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Provider.of<WinsProvider>(context, listen: false).wins,
      builder: (context, wins, child) {
        return Scaffold(
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
                  onTriggerAnimation: _onTriggerAnimation,
                ),
              if (wins.length >= 10)
                const SizedBox(
                  height: 16,
                ),
              if (wins.isNotEmpty)
                FloatingActionButton(
                  onPressed: _showCross == true ? _onTriggerAnimation : _addWin,
                  shape: const CircleBorder(),
                  elevation: 1.0,
                  child: MyAnimatedAddIcon(
                    showCross: _showCross == true,
                  ),
                ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                floating: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(vertical: 16.0),
                  centerTitle: true,
                  title: MyText(
                    "Your Wins",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
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
                                child: const Text("Add Win"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16.0),
                      child: WinCard(
                        win: wins[index],
                        onEdit: () => _editWin(
                          wins[index],
                        ),
                      ),
                    );
                  },
                  childCount: wins.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
