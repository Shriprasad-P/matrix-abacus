import 'package:flutter/material.dart';

/// Matrix Abacus design tokens — calm, trustworthy, softly playful.
abstract final class AppColors {
  static const Color primary = Color(0xFF2F3A8F);
  static const Color primaryDark = Color(0xFF1F2766);
  static const Color primaryLight = Color(0xFF5B67C7);
  static const Color secondary = Color(0xFFF4A261);
  static const Color secondarySoft = Color(0xFFFFE8D1);

  static const Color success = Color(0xFF2E9E6A);
  static const Color successSoft = Color(0xFFE4F6EE);
  static const Color warning = Color(0xFFE9A825);
  static const Color warningSoft = Color(0xFFFFF4D6);
  static const Color error = Color(0xFFE06B6B);
  static const Color errorSoft = Color(0xFFFCE8E8);

  static const Color background = Color(0xFFF3F6FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF2F8);
  static const Color outline = Color(0xFFD7DEEA);

  static const Color textPrimary = Color(0xFF1B2436);
  static const Color textSecondary = Color(0xFF5B6475);
  static const Color textTertiary = Color(0xFF8A93A5);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color streak = Color(0xFFFF8A4C);
  static const Color locked = Color(0xFFB8C0D0);
  static const Color present = Color(0xFF2E9E6A);
  static const Color absent = Color(0xFFE06B6B);
  static const Color holiday = Color(0xFF5B67C7);

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2F3A8F), Color(0xFF4A57B5), Color(0xFF6B78D4)],
  );

  static const LinearGradient practiceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEEF2FF), Color(0xFFF3F6FB)],
  );
}
