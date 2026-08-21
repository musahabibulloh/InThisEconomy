import 'package:flutter/material.dart';

/// Color palette inspired by Indonesian traditional market at dusk (pasar sore).
/// Warm evening blues, golden lantern light, fresh banana leaf greens, and fiery chili reds.
class AppColors {
  // ── Primary: Kuning Lampu (lantern gold) ──
  static const Color primary = Color(0xFFF2A93B);
  static const Color primaryLight = Color(0xFFFFCA6E);
  static const Color primaryDark = Color(0xFFD48A1E);

  // ── Secondary: Hijau Daun Pisang (banana leaf teal) ──
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryLight = Color(0xFF7EDDD6);
  static const Color secondaryDark = Color(0xFF2BA69E);

  // ── Accent: Merah Cabai (chili red) ──
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF9B9B);

  // ── Background & Surface (Biru Senja — dusk blue) ──
  static const Color bgDark = Color(0xFF1B2838);
  static const Color bgDarkSecondary = Color(0xFF1F3044);
  static const Color surfaceDark = Color(0xFF243447);
  static const Color surfaceDarkElevated = Color(0xFF2C3E52);

  // ── Text (Kapur & Asap) ──
  static const Color textPrimary = Color(0xFFE8E6DF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF8899AA);

  // ── Score/Status colors (thematic, not generic semaphore) ──
  static const Color scoreHigh = Color(0xFF4ECDC4);    // daunan — subur, tumbuh
  static const Color scoreMedium = Color(0xFFF2A93B);   // lampu — perlu perhatian
  static const Color scoreLow = Color(0xFFFF6B6B);      // cabai — panas, berisiko

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF2A93B), Color(0xFFE8851C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceDark, surfaceDarkElevated],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [secondary, Color(0xFF2BA69E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [accent, Color(0xFFE55039)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient for the Market Meter gauge (low → medium → high)
  static const LinearGradient gaugeGradient = LinearGradient(
    colors: [scoreLow, scoreMedium, scoreHigh],
    stops: [0.0, 0.5, 1.0],
  );
}
