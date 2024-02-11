import 'dart:math';

import 'package:flutter/material.dart';
import 'package:happiness_team_app/widgets/my_text.widget.dart';
import 'package:happiness_team_app/happiness_theme.dart';
import 'package:oktoast/oktoast.dart';

class DialogHelper {
  static showResponsiveDialog(
    BuildContext context, {
    required Widget child,
    double? width,
    double heightFactor = 0.8,
    double? height,
    bool enableDrag = true,
  }) {
    return showBottomSheetModal(context,
        heightFactor: heightFactor, child: child, enableDrag: enableDrag);
  }

  // static showAnimatedDialog(
  //   BuildContext context,
  //   Widget child, {
  //   bool barrierDismissible = true,
  //   double leftOffset = 0,
  //   double widthRatio = 0.6,
  //   double? width,
  //   double? height,
  // }) {
  //   height ??= 300;

  //   return showGeneralDialog(
  //     context: context,
  //     barrierColor: Colors.black.withOpacity(0.5),
  //     barrierDismissible: barrierDismissible,
  //     barrierLabel: "",
  //     transitionBuilder: (ctx, a1, a2, widget) {
  //       final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;

  //       return Transform(
  //         transform: Matrix4.translationValues(0.0, curvedValue * 200, 32),
  //         child: Opacity(
  //           opacity: a1.value,
  //           child: SimpleDialog(
  //             backgroundColor: Colors.transparent,
  //             elevation: 0.0,
  //             contentPadding: const EdgeInsets.all(0),
  //             children: [
  //               Container(
  //                 margin: EdgeInsets.only(left: leftOffset),
  //                 width: width ??
  //                     min(1000, MediaQuery.of(context).size.width * widthRatio),
  //                 height: height,
  //                 decoration: BoxDecoration(
  //                   borderRadius: Theme.of(context).borderRadius,
  //                   // color: Colors.black,
  //                 ),
  //                 child: CustomCard(
  //                   child: ClipRRect(
  //                     borderRadius: Theme.of(context).borderRadius,
  //                     child: Stack(
  //                       children: [child],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //     pageBuilder: (ctx, animationa, animationb) {
  //       return SimpleDialog(
  //         contentPadding: const EdgeInsets.all(0),
  //         children: [
  //           child,
  //         ],
  //       );
  //     },
  //   );
  // }

