import 'dart:math';

import 'package:flutter/material.dart';

class BaseText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final double maxTextScale;
  final int? maxLines;
  final TextOverflow? overflow;

  const BaseText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxTextScale = 1.2,
    this.maxLines,
    this.overflow,
  });

  double maxTextScaleFactor(BuildContext context, double maxScale) {
    return min(MediaQuery.of(context).textScaleFactor, maxScale);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      textScaler: TextScaler.linear(
        maxTextScaleFactor(context, maxTextScale),
      ),
    );
  }
}
