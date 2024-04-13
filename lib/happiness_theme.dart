import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData happinessTheme = ThemeData(
  // Define the default brightness and colors.
  brightness: Brightness.light,
  primaryColor: const Color(0xFF0C5363),
  primaryColorLight: const Color(0xFF246473),
  primaryColorDark: const Color(0xFF0b4957),

  // Define the default font family.
  fontFamily: GoogleFonts.ptSans().fontFamily,

  // Define the default TextTheme. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    displayLarge: GoogleFonts.ptSans(
      fontSize: 72.0,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF0E3254),
    ),
    titleLarge: GoogleFonts.ptSans(
      fontSize: 36.0,
      color: const Color(0xFF0E3254),
    ),
    titleMedium: GoogleFonts.ptSans(
      fontSize: 32.0,
      color: const Color(0xFF0E3254),
    ),
    titleSmall:
        GoogleFonts.ptSans(fontSize: 28.0, color: const Color(0xFF0E3254)),
    bodyLarge: GoogleFonts.ptSans(
        fontSize: 18.0, height: 1.1, color: const Color(0xFF0E3254)),
    bodyMedium: GoogleFonts.ptSans(
        fontSize: 16.0, height: 1.1, color: const Color(0xFF0E3254)),
  ),

  hintColor: const Color(0xFF92949c),

  // Example of customizing a widget directly within the theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFF7941D),
    foregroundColor: Color(0xFFFFFFFF),
  ),

  scaffoldBackgroundColor: Colors.white,

  // AppBar theme
  appBarTheme: const AppBarTheme(
    toolbarHeight: kToolbarHeight * 1.5,
    color: Colors.white,
    iconTheme: IconThemeData(
      color: Color(0xFF0C5363),
    ),
    titleTextStyle: TextStyle(
      color: Color(0xFF0C5363),
      fontSize: 28.0,
    ),
  ),
  colorScheme: const ColorScheme.light(
    surfaceTint: Colors.transparent,
    primary: Color(0xFF0C5363),
    onPrimary: Color(0xFFFFFFFF),
    // secondary: Color(0xFFF7941D),
    secondary: Color(0xffA73A37),
    onSecondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFFF7941D),
    onTertiary: Color(0xFF000000),

    error: Color(0xFFA83B36),
    onError: Color(0xFFFFFFFF),
    background: Color(0xFFFFFFFF),
    onBackground: Color(0xFF000000),
    surface: Color(0xFFF5F8FA),
    onSurface: Color(0xFF000000),
  ),
);

extension CustomTheme on ThemeData {
  Color get success => const Color.fromRGBO(80, 122, 96, 1);
  Color get timer => const Color.fromRGBO(80, 122, 96, 1);
  Color get onSuccess => const Color.fromRGBO(253, 251, 243, 1);
  Color get google => const Color.fromRGBO(219, 68, 55, 1.0);
  Color get onGoogle => const Color.fromRGBO(253, 251, 243, 1);
  Color get apple => Colors.black;
  Color get onApple => const Color.fromRGBO(253, 251, 243, 1);
  Color get dark => Colors.grey[800]!;
  Color get medium => Colors.grey[300]!;
  Color get light => const Color.fromRGBO(244, 245, 248, 1);
  Color get text => const Color(0xFF0E3254);
  Color get lightBlue => const Color(0xFFA4DDF8);
}

extension CustomProperties on ThemeData {
  BorderRadius get borderRadius => BorderRadius.circular(3.0);
  double get borderRadiusValue => 3.0;
  BoxShadow get boxShadow =>
      const BoxShadow(color: Color.fromRGBO(186, 186, 190, 1), blurRadius: 6.0);
  BoxShadow get tightBoxShadow =>
      const BoxShadow(color: Color.fromRGBO(186, 186, 190, 1), blurRadius: 2.0);
}
