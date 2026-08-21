import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Glassmorphism card — frosted glass surface for the light theme.
///
/// Uses `BackdropFilter` for real blur when floating over colorful content.
/// Falls back to a white semi-transparent surface if blur is not supported.
/// The border is a thin white highlight simulating light hitting a glass edge.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final LinearGradient? gradient;
  final double borderRadius;
  final double blurSigma;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.gradient,
    this.borderRadius = 20,
    this.blurSigma = 16,
    this.opacity = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.glassShadow(0.12), // Increased opacity
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.glassShadow(0.08), // Increased opacity
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              // Glass fill — white semi-transparent
              gradient: gradient ??
                  LinearGradient(
                    colors: [
                      AppColors.glassWhite(opacity),
                      AppColors.glassWhite(opacity - 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              borderRadius: BorderRadius.circular(borderRadius),
              // Glass edge — white highlight border
              border: Border.all(
                color: AppColors.glassBorder(0.45),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                splashColor: AppColors.primary.withValues(alpha: 0.08),
                highlightColor: AppColors.primary.withValues(alpha: 0.04),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(20),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
