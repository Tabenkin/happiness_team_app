import 'package:flutter/material.dart';

class BaseLoading extends StatelessWidget {
  Color? color;
  double? strokeWidth;

  BaseLoading({super.key, 
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    color ??= Theme.of(context).colorScheme.primary;

    return Center(
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth ?? 4.0,
      ),
    );
  }
}
