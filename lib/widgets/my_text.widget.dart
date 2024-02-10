import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;

  const MyText(this.data, {Key? key, this.style, this.textAlign})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyMedium;
    final effectiveStyle =
        style == null ? defaultStyle : defaultStyle?.merge(style);

    return Text(
      data,
      style: effectiveStyle,
      textAlign: textAlign,
    );
  }
}
