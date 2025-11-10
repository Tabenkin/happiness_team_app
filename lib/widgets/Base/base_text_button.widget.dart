import 'package:flutter/material.dart';
import 'package:happiness_team_app/widgets/Base/base_button.widget.dart';

class BaseTextButton extends StatefulWidget {
  final Widget child;
  final bool showSpinner;
  final EdgeInsets? padding;
  final BaseButtonTheme theme;
  final Function() onPressed;

  const BaseTextButton({
    required this.child,
    required this.onPressed,
    this.theme = BaseButtonTheme.primary,
    this.showSpinner = false,
    this.padding,
    super.key,
  });

  @override
  State<BaseTextButton> createState() => _BaseTextButtonState();
}

class _BaseTextButtonState extends State<BaseTextButton> {
  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color splashColor;

    switch (widget.theme) {
      case BaseButtonTheme.secondary:
        textColor = Theme.of(context).colorScheme.secondary;
        splashColor = Theme.of(context).colorScheme.secondary.withOpacity(0.2);
        break;
      case BaseButtonTheme.tertiary:
        textColor = Theme.of(context).colorScheme.tertiary;
        splashColor = Theme.of(context).colorScheme.tertiary.withOpacity(0.2);
        break;
      case BaseButtonTheme.outline:
        textColor = Theme.of(context).colorScheme.primary;
        splashColor = Theme.of(context).colorScheme.primary.withOpacity(0.2);
        break;
      case BaseButtonTheme.danger:
        textColor = Theme.of(context).colorScheme.error;
        splashColor = Theme.of(context).colorScheme.error.withOpacity(0.2);
        break;
      case BaseButtonTheme.primary:
      default:
        textColor = Theme.of(context).colorScheme.primary;
        splashColor = Theme.of(context).colorScheme.primary.withOpacity(0.2);
        break;
    }

    return Stack(
      children: [
        TextButton(
          onPressed: widget.onPressed,
          style: ButtonStyle(
            padding: widget.padding != null
                ? WidgetStateProperty.all(widget.padding)
                : null,
            overlayColor: WidgetStateProperty.all(splashColor),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: textColor,
                ),
            child: widget.child,
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
                  height: 40,
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
        ),
      ],
    );
  }
}
