import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/celestial_effects.dart';
import '../../core/theme/sacred_ui.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/app_icons.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  // Single cheap controller drives the continuous "breathing" hero float and
  // the slow drift of the constellation star dots — disposed below, no jank.
  late final AnimationController _ambient;

  // Fixed constellation: (xFraction, yFraction, sizePx, baseOpacity, isSparkle).
  static const List<List<double>> _stars = <List<double>>[
    [0.14, 0.12, 6, 0.55, 1],
    [0.82, 0.10, 5, 0.45, 0],
    [0.90, 0.26, 4, 0.40, 1],
    [0.08, 0.30, 4, 0.35, 0],
    [0.70, 0.20, 3, 0.50, 0],
    [0.22, 0.62, 4, 0.30, 1],
    [0.86, 0.58, 3, 0.35, 0],
    [0.12, 0.50, 3, 0.28, 0],
  ];

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: celestialBackdrop),
        child: Stack(
          children: [
            // ---- DEPTH: layered ambient glows build a gradient-mesh sky ----
            Positioned(
              top: -size.width * 0.28,
              left: -size.width * 0.22,
              child: CelestialGlow(
                size: size.width * 0.95,
                color: AppColors.primary,
                intensity: 0.30,
              ),
            ),
            Positioned(
              top: size.height * 0.04,
              right: -size.width * 0.30,
              child: CelestialGlow(
                size: size.width * 0.85,
                color: AppColors.secondary,
                intensity: 0.26,
              ),
            ),
            Positioned(
              bottom: -size.width * 0.30,
              left: -size.width * 0.18,
              child: CelestialGlow(
                size: size.width * 0.9,
                color: AppColors.tertiary,
                intensity: 0.24,
              ),
            ),
            Positioned(
              bottom: size.height * 0.10,
              right: -size.width * 0.22,
              child: CelestialGlow(
                size: size.width * 0.6,
                color: AppColors.accent,
                intensity: 0.20,
              ),
            ),

            // ---- DEPTH: drifting constellation of star dots ----
            ..._buildConstellation(size),

            // ---- DEPTH: fine grain lifts flat pastel into atmosphere ----
            const Positioned.fill(child: GrainOverlay(opacity: 0.03)),

            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 36),
                  StaggeredReveal(index: 1, child: _buildHeader()),
                  StaggeredReveal(
                    index: 0,
                    child: _buildAnimation(size),
                  ),
                  _buildBottomSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- DEPTH: constellation that drifts gently with the ambient controller ----
  List<Widget> _buildConstellation(Size size) {
    return [
      for (var i = 0; i < _stars.length; i++)
        AnimatedBuilder(
          animation: _ambient,
          builder: (context, _) {
            final s = _stars[i];
            // Phase-offset each star so they twinkle/drift out of sync.
            final phase = (_ambient.value + i / _stars.length) * 2 * math.pi;
            final drift = math.sin(phase) * 4;
            final twinkle =
                (s[3] * (0.6 + 0.4 * (0.5 + 0.5 * math.sin(phase)))).toDouble();
            final isSparkle = s[4] == 1;
            return Positioned(
              left: size.width * s[0],
              top: size.height * s[1] + drift,
              child: Opacity(
                opacity: twinkle,
                child: SvgIcon(
                  isSparkle ? AppIcons.sparkle : AppIcons.star,
                  size: s[2],
                  color: isSparkle ? AppColors.accent : AppColors.primary,
                ),
              ),
            );
          },
        ),
    ];
  }

  // ---- TYPOGRAPHY: dramatic display brand mark + Thai subtitle ----
  Widget _buildHeader() {
    return Column(
      children: [
        // Small uppercase letter-spaced overline.
        Text(
          'ทำบุญออนไลน์ · บุญถึงมือจริง',
          style: GoogleFonts.kanit(
            color: AppColors.onBackdropMuted.withValues(alpha: 0.88),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.5,
          ),
        ),
        const SizedBox(height: 14),
        // Big display title. Keep it bright on the plum backdrop; the previous
        // dark mystical gradient looked elegant in code but was nearly
        // invisible on-device.
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppColors.onBackdrop,
              AppColors.candleGold,
              AppColors.onBackdrop,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'ฝากมูออนไลน์',
            style: GoogleFonts.kanit(
              color: Colors.white,
              fontSize: 52,
              height: 1.05,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Calm muted Thai subtitle.
        Text(
          'ทำบุญกับวัดและมูลนิธิจริง สบายใจทุกครั้ง',
          style: GoogleFonts.kanit(
            color: AppColors.onBackdropMuted.withValues(alpha: 0.92),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ---- SIGNATURE: haloed horowheel Lottie with continuous breathing float ----
  Widget _buildAnimation(Size size) {
    final diameter = math.min(size.width * 0.72, size.height * 0.42);

    return AnimatedBuilder(
      animation: _ambient,
      builder: (context, child) {
        // Gentle breathing scale + vertical float (cheap sin curves).
        final t = _ambient.value;
        final scale = 1.0 + 0.025 * math.sin(t * 2 * math.pi);
        final dy = 6 * math.sin(t * 2 * math.pi);
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: SizedBox(
        width: diameter * 1.18,
        height: diameter * 1.18,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft radial halo behind the wheel.
            CelestialGlow(
              size: diameter * 1.15,
              color: AppColors.primary,
              intensity: 0.34,
            ),
            CelestialGlow(
              size: diameter * 0.92,
              color: AppColors.secondary,
              intensity: 0.22,
            ),
            // The signature wheel sitting on a luminous disc.
            Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lightSurface.withValues(alpha: 0.95),
                    AppColors.surfaceMuted.withValues(alpha: 0.35),
                    AppColors.surfaceMuted.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.20),
                    blurRadius: 55,
                    spreadRadius: 6,
                  ),
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.16),
                    blurRadius: 70,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Lottie.asset(
                  'assets/animations/horowheel.json',
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- MOTION: staggered CTAs with press feedback (handlers untouched) ----
  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 38),
      child: Column(
        children: [
          StaggeredReveal(
            index: 2,
            child: Text(
              'ร่วมบุญกับวัดและมูลนิธิที่คัดสรรแล้ว '
              'พร้อมรูปถ่ายและใบอนุโมทนาส่งถึงคุณทุกครั้ง\n'
              'มีดวงประจำวันและไพ่ทาโรต์ให้เสริมกำลังใจ',
              textAlign: TextAlign.center,
              style: GoogleFonts.kanit(
                color: AppColors.onBackdropMuted.withValues(alpha: 0.95),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 30),
          StaggeredReveal(
            index: 3,
            child: _PressableScale(
              child: SacredPrimaryButton(
                label: 'เริ่มทำบุญออนไลน์',
                onTap: () {
                  AppRouter.navigateToReplacement(
                      context, AppRoutes.onboarding);
                },
                leadingSvg: AppIcons.sparkle,
                filled: true,
              ),
            ),
          ),
          const SizedBox(height: 18),
          StaggeredReveal(
            index: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'มีบัญชีอยู่แล้ว? ',
                  style: GoogleFonts.kanit(
                    color: AppColors.onBackdropMuted.withValues(alpha: 0.88),
                    fontSize: 14,
                  ),
                ),
                _PressableScale(
                  child: GestureDetector(
                    onTap: () {
                      AppRouter.navigateToReplacement(
                          context, AppRoutes.login);
                    },
                    child: Text(
                      'เข้าสู่ระบบ',
                      style: GoogleFonts.kanit(
                        color: AppColors.candleGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight press-feedback wrapper: scales its child down slightly while
/// pressed. Purely visual — it forwards taps to the child untouched.
class _PressableScale extends StatefulWidget {
  final Widget child;

  const _PressableScale({required this.child});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
