import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/celestial_effects.dart';
import '../../../core/utils/app_icons.dart';

/// A cinematic "Celestial Ritual" riffle shuffle driven entirely by an external
/// [progress] value in 0→1. VISUAL/ANIMATION ONLY — it owns no controllers and
/// no logic. The caller wraps it in an `AnimatedBuilder` over its shuffle
/// animation and feeds the current value in.
///
/// Instead of a single quick riffle, [progress] is re-mapped into THREE full
/// riffle cycles followed by a final settle, so the user clearly sees the deck
/// shuffled again and again before the energy peaks:
///
///   * cycle 0   0.00 → 0.27  — split → interleave → merge
///   * cycle 1   0.27 → 0.54  — split → interleave → merge (tighter, faster)
///   * cycle 2   0.54 → 0.82  — split → interleave → merge (the big one)
///   * flare     0.82 → 0.92  — the deck squares up in a bright bloom of energy
///   * settle    0.92 → 1.00  — the merged deck breathes back down to rest
///
/// Around the deck a pulsing radial glow breathes with the riffle rhythm,
/// star specks drift + twinkle, a fine grain sits over everything, and the
/// glow/intensity BUILDS toward the flare for a satisfying climax.
class RiffleShuffle extends StatelessWidget {
  const RiffleShuffle({
    super.key,
    required this.progress,
    this.cardCount = 16,
    this.cardWidth = 58,
    this.cardHeight = 92,
  });

  /// Shuffle progress, 0 → 1. Supplied by the caller's `_shuffleAnimation`.
  final double progress;

  /// Number of card backs in the riffle. Even split into two halves.
  final int cardCount;
  final double cardWidth;
  final double cardHeight;

  // The three riffle cycles live before the flare; each is split→merge.
  static const int _cycles = 3;
  static const double _flareStart = 0.82;
  static const double _flarePeak = 0.90;

  // Smoothstep — cheap easeInOut for a 0→1 sub-range.
  static double _smooth(double t) {
    final c = t.clamp(0.0, 1.0);
    return c * c * (3 - 2 * c);
  }

  // easeOutBack — a small overshoot/spring for the landing + settle.
  static double _easeOutBack(double t) {
    const s = 1.70158;
    final x = t.clamp(0.0, 1.0) - 1.0;
    return 1.0 + (s + 1) * x * x * x + s * x * x;
  }

  /// Decompose [progress] into the active riffle cycle and the local 0→1 phase
  /// within that cycle's split→interleave→merge motion. During the flare/settle
  /// the deck is fully merged, so phase resolves to a squared-up pile.
  ({int cycle, double phase, bool merged}) _stage() {
    if (progress >= _flareStart) {
      return (cycle: _cycles - 1, phase: 1.0, merged: true);
    }
    const cycleSpan = _flareStart / _cycles;
    final raw = progress / cycleSpan;
    final cycle = raw.floor().clamp(0, _cycles - 1);
    final phase = (raw - cycle).clamp(0.0, 1.0);
    return (cycle: cycle, phase: phase, merged: false);
  }

  /// 0→1 "energy" envelope that builds across the whole shuffle, spikes at the
  /// flare, then eases off through the settle. Drives glow size + brightness.
  double get _energy {
    if (progress < _flareStart) {
      // Gentle build across the three cycles (each merge nudges it up).
      final base = _smooth(progress / _flareStart) * 0.55;
      // A small ripple synced to each cycle so the glow "breathes" per riffle.
      final s = _stage();
      final breathe = math.sin(s.phase * math.pi) * 0.12;
      return (base + breathe).clamp(0.0, 1.0);
    }
    if (progress < _flarePeak) {
      // Ramp hard into the bloom.
      final t = (progress - _flareStart) / (_flarePeak - _flareStart);
      return 0.55 + 0.45 * _smooth(t);
    }
    // Decay from the peak back to a calm afterglow.
    final t = (progress - _flarePeak) / (1.0 - _flarePeak);
    return 1.0 - 0.55 * _smooth(t);
  }

