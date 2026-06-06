import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A one-shot celestial "burst" overlay played the moment a tarot card is
/// revealed — the signature moment. A soft expanding gold halo plus a ring of
/// outward-flung sparkles that fade as they travel.
///
/// Pure visual: it reads a [progress] value (0→1) from an external controller
/// and paints accordingly. No app logic/state lives here.
class RevealBurst extends StatelessWidget {
  /// 0 → 1 progress of the burst. At 0 nothing is drawn; at 1 it has faded out.
  final double progress;
  final Color color;

  const RevealBurst({
    super.key,
    required this.progress,
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 1) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: CustomPaint(
        painter: _BurstPainter(progress: progress, color: color),
        size: Size.infinite,
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final double progress;
  final Color color;

  // Deterministic spark angles (no per-frame Random churn).
  static const int _sparkCount = 10;

  _BurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) * 0.75;

    // Curve: fast in, gentle out.
    final eased = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final fade = (1.0 - progress).clamp(0.0, 1.0);

    // 1) Expanding soft halo.
    final haloR = maxR * (0.25 + eased * 0.75);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.28 * fade),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.55, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: haloR));
    canvas.drawCircle(center, haloR, haloPaint);

    // 2) Central flash that blooms then fades.
    final flashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5 * fade * fade);
    canvas.drawCircle(center, maxR * 0.18 * (1 - eased * 0.4), flashPaint);

    // 3) Outward sparks.
    final sparkPaint = Paint()..color = color.withValues(alpha: 0.9 * fade);
    final whitePaint = Paint()..color = Colors.white.withValues(alpha: fade);
    for (var i = 0; i < _sparkCount; i++) {
      final angle = (i / _sparkCount) * 2 * math.pi;
      final dist = maxR * (0.2 + eased * 0.85);
      final dx = center.dx + math.cos(angle) * dist;
      final dy = center.dy + math.sin(angle) * dist;
      final r = (1.6 + (i.isEven ? 1.4 : 0.6)) * (1 - eased * 0.5);
      canvas.drawCircle(Offset(dx, dy), r, i.isEven ? sparkPaint : whitePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) =>
      old.progress != progress || old.color != color;
}
