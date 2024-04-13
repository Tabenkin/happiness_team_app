import 'dart:math';

import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final double maxTextScale;
  final int? maxLines;
  final TextOverflow? overflow;

  const MyText(
    this.data, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxTextScale = 1.2,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  double maxTextScaleFactor(BuildContext context, double maxScale) {
    return min(MediaQuery.of(context).textScaleFactor, maxScale);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyMedium;
    final effectiveStyle =
        style == null ? defaultStyle : defaultStyle?.merge(style);

    return Text(
      data,
      style: effectiveStyle,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      textScaler: TextScaler.linear(
        maxTextScaleFactor(context, maxTextScale),
      ),
    );
  }
}
