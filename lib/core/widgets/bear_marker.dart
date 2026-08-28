import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Bear expression level based on competitor rating.
enum BearExpression {
  happy,   // Rating >= 4.0 — strong competitor
  neutral, // Rating 3.0–3.9 — average
  sad,     // Rating < 3.0 — weak (opportunity gap!)
}

/// Returns a bear expression based on the competitor's rating.
BearExpression bearExpressionForRating(double rating) {
  if (rating >= 4.0) return BearExpression.happy;
  if (rating >= 3.0) return BearExpression.neutral;
  return BearExpression.sad;
}

/// Custom bear face marker widget for competitor map markers.
///
/// Uses SVG bear face assets with varying expressions based on
/// competitor rating — strong competitors smile, weak ones look lesu.
class BearMarker extends StatelessWidget {
  final BearExpression expression;
  final double size;
  final VoidCallback? onTap;

  const BearMarker({
    super.key,
    this.expression = BearExpression.neutral,
    this.size = 36,
    this.onTap,
  });

  /// Factory from rating value.
  factory BearMarker.fromRating(double rating, {double size = 36, VoidCallback? onTap}) {
    return BearMarker(
      expression: bearExpressionForRating(rating),
      size: size,
      onTap: onTap,
    );
  }

  String get _assetPath {
    switch (expression) {
      case BearExpression.happy:
        return 'assets/icons/bear_happy.svg';
      case BearExpression.neutral:
        return 'assets/icons/bear_neutral.svg';
      case BearExpression.sad:
        return 'assets/icons/bear_sad.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          _assetPath,
          width: size,
          height: size,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: child);
    }
    return child;
  }
}
