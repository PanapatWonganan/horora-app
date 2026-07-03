import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    Key? key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors ?? [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _StarsPainter(),
            ),
          ),
          // Content
          child,
        ],
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  // Fixed seed so the stars are deterministic (no per-frame churn / jitter
  // on every repaint). Matches the pattern used by _GrainPainter in
  // lib/core/theme/celestial_effects.dart.
  static const int _seed = 1340217;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final rng = math.Random(_seed);
    const starCount = 100;

    for (var i = 0; i < starCount; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final radius = rng.nextDouble() * 3 + 1.0;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 