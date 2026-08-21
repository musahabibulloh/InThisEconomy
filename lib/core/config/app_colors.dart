import 'package:flutter/material.dart';

/// Color palette — Light Glassmorphism theme.
/// Warm, clean, and airy — inspired by frosted glass under soft daylight.
/// The "pasar sore" identity (gold, teal, chili) is preserved as accent colors
/// but now lives on a bright, breathing canvas.
class AppColors {
  // ── Primary: Kuning Lampu (lantern gold) — solid, pekat ──
  static const Color primary = Color(0xFFE8961F);
  static const Color primaryLight = Color(0xFFF2A93B);
  static const Color primaryDark = Color(0xFFCB7E12);

  // ── Secondary: Hijau Daun Pisang (banana leaf teal) ──
  static const Color secondary = Color(0xFF2BA69E);
  static const Color secondaryLight = Color(0xFF4ECDC4);
  static const Color secondaryDark = Color(0xFF1E8C85);

  // ── Accent: Merah Cabai (chili red) ──
  static const Color accent = Color(0xFFE84545);
  static const Color accentLight = Color(0xFFFF6B6B);

  // ── Background & Surface (Light — cream to white gradient canvas) ──
  static const Color bgLight = Color(0xFFF7F4EF);        // Warm cream base
  static const Color bgLightSecondary = Color(0xFFF0ECE5); // Slightly deeper cream
  static const Color surfaceLight = Color(0xFFFFFFFF);     // Pure white card fallback
  static const Color surfaceLightElevated = Color(0xFFFAF8F5); // Warm white

  // ── Glass surface tokens ──
  /// Glass fill: highly transparent white
  static Color glassWhite([double opacity = 0.35]) =>
      Colors.white.withValues(alpha: opacity);
  /// Glass border: white at higher opacity for light-edge refraction effect
  static Color glassBorder([double opacity = 0.5]) =>
      Colors.white.withValues(alpha: opacity);
  /// Glass shadow: very soft, diffused, warm
  static Color glassShadow([double opacity = 0.08]) =>
      const Color(0xFF6E5A3E).withValues(alpha: opacity);

  // ── Text (dark, solid — never transparent on glass) ──
  static const Color textPrimary = Color(0xFF1E1E1E);       // Jet black text
  static const Color textSecondary = Color(0xFF5A5A5A);      // Dark gray
  static const Color textMuted = Color(0xFF9E9E9E);          // Medium gray
  static const Color textOnPrimary = Color(0xFFFFFFFF);      // White on colored bg

  // ── Score/Status colors (same identity, slightly bolder for light bg) ──
  static const Color scoreHigh = Color(0xFF2BA69E);    // daunan — subur
  static const Color scoreMedium = Color(0xFFE8961F);  // lampu — perhatian
  static const Color scoreLow = Color(0xFFE84545);     // cabai — panas

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF2A93B), Color(0xFFE8961F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle warm canvas gradient — used as Scaffold background
  static const LinearGradient canvasGradient = LinearGradient(
    colors: [Color(0xFFF7F4EF), Color(0xFFEDE8DF), Color(0xFFF0ECE5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  /// Card gradient — replaced by glass; kept for compatibility
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAF8F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF2BA69E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFE84545)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient for the Market Meter gauge (low → medium → high)
  static const LinearGradient gaugeGradient = LinearGradient(
    colors: [scoreLow, scoreMedium, scoreHigh],
    stops: [0.0, 0.5, 1.0],
  );
}
