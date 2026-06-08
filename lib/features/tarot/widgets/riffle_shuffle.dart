import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_icons.dart';

/// A real riffle-shuffle visualization (two halves of a deck interleaving)
/// driven entirely by an external [progress] value in 0→1.
///
/// This is VISUAL/ANIMATION ONLY. It owns no controllers and no logic — the
/// caller wraps it in an `AnimatedBuilder` over its shuffle animation and feeds
/// the current value in. The three conceptual phases map onto [progress]:
///
///   * split      0.00 → 0.35  — the stacked deck splits into a left + right
///                               half that move apart and tilt outward.
///   * interleave 0.35 → 0.85  — the two halves arc back to centre and the
///                               cards zip together with a per-card stagger,
///                               each landing with a little bounce + rotation.
///   * settle     0.85 → 1.00  — the merged deck squares up with a tiny
///                               overshoot settle.
class RiffleShuffle extends StatelessWidget {
  const RiffleShuffle({
    super.key,
    required this.progress,
    this.cardCount = 12,
    this.cardWidth = 46,
    this.cardHeight = 74,
  });

  /// Shuffle progress, 0 → 1. Supplied by the caller's `_shuffleAnimation`.
  final double progress;

  /// Number of card backs in the riffle. Even split into two halves.
  final int cardCount;
  final double cardWidth;
  final double cardHeight;

  // Smoothstep — cheap easeInOut for a 0→1 sub-range.
  double _smooth(double t) {
    final c = t.clamp(0.0, 1.0);
    return c * c * (3 - 2 * c);
  }

  // easeOutBack — a small overshoot/spring for the landing + settle.
  double _easeOutBack(double t) {
    const s = 1.70158;
    final x = t.clamp(0.0, 1.0) - 1.0;
    return 1.0 + (s + 1) * x * x * x + s * x * x;
  }

  @override
  Widget build(BuildContext context) {
    // The merged stack is ~80px wide, ~96 tall once spread for the split.
    final boardW = cardWidth + 100;
    final boardH = cardHeight + 32;

    return SizedBox(
      width: boardW,
      height: boardH,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: List.generate(cardCount, (i) {
          return _buildCard(i);
        }),
      ),
    );
  }

  Widget _buildCard(int index) {
    // Left half = even indices, right half = odd indices. Within each half the
    // card's "depth" governs its resting offset in the neat stack so the final
    // merged deck looks like a tidy interleaved pile.
    final bool isLeft = index.isEven;
    final int half = index ~/ 2; // 0..(cardCount/2 - 1) within its half.
    final int halfCount = (cardCount / 2).ceil();

    // Per-card stagger so the halves "zip" together rather than snap as one.
    final double stagger = halfCount <= 1 ? 0 : half / (halfCount - 1);

    // Final resting position: a slightly offset neat stack (cascading down a
    // touch so the pile reads as many cards, matching the dealt-stack look).
    final double restY = (index - cardCount / 2) * 0.6;
    final double restX = (index - cardCount / 2) * 0.25;
    const double restAngle = 0.0;

    double dx;
    double dy;
    double angle;
    double scale = 1.0;
    double opacity = 1.0;

    if (progress < 0.35) {
      // ---- SPLIT ---- two halves slide apart + tilt outward.
      final t = _smooth(progress / 0.35);
      final dir = isLeft ? -1.0 : 1.0;
      final spread = 46.0 * t;
      dx = restX + dir * spread;
      dy = restY - 4 * t; // lift a hair off the table as it parts.
      angle = dir * 0.12 * t; // tilt outward.
    } else if (progress < 0.85) {
      // ---- INTERLEAVE ---- each card arcs back to centre with its own
      // phase window so the two halves cascade/zip together.
      final phase = (progress - 0.35) / 0.5; // 0→1 across the interleave.
      // Each card occupies a staggered slice of the interleave window; cards
      // deeper in the half start a touch later -> a travelling "riffle" wave.
      final double start = stagger * 0.45;
      final double localRaw = ((phase - start) / 0.55).clamp(0.0, 1.0);
      final double local = _easeOutBack(localRaw);

      final dir = isLeft ? -1.0 : 1.0;
      final double splitX = restX + dir * 46.0;
      final double splitY = restY - 4;
      final double splitTilt = dir * 0.12;

      // Lerp from the split pose toward the resting (merged) pose.
      dx = splitX + (restX - splitX) * local;
      // Arc: lift through the middle of the travel for a springy riffle.
      final arc = math.sin(localRaw * math.pi) * 10.0;
      dy = splitY + (restY - splitY) * local - arc;
      // Outward tilt resolves toward the resting (flat) angle as it lands.
      angle = restAngle + splitTilt * (1 - local);
      // A quick spin flourish as the card lands, settling to rest.
      angle += dir * 0.18 * math.sin(localRaw * math.pi);
      // Tiny scale pop on landing for a tactile snap.
      scale = 1.0 + 0.06 * math.sin(localRaw * math.pi);
      // Brief opacity trail at the very start of each card's travel — a cheap
      // motion-blur feel without a real blur.
      opacity = 0.55 + 0.45 * _smooth((localRaw / 0.3).clamp(0.0, 1.0));
    } else {
      // ---- SETTLE ---- the merged deck squares up with a small overshoot.
      final t = _easeOutBack((progress - 0.85) / 0.15);
      // Overshoot squeeze: deck compresses then settles into the neat stack.
      final settle = 1 - t;
      dx = restX;
      dy = restY + settle * 3.0;
      angle = restAngle + settle * 0.02 * (isLeft ? -1 : 1);
      scale = 1.0 - settle * 0.03;
    }

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: scale,
            child: _CardBack(width: cardWidth, height: cardHeight),
          ),
        ),
      ),
    );
  }
}

/// A small celestial card back — mystical lavender gradient, thin gold border,
/// and a tiny sparkle — matching the un-revealed deck's look at riffle scale.
class _CardBack extends StatelessWidget {
  const _CardBack({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C5BD0), // deep lavender
            Color(0xFF8B6FE0),
            Color(0xFFB8A6F0),
          ],
        ),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.85),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Faint top sheen for depth.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Central sparkle ring — the deck's signet, shrunk to fit.
            Container(
              width: width * 0.5,
              height: width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.30),
                    Colors.white.withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.85),
                  width: 1.0,
                ),
              ),
              child: const Center(
                child: SvgIcon(
                  AppIcons.sparkle,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
