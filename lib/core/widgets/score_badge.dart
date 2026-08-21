import 'package:flutter/material.dart';
import '../config/app_colors.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: _color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
