import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData createTheme() {
  final TextTheme textTheme = GoogleFonts.shareTechTextTheme(
    ThemeData.dark().textTheme,
  );

  ColorScheme colorScheme = ColorScheme.dark(
    primary: Color(0xFF292a2e),
    surface: Color(0xFF212629),
    secondary: Color(0xFFef1c71), //Color(0xFFeb004a),
    onSecondary: Colors.white,
    background: Color(0xFF111214),
  );

  final themeData = ThemeData.from(
    colorScheme: colorScheme,
    textTheme: textTheme,
  ).copyWith(
      accentTextTheme: textTheme,
      primaryTextTheme: textTheme,
      cursorColor: colorScheme.secondary,
      textSelectionHandleColor: colorScheme.secondary);

  return themeData.copyWith(
    appBarTheme: AppBarTheme(elevation: 0, color: colorScheme.background),
  );
}