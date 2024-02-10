import 'dart:math';
import 'package:flutter/material.dart';

class WinningWheel extends StatefulWidget {
  const WinningWheel({super.key});

  @override
  _WinningWheelState createState() => _WinningWheelState();
}

class _WinningWheelState extends State<WinningWheel>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  List<Animation<Offset>> _positionAnimations = [];
  Map<int, int> circleDepths = {0: 1, 1: 1, 2: 1, 3: 1};

  final List<Color> circleColors = [
    const Color(0xFFA4DDF8), // Light Blue
    const Color(0xFFFAAC3E), // Orange
    const Color(0xFFA73A36), // Red
    const Color(0xFF136478), // Dark Blue
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _positionAnimations = [
      Tween<Offset>(begin: Offset.zero, end: const Offset(0, -100)).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      Tween<Offset>(begin: Offset.zero, end: const Offset(100, 0)).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      Tween<Offset>(begin: Offset.zero, end: const Offset(0, 100)).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      Tween<Offset>(begin: Offset.zero, end: const Offset(-100, 0)).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
    ];

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Once the animation completes its forward run, bring a random circle to the front
        bringRandomCircleToFront();
        // Then reverse the animation without repeating
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        // Once the animation completes its reverse run, stop the animation
        // This line is optional if you don't need to do anything when animation is dismissed
      }
    });

    _controller.forward();
  }

  void bringRandomCircleToFront() {
    setState(() {
      final randomIndex = Random().nextInt(4); // Assuming there are 4 circles
      // Update depths to bring the selected circle to the front
      circleDepths.forEach((key, value) {
        circleDepths[key] = key == randomIndex ? 2 : 1;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sort circles based on their "depth" to determine the draw order
    final sortedCircleIndexes = circleDepths.keys.toList()
      ..sort((a, b) => circleDepths[a]!.compareTo(circleDepths[b]!));

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: sortedCircleIndexes.map((index) {
              return Transform.translate(
                offset: _positionAnimations[index].value,
                child: CircleWidget(color: circleColors[index]),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class CircleWidget extends StatelessWidget {
  final Color color;

  const CircleWidget({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
