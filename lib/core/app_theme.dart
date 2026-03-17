import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color navy = Color(0xFF0E1E34);
  static const Color navyDeep = Color(0xFF0A1526);
  static const Color slate = Color(0xFF1C2433);
  static const Color cyan = Color(0xFF37C8FF);
  static const Color blue = Color(0xFF1C7DFF);
  static const Color textSoft = Color(0xFFB7C3D7);

  static ThemeData light() {
    final base = ThemeData(
      colorSchemeSeed: blue,
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    return base.copyWith(
      scaffoldBackgroundColor: navy,
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
      ),
    );
  }
}