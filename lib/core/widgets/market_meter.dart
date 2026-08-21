import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_theme.dart';

/// Signature element: "Meteran Pasar" (Market Meter).
///
/// A half-circle gauge inspired by traditional market scales (timbangan).
/// The needle animates from 0 to the target score, creating a memorable
/// reveal moment. Colors flow from cabai (low) → lampu (medium) → daunan (high).
class MarketMeter extends StatefulWidget {
  /// Score label: 'Tinggi', 'Sedang', or 'Rendah'
  final String score;

  /// Display label below the gauge (e.g. "Peluang", "Persaingan")
  final String label;

  /// Icon displayed above the gauge
  final IconData icon;

  /// Size of the gauge (width = size, height ≈ size/2 + labels)
  final double size;

  const MarketMeter({
    super.key,
    required this.score,
    required this.label,
    required this.icon,
    this.size = 130,
  });

  @override
  State<MarketMeter> createState() => _MarketMeterState();
}

class _MarketMeterState extends State<MarketMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _needleAnimation;

  double get _targetAngle {
    switch (widget.score.toLowerCase()) {
      case 'tinggi':
        return 0.85; // Near right end
      case 'sedang':
        return 0.50; // Center
      case 'rendah':
        return 0.15; // Near left end
      default:
        return 0.50;
    }
  }

  Color get _scoreColor {
    switch (widget.score.toLowerCase()) {
      case 'tinggi':
        return AppColors.scoreHigh;
      case 'sedang':
        return AppColors.scoreMedium;
      case 'rendah':
        return AppColors.scoreLow;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _needleAnimation = Tween<double>(begin: 0.0, end: _targetAngle).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    // Delay start for staggered effect
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant MarketMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _needleAnimation = Tween<double>(
        begin: _needleAnimation.value,
        end: _targetAngle,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gauge
          SizedBox(
            width: widget.size,
            height: widget.size * 0.55,
            child: AnimatedBuilder(
              animation: _needleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GaugePainter(
                    progress: _needleAnimation.value,
                    scoreColor: _scoreColor,
                  ),
                  size: Size(widget.size, widget.size * 0.55),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          // Score text
          Text(
            widget.score,
            style: AppTheme.displayFont(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _scoreColor,
            ),
          ),
          const SizedBox(height: 2),
          // Label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color scoreColor;

  _GaugePainter({required this.progress, required this.scoreColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.9);
    final radius = size.width * 0.42;
    const startAngle = math.pi; // 180° (left)
    const sweepAngle = math.pi; // 180° sweep to right

    // Background arc (track) — light gray on light theme
    final trackPaint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Colored arc (filled portion)
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: math.pi,
        endAngle: math.pi * 2,
        colors: const [
          AppColors.scoreLow,
          AppColors.scoreMedium,
          AppColors.scoreHigh,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(0),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      arcPaint,
    );

    // Needle
    final needleAngle = startAngle + sweepAngle * progress;
    final needleLength = radius * 0.7;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = scoreColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    // Needle dot (center) — white core on light bg
    canvas.drawCircle(center, 5, Paint()..color = scoreColor);
    canvas.drawCircle(
      center,
      3,
      Paint()..color = Colors.white,
    );

    // Tip glow
    canvas.drawCircle(
      needleEnd,
      4,
      Paint()..color = scoreColor.withValues(alpha: 0.4),
    );
    canvas.drawCircle(needleEnd, 2.5, Paint()..color = scoreColor);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.scoreColor != scoreColor;
  }
}
