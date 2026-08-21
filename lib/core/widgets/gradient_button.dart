import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Primary CTA button with gradient background and glow shadow.
/// Text is dark-on-gold for the warm primary, white for accent gradients.
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  /// Decide text/icon color based on gradient brightness.
  /// Primary (gold) uses dark text; accent/danger/secondary use white.
  Color get _foregroundColor {
    if (gradient == null || gradient == AppColors.primaryGradient) {
      return const Color(0xFF1B2838);
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return SizedBox(
      width: width ?? double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isEnabled
              ? (gradient ?? AppColors.primaryGradient)
              : LinearGradient(
                  colors: [
                    AppColors.textMuted.withValues(alpha: 0.3),
                    AppColors.textMuted.withValues(alpha: 0.2),
                  ],
                ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: (gradient ?? AppColors.primaryGradient)
                        .colors
                        .first
                        .withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: _foregroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_foregroundColor),
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: _foregroundColor),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: _foregroundColor,
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
