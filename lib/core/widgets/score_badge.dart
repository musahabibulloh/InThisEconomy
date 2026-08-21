import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_theme.dart';

/// Compact score indicator badge with color-coded background.
/// Used in list views and summary rows where the full MarketMeter
/// gauge would be too large.
class ScoreBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ScoreBadge({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  Color get _color {
    switch (value.toLowerCase()) {
      case 'tinggi':
        return AppColors.scoreHigh;
      case 'sedang':
        return AppColors.scoreMedium;
      case 'rendah':
        return AppColors.scoreLow;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _color, size: 16),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.displayFont(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
