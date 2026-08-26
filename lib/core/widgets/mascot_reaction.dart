import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import 'ite_avatar.dart';

/// Mascot reaction strip — Ite + speech bubble with contextual message.
///
/// Used in analysis results, empty states, loading states, and info sections.
/// The mascot appears on the left with a speech bubble containing the message.
class MascotReaction extends StatelessWidget {
  final ItePose pose;
  final String message;
  final Color? bubbleColor;
  final double mascotSize;
  final bool highlighted;

  const MascotReaction({
    super.key,
    required this.pose,
    required this.message,
    this.bubbleColor,
    this.mascotSize = 48,
    this.highlighted = false,
  });

  /// Convenient factory for score-based reactions (opportunity score).
  factory MascotReaction.forScore(String score) {
    switch (score.toLowerCase()) {
      case 'tinggi':
        return const MascotReaction(
          pose: ItePose.celebrate,
          message:
              'Mantap! Peluangnya cerah banget di sini! 🌟 Ayo mulai sebelum yang lain duluan!',
          highlighted: true,
        );
      case 'sedang':
        return const MascotReaction(
          pose: ItePose.thinking,
          message:
              'Lumayan ada peluang nih, tapi perlu strategi yang tepat biar bisa menang dari pesaing 🤔',
        );
      case 'rendah':
        return const MascotReaction(
          pose: ItePose.support,
          message:
              'Jangan sedih ya — persaingan ketat artinya pasarnya memang ada! Yuk kita cari celahnya bareng 💪',
        );
      default:
        return const MascotReaction(
          pose: ItePose.thinking,
          message: 'Ite lagi ngitung-ngitung hasilnya... Sabar ya! 😊',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = highlighted
        ? AppColors.primary.withValues(alpha: 0.08)
        : bubbleColor ?? AppColors.surfaceLightElevated;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: highlighted
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.textMuted.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IteAvatar(pose: pose, size: mascotSize),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Speech bubble tail hint
                Text(
                  'Ite bilang:',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

/// Compact mascot speech for inline use (no card wrapper).
class MascotSpeech extends StatelessWidget {
  final ItePose pose;
  final String message;
  final double mascotSize;

  const MascotSpeech({
    super.key,
    required this.pose,
    required this.message,
    this.mascotSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLightElevated,
        borderRadius: BorderRadius.circular(16), // Rounded cleanly on all sides
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IteAvatar(pose: pose, size: mascotSize, showEntrance: false),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state widget with Ite mascot.
class MascotEmptyState extends StatelessWidget {
  final ItePose pose;
  final String title;
  final String subtitle;
  final Widget? action;

  const MascotEmptyState({
    super.key,
    this.pose = ItePose.greet,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IteAvatar(pose: pose, size: 80),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}
