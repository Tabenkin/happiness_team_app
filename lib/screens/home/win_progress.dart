import 'package:flutter/material.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:happiness_team_app/models/win.model.dart';

class WinProgress extends StatefulWidget {
  final Wins wins;

  const WinProgress({
    required this.wins,
    Key? key,
  }) : super(key: key);

  @override
  State<WinProgress> createState() => _WinProgressState();
}

class _WinProgressState extends State<WinProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration:
          const Duration(milliseconds: 400), // Animation duration of 2 seconds
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0, // Assuming starting with 0 wins
      end: widget.wins.length / 10, // Normalized value for progress bar
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WinProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.wins.length != oldWidget.wins.length) {
      // Update the animation to reflect the new value
      double newEnd = widget.wins.length / 10;
      _animation = Tween<double>(
        begin: _animation.value,
        end: newEnd,
      ).animate(_controller);

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
          left: 32.0, right: 32.0, top: 40, bottom: 16.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: _animation.value, // Current progress
            backgroundColor: theme.medium,
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
            minHeight: 20, // Adjust the thickness
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Add 10 wins to unlock new features",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
