import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      textTheme: GoogleFonts.notoSansBengaliTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFF6FBFF),
        displayColor: const Color(0xFFF6FBFF),
      ),
      scaffoldBackgroundColor: const Color(0xFF05386B),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFFF7C62F),
        secondary: const Color(0xFF2D8CFF),
        surface: const Color(0xFF0A3B74),
      ),
    );
  }
}
