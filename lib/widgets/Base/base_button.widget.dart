import 'package:flutter/material.dart';
import 'package:happiness_team_app/widgets/Base/base_text.widget.dart';

enum BaseButtonTheme {
  primary,
  secondary,
  tertiary,
  outline,
  success,
  danger,
  google,
  apple,
}

class BaseButton extends StatefulWidget {
  final String? label;
  final Widget? child;
  final BaseButtonTheme theme;
  final bool showSpinner;
  final double? width;
  final Function() onPressed;

  const BaseButton({
    this.label,
    this.child,
    required this.onPressed,
    this.theme = BaseButtonTheme.primary,
    this.showSpinner = false,
    this.width,
    super.key,
  }) : assert(
            (label != null && child == null) ||
                (label == null && child != null),
            'You must provide either a label or a child, but not both.');

  @override
  State<BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends State<BaseButton> {
  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (widget.theme) {
      case BaseButtonTheme.secondary:
        backgroundColor = Theme.of(context).colorScheme.secondary;
        textColor = Theme.of(context).colorScheme.onSecondary;
        borderColor = Theme.of(context).colorScheme.secondary;
        break;
      case BaseButtonTheme.tertiary:
        backgroundColor = Theme.of(context).colorScheme.tertiary;
        textColor = Theme.of(context).colorScheme.onTertiary;
        borderColor = Theme.of(context).colorScheme.tertiary;
        break;
      case BaseButtonTheme.outline:
        backgroundColor = Theme.of(context).colorScheme.surface;
        textColor = Theme.of(context).colorScheme.primary;
        borderColor = Theme.of(context).colorScheme.primary;
        break;
      case BaseButtonTheme.danger:
        backgroundColor = Theme.of(context).colorScheme.error;
        textColor = Theme.of(context).colorScheme.onError;
        borderColor = Theme.of(context).colorScheme.error;
        break;
      case BaseButtonTheme.primary:
      default:
        backgroundColor = Theme.of(context).colorScheme.primary;
        textColor = Theme.of(context).colorScheme.onPrimary;
        borderColor = Theme.of(context).colorScheme.primary;
        break;
    }

    return SizedBox(
      height: 50,
      width: widget.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 50,
            width: widget.width,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: textColor,
                    ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(
                    color: borderColor,
                    width: 3.0,
                  ),
                ),
              ),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: textColor,
                    ),
                child: IconTheme(
                  data: IconThemeData(
                    color: textColor,
                  ),
                  child: widget.child != null
                      ? widget.child!
                      : widget.label != null
                          ? BaseText(widget.label!)
                          : const BaseText("-"),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: widget.showSpinner ? 1 : 0,
              child: IgnorePointer(
                ignoring: widget.showSpinner != true,
                child: IntrinsicHeight(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
