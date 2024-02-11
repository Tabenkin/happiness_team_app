import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/models/win.model.dart';
import 'package:happiness_team_app/providers/wins.provider.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:provider/provider.dart';

class WinningWheel extends StatefulWidget {
  final AnimationController initialTransformController;
  final AnimationController rotationAnimationController;
  final AnimationController finalTransformController;
  final List<Color> circleColors;
  final Map<int, int> circleDepths;
  final Win? win;
  final Function() onTriggerAnimation;

  const WinningWheel({
    required this.initialTransformController,
    required this.rotationAnimationController,
    required this.finalTransformController,
    required this.circleColors,
    required this.circleDepths,
    this.win,
    required this.onTriggerAnimation,
    super.key,
  });

  @override
  WinningWheelState createState() => WinningWheelState();
}

class WinningWheelState extends State<WinningWheel> {
  late Animation<double> _initialTransformAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _yOffsetAnimation;
  late Animation<double> _finalTransfomAnimatino;
  List<Animation<Offset>> _positionAnimations = [];

  @override
  void initState() {
    super.initState();

    _initialTransformAnimation = CurvedAnimation(
      parent: widget.initialTransformController,
      curve: Curves.elasticOut,
    );

    _rotationAnimation = Tween(begin: 0.0, end: 4.1 * pi).animate(
      CurvedAnimation(
        parent: widget.rotationAnimationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _yOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -75),
    ).animate(
      CurvedAnimation(
        parent: widget.rotationAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _positionAnimations = [
      Tween<Offset>(begin: Offset.zero, end: const Offset(0, -75)).animate(
          CurvedAnimation(
              parent: widget.rotationAnimationController,
              curve: Curves.easeInOut)),
      Tween<Offset>(begin: Offset.zero, end: const Offset(75, 0)).animate(
          CurvedAnimation(
              parent: widget.rotationAnimationController,
              curve: Curves.easeInOut)),
      Tween<Offset>(begin: Offset.zero, end: const Offset(0, 75)).animate(
          CurvedAnimation(
              parent: widget.rotationAnimationController,
              curve: Curves.easeInOut)),
      Tween<Offset>(begin: Offset.zero, end: const Offset(-75, 0)).animate(
          CurvedAnimation(
              parent: widget.rotationAnimationController,
              curve: Curves.easeInOut)),
    ];

    _finalTransfomAnimatino = CurvedAnimation(
      parent: widget.finalTransformController,
      curve: Curves.elasticOut,
    );
  }

  final bool _shouldMoveForward = true;

  @override
  Widget build(BuildContext context) {
    List<int> sortedIndices = widget.circleDepths.keys.toList()
      ..sort(
          (a, b) => widget.circleDepths[a]!.compareTo(widget.circleDepths[b]!));

    return GestureDetector(
      onTap: widget.onTriggerAnimation,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.initialTransformController,
          widget.rotationAnimationController,
          widget.finalTransformController
        ]),
        builder: (_, child) {
          return Transform.translate(
            offset: _yOffsetAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: sortedIndices.map((index) {
                  return Material(
                    color: Colors.transparent,
                    child: _buildAnimatedCircle(
                      widget.circleColors[index],
                      _positionAnimations[index],
                      widget.circleDepths[index] ?? 1,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedCircle(
      Color color, Animation<Offset> positionAnimation, int circleDepth) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnimatedBuilder(
        animation: Listenable.merge([
          widget.initialTransformController,
          widget.finalTransformController
        ]),
        builder: (context, child) {
          var maxWidth = constraints.maxWidth * 0.7;

          double height = 56.0 + 150.0 * _finalTransfomAnimatino.value;
          double width = 56 +
              maxWidth * (1 - _initialTransformAnimation.value) +
              maxWidth * _finalTransfomAnimatino.value;

          double borderRadius =
              25.0 * (1 - widget.finalTransformController.value) + 20;

          bool showWinText =
              _finalTransfomAnimatino.status == AnimationStatus.completed &&
                  borderRadius == 20;

          Widget? winWidget;

          if (showWinText && widget.win != null) {
            winWidget = Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: MyText(
                        widget.win!.notes,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyText(
                        widget.win!.formattedDate,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          // if the there is no animation in progress set the winWindert to celebration icon
          if (widget.rotationAnimationController.status ==
                  AnimationStatus.dismissed &&
              widget.finalTransformController.status ==
                  AnimationStatus.dismissed) {
            winWidget = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.celebration,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: MyText(
                          "Surprise Me!",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.celebration,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 25,
                      )
                    ],
                  ),
                ),
              ),
            );
          }

          print(circleDepth);

          return Transform.translate(
            offset: positionAnimation.value,
            child: Container(
              width: max(0, width),
              height: max(0, height),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: FloatingActionButton(
                onPressed: widget.onTriggerAnimation,
                backgroundColor: color,
                elevation: winWidget != null && circleDepth == 2 ? 1.0 : 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: AnimatedOpacity(
                  opacity: widget.initialTransformController.isAnimating ||
                          widget.rotationAnimationController.isAnimating ||
                          widget.finalTransformController.isAnimating
                      ? 0.0
                      : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: winWidget,
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
