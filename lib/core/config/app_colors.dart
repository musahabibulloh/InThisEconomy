import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Deep indigo to violet gradient
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7CF6);
  static const Color primaryDark = Color(0xFF4C3ED1);

  // Secondary palette - Teal accent
  static const Color secondary = Color(0xFF00CEC9);
  static const Color secondaryLight = Color(0xFF55E6C1);
  static const Color secondaryDark = Color(0xFF009E98);

  // Accent - Warm coral
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF8E8E);

  // Background & Surface (Dark mode)
  static const Color bgDark = Color(0xFF0F0F23);
  static const Color bgDarkSecondary = Color(0xFF1A1A3E);
  static const Color surfaceDark = Color(0xFF252550);
  static const Color surfaceDarkElevated = Color(0xFF2D2D5E);

  // Text
  static const Color textPrimary = Color(0xFFF5F5FF);
  static const Color textSecondary = Color(0xFFB0B0D0);
  static const Color textMuted = Color(0xFF7070A0);

  // Score colors
  static const Color scoreHigh = Color(0xFF00E676);
  static const Color scoreMedium = Color(0xFFFFAB40);
  static const Color scoreLow = Color(0xFFFF5252);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceDark, surfaceDarkElevated],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [secondary, Color(0xFF6C5CE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [accent, Color(0xFFE55039)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