  @override
  Widget build(BuildContext context) {
    final boardW = cardWidth + 150;
    final boardH = cardHeight + 70;
    final energy = _energy;

    // Flare bloom: a brief bright over-glow as the deck squares up.
    final double flare = (progress >= _flareStart && progress < 1.0)
        ? math.sin(
                ((progress - _flareStart) / (1.0 - _flareStart)).clamp(0.0, 1.0) *
                    math.pi,
              ) *
            (progress < _flarePeak ? 1.0 : 0.85)
        : 0.0;

    return SizedBox(
      width: boardW,
      height: boardH,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ---- ATMOSPHERE: pulsing radial glow that breathes + builds. ----
          Center(
            child: CelestialGlow(
              size: boardW * (0.95 + energy * 0.55),
              color: Color.lerp(
                AppColors.softPlum,
                AppColors.candleGold,
                0.35 + energy * 0.4,
              )!,
              intensity: (0.16 + energy * 0.30).clamp(0.0, 0.6),
            ),
          ),
          // A tighter gold core that blooms at the flare for the climax.
          if (flare > 0.01)
            Center(
              child: CelestialGlow(
                size: cardWidth * (2.2 + flare * 1.6),
                color: AppColors.candleGold,
                intensity: (0.10 + flare * 0.38).clamp(0.0, 0.5),
              ),
            ),

          // ---- DRIFTING STAR SPECKS — twinkle around the deck. ----
          ..._buildSpecks(boardW, boardH, energy),

          // ---- THE DECK ----
          ...List.generate(cardCount, (i) => _buildCard(i)),

          // ---- GRAIN over the whole ritual for atmosphere. ----
          Positioned.fill(
            child: GrainOverlay(opacity: 0.05 + energy * 0.03),
          ),
        ],
      ),
    );
  }

  // Eight specks orbiting the deck; each twinkles on its own phase and the set
  // brightens with the energy envelope (peaking at the flare).
  List<Widget> _buildSpecks(double boardW, double boardH, double energy) {
    const positions = <Offset>[
      Offset(-0.42, -0.34),
      Offset(0.40, -0.30),
      Offset(-0.30, 0.36),
      Offset(0.34, 0.34),
      Offset(-0.48, 0.06),
      Offset(0.47, -0.02),
      Offset(0.04, -0.46),
      Offset(-0.10, 0.46),
    ];
    final specks = <Widget>[];
    for (var i = 0; i < positions.length; i++) {
      final p = positions[i];
      // Each speck twinkles on a phase offset; multiply by the energy build.
      final tw = 0.5 +
          0.5 *
              math.sin(progress * math.pi * (4 + i * 0.7) + i * 1.3);
      final drift = math.sin(progress * math.pi * 2 + i) * 4.0;
      final twinkle = (0.18 + tw * 0.55) * (0.4 + energy * 0.6);
      final isStar = i.isEven;
      final size = (isStar ? 9.0 : 7.0) * (0.8 + tw * 0.5);
      specks.add(
        Positioned(
          left: boardW / 2 + p.dx * boardW + drift - size / 2,
          top: boardH / 2 + p.dy * boardH - drift * 0.5 - size / 2,
          child: Opacity(
            opacity: twinkle.clamp(0.0, 1.0),
            child: SvgIcon(
              isStar ? AppIcons.star : AppIcons.sparkle,
              size: size,
              color: AppColors.candleGold,
            ),
          ),
        ),
      );
    }
    return specks;
  }

  Widget _buildCard(int index) {
    // Left half = even indices, right half = odd indices.
    final bool isLeft = index.isEven;
    final int half = index ~/ 2;
    final int halfCount = (cardCount / 2).ceil();
    final double stagger = halfCount <= 1 ? 0 : half / (halfCount - 1);

    // Final resting position: a slightly offset neat stack.
    final double restY = (index - cardCount / 2) * 0.55;
    final double restX = (index - cardCount / 2) * 0.22;
    const double restAngle = 0.0;

    final stage = _stage();
    final double phase = stage.phase;
    // Later cycles riffle a touch tighter/snappier (less spread) so the
    // sequence reads as the deck being worked harder, then settling.
    final double spreadScale = 1.0 - stage.cycle * 0.16;

    double dx;
    double dy;
    double angle;
    double scale = 1.0;
    double opacity = 1.0;

    if (stage.merged) {
      // ---- FLARE + SETTLE ---- merged deck squares up with a small overshoot
      // and a faint compression as the bloom hits, then breathes back to rest.
      final t = _easeOutBack(
        ((progress - _flareStart) / (1.0 - _flareStart)).clamp(0.0, 1.0),
      );
      final settle = 1 - t;
      // A brief squeeze at the bloom centre for the "charged" climax beat.
      final bloom = math.sin(
            ((progress - _flareStart) / (1.0 - _flareStart)).clamp(0.0, 1.0) *
                math.pi,
          ) *
          (progress < _flarePeak ? 1.0 : 0.7);
      dx = restX;
      dy = restY + settle * 3.0 - bloom * 1.5;
      angle = restAngle + settle * 0.02 * (isLeft ? -1 : 1);
      scale = 1.0 - settle * 0.03 + bloom * 0.04;
    } else if (phase < 0.32) {
      // ---- SPLIT ---- two halves slide apart + tilt outward.
      final t = _smooth(phase / 0.32);
      final dir = isLeft ? -1.0 : 1.0;
      final spread = 52.0 * spreadScale * t;
      dx = restX + dir * spread;
      dy = restY - 5 * t;
      angle = dir * 0.13 * t;
    } else if (phase < 0.86) {
      // ---- INTERLEAVE ---- each card arcs back to centre with its own phase
      // window so the two halves cascade/zip together.
      final local01 = (phase - 0.32) / 0.54; // 0→1 across the interleave.
      final double start = stagger * 0.45;
      final double localRaw = ((local01 - start) / 0.55).clamp(0.0, 1.0);
      final double local = _easeOutBack(localRaw);

      final dir = isLeft ? -1.0 : 1.0;
      final double splitX = restX + dir * 52.0 * spreadScale;
      final double splitY = restY - 5;
      final double splitTilt = dir * 0.13;

      dx = splitX + (restX - splitX) * local;
      final arc = math.sin(localRaw * math.pi) * 12.0;
      dy = splitY + (restY - splitY) * local - arc;
      angle = restAngle + splitTilt * (1 - local);
      angle += dir * 0.20 * math.sin(localRaw * math.pi);
      scale = 1.0 + 0.07 * math.sin(localRaw * math.pi);
      opacity = 0.55 + 0.45 * _smooth((localRaw / 0.3).clamp(0.0, 1.0));
    } else {
      // ---- MERGE ---- the cycle's merged deck squares up with a small
      // overshoot before the next split (or before the flare).
      final t = _easeOutBack((phase - 0.86) / 0.14);
      final settle = 1 - t;
      dx = restX;
      dy = restY + settle * 3.0;
      angle = restAngle + settle * 0.02 * (isLeft ? -1 : 1);
      scale = 1.0 - settle * 0.03;
    }

    // Cards glint brighter as the energy builds toward the flare.
    final double glint = (_energy * 0.5).clamp(0.0, 0.5);

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: scale,
            child: _CardBack(
              width: cardWidth,
              height: cardHeight,
              glint: glint,
            ),
          ),
        ),
      ),
    );
  }
}

/// A celestial card back — mystical lavender gradient, thin gold border, and a
/// sparkle signet — matching the un-revealed deck's look at riffle scale. A
/// [glint] term lifts the gold edge + sheen as the ritual's energy builds.
class _CardBack extends StatelessWidget {
  const _CardBack({
    required this.width,
    required this.height,
    this.glint = 0.0,
  });

  final double width;
  final double height;
  final double glint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
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
          color: AppColors.accent.withValues(alpha: (0.85 + glint * 0.15).clamp(0.0, 1.0)),
          width: 1.0 + glint * 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          // Gold halo that intensifies with the ritual's energy build.
          if (glint > 0.02)
            BoxShadow(
              color: AppColors.candleGold.withValues(alpha: glint * 0.55),
              blurRadius: 10 + glint * 12,
              spreadRadius: glint * 2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
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
                      Colors.white.withValues(alpha: 0.22 + glint * 0.2),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Central sparkle ring — the deck's signet.
            Container(
              width: width * 0.5,
              height: width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.30 + glint * 0.25),
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
                  size: 16,
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