  static showAlertDialog(BuildContext context,
      {required String title,
      required String message,
      double widthRatio = 0.5,
      bool barrierDismissible = true,
      double? width}) {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: barrierDismissible,
      barrierLabel: "",
      transitionBuilder: (ctx, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 32),
          child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                surfaceTintColor: Theme.of(context).colorScheme.background,
                title: MyText(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontSize: 22.0,
                      ),
                ),
                content: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.background),
                  width: width,
                  child: MyText(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 18.0,
                        ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: MyText(
                      "Ok",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              )),
        );
      },
      pageBuilder: (ctx, animationa, animationb) {
        return const SimpleDialog(
          contentPadding: EdgeInsets.all(0),
          children: [
            SizedBox(),
          ],
        );
      },
    );
  }

  static showLandscapeFullScreenModal(
    BuildContext context,
    Widget childWidget,
  ) {
    return showGeneralDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 150),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedValue = animation.value;

        return Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * curvedValue,
            width: MediaQuery.of(context).size.width * curvedValue,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  child: Center(
                    child: OverflowBox(
                      maxWidth:
                          MediaQuery.of(context).size.height * curvedValue,
                      maxHeight:
                          MediaQuery.of(context).size.width * curvedValue,
                      child: Transform.rotate(
                        angle: (90 * animation.value) * pi / 180,
                        child: Center(child: childWidget),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.height * animation.value,
            height: MediaQuery.of(context).size.width * animation.value,
            color: Colors.blue,
          ),
        );
      },
    );
  }

  static showFadeInModal(
    BuildContext context, {
    required Widget child,
  }) {
    var theme = Theme.of(context);

    return showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox();
      },
      transitionBuilder: (context, animation, secondaryAnimation, _) {
        return Opacity(
          opacity: 1.0 * animation.value,
          child: Scaffold(
            backgroundColor: theme.dark.withOpacity(0.6),
            body: Center(
              child: child,
            ),
          ),
        );
      },
    );
  }

  static showPlainBottomModal(
    BuildContext context, {
    required Widget child,
  }) {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: "",
      transitionBuilder: (ctx, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;

        var startingPoint = MediaQuery.of(context).size.height - 800;

        var position = startingPoint + (curvedValue * 200);

        return Transform(
          transform: Matrix4.translationValues(0.0, position, 32),
          child: Opacity(
            opacity: a1.value,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: child,
            ),
          ),
        );
      },
      pageBuilder: (ctx, animationa, animationb) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(0),
          children: [
            child,
          ],
        );
      },
    );
  }

  static showBottomModal(
    BuildContext context, {
    required Widget child,
    required double width,
    required double height,
  }) {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: false,
      barrierLabel: "",
      transitionBuilder: (ctx, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 32),
          child: Opacity(
            opacity: a1.value,
            child: SimpleDialog(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              contentPadding: const EdgeInsets.all(0),
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 0),
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    // color: Colors.black,
                  ),
                  child: Card(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Stack(
                        children: [child],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      pageBuilder: (ctx, animationa, animationb) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(0),
          children: [
            child,
          ],
        );
      },
    );
  }

  static showConfirmDialog(BuildContext context,
      {required String title,
      required String message,
      double widthRatio = 0.5,
      bool barrierDismissible = true,
      double? width,
      NavigatorState? navigatorState}) {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: barrierDismissible,
      barrierLabel: "",
      transitionBuilder: (ctx, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 32),
          child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.background,
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyText(
                    title,
                    style: Theme.of(ctx).textTheme.headlineSmall!.copyWith(
                          fontSize: 22.0,
                        ),
                  ),
                ),
                content: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: width,
                  child: MyText(
                    message,
                    style: Theme.of(ctx).textTheme.bodyLarge!.copyWith(
                          fontSize: 18.0,
                        ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx, rootNavigator: true).pop(false);
                    },
                    child: MyText(
                      "No",
                      style: Theme.of(ctx).textTheme.bodyLarge!.copyWith(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx, rootNavigator: true).pop(true);
                    },
                    child: MyText(
                      "Yes",
                      style: Theme.of(ctx).textTheme.bodyLarge!.copyWith(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(ctx).colorScheme.primary),
                    ),
                  ),
                ],
              )),
        );
      },
      pageBuilder: (ctx, animationa, animationb) {
        return const SimpleDialog(
          contentPadding: EdgeInsets.all(0),
          children: [
            SizedBox(),
          ],
        );
      },
    );
  }

  static Future<dynamic> showBottomSheetModal(
    BuildContext ctx, {
    required Widget child,
    double maxHeight = 500,
    double heightFactor = 0.9,
    bool isBarrierDismissable = true,
    BorderRadius? borderRadius,
    bool showNotch = false,
    bool enableDrag = true,
  }) {
    var defaultBorderRadius = 16.0;
    var theme = Theme.of(ctx);

    return showModalBottomSheet(
      context: ctx,
      enableDrag: enableDrag,
      isScrollControlled: true, // Set this to true
      isDismissible: isBarrierDismissable,
      backgroundColor: theme.colorScheme.background,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ?? BorderRadius.circular(defaultBorderRadius),
      ),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: FractionallySizedBox(
            heightFactor: heightFactor,
            child: ClipRRect(
              borderRadius:
                  borderRadius ?? BorderRadius.circular(defaultBorderRadius),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: child,
                  ),
                  if (showNotch == true)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 4.0,
                          ),
                          Container(
                            height: 5,
                            width: 36,
                            margin: const EdgeInsets.only(bottom: 10, top: 5),
                            decoration: BoxDecoration(
                              color: theme
                                  .dividerColor, // Adjusted to use a more generic theme color reference
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(2.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static PersistentBottomSheetController showModal(
    BuildContext ctx,
    Widget child, {
    double heightFactor = 0.7,
    Color? barrierColor,
    int leftOffset = 275,
  }) {
    var screenWidth = MediaQuery.of(ctx).size.width;

    return showBottomSheet(
      context: ctx,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth - 275),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  // margin: EdgeInsets.only(left: leftOffset.toDouble()),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                      color: Theme.of(context).colorScheme.background),
                  child: child,
                );
              },
            ),
          ),
        );
      },
    );
  }

  static showSimpleSuccessToast(
    BuildContext context,
    String message, {
    double? width,
    double margin = 16.0,
  }) {
    var theme = Theme.of(context);

    showToastWidget(
      Container(
        margin: margin != null
            ? EdgeInsets.only(
                left: margin,
                right: margin,
                top: margin * 2,
              )
            : const EdgeInsets.all(0),
        width: width ?? double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: theme.success,
          borderRadius: theme.borderRadius,
        ),
        child: MyText(
          message,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 18.0,
                color: theme.onSuccess,
              ),
          textAlign: TextAlign.center,
        ),
      ),
      duration: const Duration(seconds: 3),
      position: ToastPosition.top,
      // constraints: BoxConstraints(maxWidth: double.infinity),
    );
  }

  static showSimpleErrorToast(BuildContext context, String message,
      {double? width}) {
    showToastWidget(
      Container(
        margin: const EdgeInsets.all(
          16.0,
        ),
        width: width ?? double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: Theme.of(context).borderRadius,
        ),
        child: MyText(
          message,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 18.0,
                color: Theme.of(context).colorScheme.onError,
              ),
          textAlign: TextAlign.center,
        ),
      ),
      duration: const Duration(seconds: 3),
      position: ToastPosition.top,
      // constraints: BoxConstraints(maxWidth: double.infinity),
    );
  }
}
