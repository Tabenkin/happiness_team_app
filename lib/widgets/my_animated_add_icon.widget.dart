import 'package:flutter/material.dart';

class MyAnimatedAddIcon extends StatefulWidget {
  final bool showCross;
  const MyAnimatedAddIcon({Key? key, required this.showCross})
      : super(key: key);

  @override
  _MyAnimatedAddIconState createState() => _MyAnimatedAddIconState();
}

class _MyAnimatedAddIconState extends State<MyAnimatedAddIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Use CurvedAnimation to apply a non-linear curve to the animation
    final CurvedAnimation curve =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);

    // Update the Tween to increase the rotation (e.g., 2 full rotations)
    // and apply the curve for a more dynamic effect
    _animation = Tween<double>(begin: 0.0, end: 4 * 3.14159)
        .animate(curve) // 2 full rotations
      ..addListener(() {
        setState(() {});
      });

    if (widget.showCross) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(MyAnimatedAddIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showCross != oldWidget.showCross) {
      if (widget.showCross) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _animation.value, // Apply the animation value directly
      child: widget.showCross ? const Icon(Icons.close) : const Icon(Icons.add),
    );
  }
}
