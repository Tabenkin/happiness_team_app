import 'dart:math';
import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  final List<Color> colors;
  final double progress;
  final double distanceFromCenter;

  CirclePainter({
    required this.colors,
    required this.progress,
    this.distanceFromCenter =
        50.0, // Default distance, adjust based on your layout
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    const circleRadius = 20.0; // Circle radius, adjust as needed

    for (int i = 0; i < 4; i++) {
      // Calculate angle for the spinning effect
      final angle = 2 * pi * i / 4 + 2 * pi * progress;
      // Adjust distance for the spiral effect based on progress
      final currentDistance = distanceFromCenter * (1 - progress);

      // Calculate circle center for both spinning and spiraling effect
      final circleCenter = Offset(
        center.dx + currentDistance * cos(angle),
        center.dy + currentDistance * sin(angle),
      );

      paint.color = colors[i];
      canvas.drawCircle(circleCenter, circleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Always repaint for simplicity; could be optimized based on actual changes in progress or distance
    return true;
  }
}
