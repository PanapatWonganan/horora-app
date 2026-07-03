import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shared "Celestial, elevated" visual building blocks for the hero screens.
///
/// These give the Soft Celestial theme real depth and motion instead of flat
/// pastel fills: a layered mesh-ish gradient backdrop, a subtle grain overlay,
/// and a staggered entrance reveal. Pure visual helpers — no logic/state of the
/// app passes through here.

/// A multi-stop "mesh-like" Sacred-Astrology backdrop for full-screen surfaces:
/// a deep temple indigo → night-plum → soft-plum descent (a quiet temple sky at
/// dusk). Layer ambient candle/plum glows (see [CelestialGlow]) on top for the
/// mesh feel. NOT a saturated/neon purple — the stops stay muted and dark so
/// gilt accents and ivory cards read premium against them.
const LinearGradient celestialBackdrop = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF241C35), // deep temple indigo
    Color(0xFF2B2140), // indigo→plum
    Color(0xFF332647), // warm night plum
    Color(0xFF3D2C50), // soft plum glow at the foot
  ],
  stops: [0.0, 0.4, 0.75, 1.0],
);

/// A soft radial pastel glow — drop several at different corners/sizes to build
/// a gradient-mesh atmosphere.
class CelestialGlow extends StatelessWidget {
  final double size;
  final Color color;
  final double intensity;

  const CelestialGlow({
    super.key,
    required this.size,
    required this.color,
    this.intensity = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: intensity),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

/// A fine grain/noise overlay that lifts flat pastel into something with
/// atmosphere (prevents the "flat digital" look). Tile it across the screen
/// behind content with very low opacity.
class GrainOverlay extends StatelessWidget {
  final double opacity;

  const GrainOverlay({super.key, this.opacity = 0.035});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GrainPainter(opacity: opacity),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final double opacity;
  // Fixed seed so the grain is deterministic (no per-frame churn / Random ban).
  static const int _seed = 1340217;

  const _GrainPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(_seed);
    final paint = Paint();
    final count = ((size.width * size.height) / 900).clamp(0, 2600).toInt();
    for (var i = 0; i < count; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final a = opacity * (0.4 + rng.nextDouble() * 0.6);
      // Light gilt/ivory specks read as faint stardust over the deep indigo
      // backdrop (dark ink grain would vanish into the plum).
      paint.color = (rng.nextBool() ? AppColors.candleGold : AppColors.onBackdrop)
          .withValues(alpha: a);
      canvas.drawCircle(Offset(dx, dy), rng.nextDouble() * 0.9 + 0.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => old.opacity != opacity;
}

/// Staggered entrance: fades + slides its child up, with a per-index delay so a
/// column of these reveals top-to-bottom on page load (the skill's "one
/// well-orchestrated page load" moment).
class StaggeredReveal extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;
  final double offsetY;

  const StaggeredReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 90),
    this.duration = const Duration(milliseconds: 560),
    this.offsetY = 28,
  });

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    Future.delayed(widget.baseDelay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, widget.offsetY * (1 - _curve.value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
