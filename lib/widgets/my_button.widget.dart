import 'package:flutter/material.dart';
import 'package:happiness_team_app/happiness_theme.dart';

enum MyButtonColor { primary, secondary, tertiary, error, google, apple }

class MyButton extends StatefulWidget {
  final MyButtonColor color;
  final Widget child;
  final VoidCallback? onTap;
  final bool showSpinner;
  final bool filled;
  final double textSize;

  const MyButton({
    Key? key,
    this.color = MyButtonColor.primary, // Default to primary if not provided
    required this.child,
    this.onTap,
    this.showSpinner = false,
    this.filled = true, // Default to false if not provided
    this.textSize = 16, // Default to 16 if not provided
  }) : super(key: key);

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  late Color backgroundColor;
  late Color onPrimaryColor;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // Determine the colors based on the theme and MyButtonColor
    switch (widget.color) {
      case MyButtonColor.primary:
        backgroundColor = theme.primaryColor;
        onPrimaryColor = theme.colorScheme.onPrimary;
        break;
      case MyButtonColor.secondary:
        backgroundColor = theme.colorScheme.secondary;
        onPrimaryColor = theme.colorScheme.onSecondary;
        break;
      case MyButtonColor.tertiary:
        backgroundColor = theme.colorScheme.tertiary;
        onPrimaryColor = theme.colorScheme.onTertiary;
        break;
      case MyButtonColor.error:
        backgroundColor = theme.colorScheme.error;
        onPrimaryColor = theme.colorScheme.onError;
        break;
      case MyButtonColor.google:
        backgroundColor = theme.google;
        onPrimaryColor = theme.onGoogle;
        break;
      case MyButtonColor.apple:
        backgroundColor = const Color(0xFF000000);
        onPrimaryColor = const Color(0xFFFFFFFF);
        break;
    }

    // Set the text color to the passed color if not filled
    Color textColor = widget.filled ? onPrimaryColor : backgroundColor;

    // Set a smaller text size for the text within the button
    double textSize =
        widget.textSize; // Example text size, you can adjust as needed

    return DefaultTextStyle(
      style: TextStyle(color: textColor, fontSize: textSize),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.zero, // No padding for the AnimatedContainer
        child: Material(
          color: widget.filled
              ? backgroundColor
              : Colors.transparent, // Use the background color if filled
          borderRadius: BorderRadius.circular(
              25), // Border radius for the Material widget
          child: InkWell(
            borderRadius: BorderRadius.circular(
                25), // Match the border radius for the ripple effect
            onTap: widget.showSpinner ? null : widget.onTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ), //
                  child: DefaultTextStyle(
                    style: TextStyle(color: textColor, fontSize: textSize),
                    child: IconTheme(
                      data: IconThemeData(color: textColor),
                      child: widget.child,
                    ),
                  ),
                ),
                if (widget.showSpinner)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        25,
                      ), // Clip overlay to match button shape
                      child: Container(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5), // Semi-transparent overlay
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ), // Spinner color
                              strokeWidth: 2.0,
                              // Thinner stroke for the spinner
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
