import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/celestial_effects.dart';
import '../../../core/theme/merit_colors.dart';
import '../../../core/utils/app_icons.dart';

/// ──────────────────────────────────────────────────────────────────────────
/// Merit shared UI — "ผ้าไหม + แสงเทียน" (silk + candlelight) design system.
///
/// A faith-centered, premium, trustworthy visual language for the ฝากทำบุญ /
/// online merit-making flow. The mood is a quiet temple at dusk: warm silk
/// gold + amber candlelight over a soft celestial canvas, with calm typography
/// and honest, non-salesy copy.
///
/// Design rules encoded here (so every merit screen stays consistent):
///   • Backdrop: celestial wash + layered candle glows + woven-silk hairlines.
///   • Accent: silk gold → amber gradient ([MeritColors.accentGradient]).
///   • Typography: Fraunces (serif, English overlines/numerals) paired with
///     Kanit (Thai). Generous line-height, gentle letter-spacing.
///   • Copy voice: merit & gratitude, never commerce. We use ร่วมบุญ / คำสั่งบุญ /
///     บุญของฉัน / อนุโมทนา / ดูหลักฐาน — NEVER ซื้อเลย / โปรโมชั่น / แฟลชเซล /
///     ด่วน / เหลือน้อย.
///
/// All widgets here are purely presentational — no business logic, no network,
/// no auth/payment. Real data is passed in by the screens.
/// ──────────────────────────────────────────────────────────────────────────

// ── Brand tokens ────────────────────────────────────────────────────────────

class MeritUI {
  MeritUI._();

  /// Deep candle-ember accent for fine details / serif numerals.
  static const Color ember = AppColors.deepGoldBrown;

  /// Silk gold hairline used as the signature 1px border on premium surfaces.
  static Color silkHairline = Colors.white.withValues(alpha: 0.6);

  /// Standard premium card radius.
  static const double cardRadius = 24;

  /// Soft shadow used on light cards.
  static List<BoxShadow> softShadow({double blur = 14, double y = 8}) => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.07),
          blurRadius: blur,
          offset: Offset(0, y),
        ),
      ];

  /// Warm gold glow used under hero / CTA surfaces.
  static List<BoxShadow> goldGlow({double blur = 22, double y = 12, double alpha = 0.38}) => [
        BoxShadow(
          color: MeritColors.accent.withValues(alpha: alpha),
          blurRadius: blur,
          offset: Offset(0, y),
        ),
      ];

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: MeritColors.accentGradient,
  );

  /// Light pressed-haptic helper.
  static void tapHaptic() {
    HapticFeedback.selectionClick();
  }
}

// ── Backdrop ────────────────────────────────────────────────────────────────

/// Full-screen "silk + candlelight" backdrop: celestial wash, layered candle
/// glows, a faint woven-silk diagonal texture and a fine grain overlay.
///
/// Wrap a screen body in this and stack content on top.
class SilkCandleBackdrop extends StatelessWidget {
  final Widget child;

  /// When true, adds an extra warm candle bloom near the top — used on hero
  /// surfaces (catalog / status). Lighter screens can set false.
  final bool warmHero;

  const SilkCandleBackdrop({
    super.key,
    required this.child,
    this.warmHero = true,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: celestialBackdrop),
      child: Stack(
        children: [
          if (warmHero)
            const Positioned(
              top: -130,
              right: -90,
              child: CelestialGlow(size: 340, color: MeritColors.accent, intensity: 0.40),
            ),
          Positioned(
            top: 200,
            left: -120,
            child: CelestialGlow(
              size: 300,
              color: AppColors.secondary.withValues(alpha: 1),
              intensity: 0.26,
            ),
          ),
          const Positioned(
            bottom: -70,
            right: -70,
            child: CelestialGlow(size: 300, color: AppColors.primary, intensity: 0.16),
          ),
          // Woven-silk diagonal sheen.
          const Positioned.fill(child: IgnorePointer(child: _SilkWeaveOverlay())),
          const Positioned.fill(child: GrainOverlay()),
          child,
        ],
      ),
    );
  }
}

/// Very subtle diagonal "silk weave" — fine parallel sheen lines that catch the
/// candlelight without reading as a pattern. Pure paint, deterministic.
class _SilkWeaveOverlay extends StatelessWidget {
  const _SilkWeaveOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _SilkWeavePainter());
  }
}

class _SilkWeavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const gap = 26.0;
    // Diagonal sheen lines (top-left → bottom-right).
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Typography helpers ──────────────────────────────────────────────────────

/// Small uppercase serif overline above Thai section titles.
///
/// These overlines almost always sit DIRECTLY on the dark celestial backdrop,
/// so they default to a light muted-lilac tone ([AppColors.onBackdropMuted]).
/// Pass [onCard] when the overline lives inside an ivory/cream card, which
/// switches it back to the warm deep-gold-brown ink. An explicit [color] always
/// wins over both.
class MeritOverline extends StatelessWidget {
  final String text;
  final Color? color;
  final bool onCard;

  const MeritOverline(this.text, {super.key, this.color, this.onCard = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.fraunces(
        fontSize: 11,
        color: color ?? (onCard ? MeritColors.accentDark : AppColors.onBackdropMuted),
        fontWeight: FontWeight.w600,
        letterSpacing: 2.8,
      ),
    );
  }
}

/// Section title with optional serif overline + leading icon.
///
/// Section titles on the merit screens are headers placed DIRECTLY on the dark
/// celestial backdrop, so by default the title text uses light ivory
/// ([AppColors.onBackdrop]), the overline uses muted lilac, and the leading
/// icon uses candle gold ([MeritColors.accent]) — all legible on the dark
/// canvas. Pass [onCard] for the rare case where the title sits inside an
/// ivory/cream card, which restores deep ink + deep-gold-brown tones.
class MeritSectionTitle extends StatelessWidget {
  final String title;
  final String? overline;
  final String? icon;
  final Color? iconColor;
  final bool onCard;

  const MeritSectionTitle(
    this.title, {
    super.key,
    this.overline,
    this.icon,
    this.iconColor,
    this.onCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = onCard ? AppColors.deepText : AppColors.onBackdrop;
    final defaultIconColor = onCard ? MeritColors.accentDark : MeritColors.accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overline != null) ...[
          MeritOverline(overline!, onCard: onCard),
          const SizedBox(height: 6),
        ],
        Row(
          children: [
            if (icon != null) ...[
              SvgIcon(icon!, size: 18, color: iconColor ?? defaultIconColor),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.kanit(
                  color: titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Press-scale micro-interaction ───────────────────────────────────────────

class MeritPressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final double pressedScale;

  const MeritPressScale({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.pressedScale = 0.97,
  });

  @override
  State<MeritPressScale> createState() => _MeritPressScaleState();
}

class _MeritPressScaleState extends State<MeritPressScale> {
  bool _pressed = false;

  void _set(bool v) {
    if (mounted && _pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap == null
          ? null
          : () {
              MeritUI.tapHaptic();
              widget.onTap!();
            },
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ── Trust strip ─────────────────────────────────────────────────────────────

/// A single trust signal — soft pastel chip with a check/shield mark.
class MeritTrustChip extends StatelessWidget {
  final String text;
  final String icon;

  const MeritTrustChip({super.key, required this.text, this.icon = AppIcons.checkCircle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: MeritColors.cardBackground.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MeritColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgIcon(icon, size: 15, color: AppColors.success),
          const SizedBox(width: 7),
          Text(
            text,
            style: GoogleFonts.kanit(
              color: AppColors.deepText,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A wrapped set of trust signals. Defaults to the canonical three.
class MeritTrustStrip extends StatelessWidget {
  final List<MeritTrustChip> chips;

  const MeritTrustStrip({super.key, this.chips = _defaults});

  static const List<MeritTrustChip> _defaults = [
    MeritTrustChip(text: 'ส่งภาพ/วิดีโอหลักฐานทุกคำสั่งบุญ', icon: AppIcons.camera),
    MeritTrustChip(text: 'ระบุวัด/มูลนิธิปลายทางชัดเจน', icon: AppIcons.temple),
    MeritTrustChip(text: 'ใบอนุโมทนาพร้อมเลขอ้างอิง', icon: AppIcons.checkCircle),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}

// ── Transparency / fee-split block ──────────────────────────────────────────

class MeritFeeLine {
  final String label;
  final String detail;
  final double fraction; // 0..1, share of the bar
  final Color color;

  const MeritFeeLine({
    required this.label,
    required this.detail,
    required this.fraction,
    required this.color,
  });
}

/// Honest "where your merit goes" block: a stacked proportion bar + line items.
///
/// This is the trust centrepiece — it shows the user that the bulk of their
/// contribution reaches the temple/foundation, with operating costs disclosed
/// openly rather than hidden. Copy stays calm and factual.
class MeritTransparencyBlock extends StatelessWidget {
  final List<MeritFeeLine> lines;
  final String note;

  const MeritTransparencyBlock({
    super.key,
    this.lines = _defaultLines,
    this.note =
        'ดวงใจเปิดเผยการจัดสรรอย่างตรงไปตรงมา ส่วนใหญ่ของยอดร่วมบุญถึงปลายทางจริง',
  });

  static const List<MeritFeeLine> _defaultLines = [
    MeritFeeLine(
      label: 'ปัจจัย/ของถวายถึงวัด·มูลนิธิ',
      detail: 'ค่าของไหว้และปัจจัยทำบุญที่ส่งถึงปลายทาง',
      fraction: 0.80,
      color: Color(0xFFE6A15C),
    ),
    MeritFeeLine(
      label: 'ค่าดำเนินการทีมงาน',
      detail: 'ค่าเดินทาง จัดเตรียม และถ่ายภาพ/วิดีโอหลักฐาน',
      fraction: 0.15,
      color: Color(0xFFCDB7FF),
    ),
    MeritFeeLine(
      label: 'ค่าธรรมเนียมระบบ',
      detail: 'ค่าธรรมเนียมการชำระเงินและดูแลแพลตฟอร์ม',
      fraction: 0.05,
      color: Color(0xFFBEE8FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MeritColors.cardBackground,
        borderRadius: BorderRadius.circular(MeritUI.cardRadius),
        border: Border.all(color: AppColors.divider),
        boxShadow: MeritUI.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SvgIcon(AppIcons.info, size: 18, color: MeritColors.accentDark),
              const SizedBox(width: 8),
              Text(
                'บุญของคุณไปถึงไหน',
                style: GoogleFonts.kanit(
                  color: AppColors.deepText,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stacked proportion bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                for (final l in lines)
                  Expanded(
                    flex: (l.fraction * 1000).round(),
                    child: Container(height: 14, color: l.color),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final l in lines) ...[
            _line(l),
            if (l != lines.last) const SizedBox(height: 14),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SvgIcon(AppIcons.heart, size: 15, color: MeritColors.accentDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note,
                    style: GoogleFonts.kanit(
                      color: AppColors.deepText.withValues(alpha: 0.8),
                      fontSize: 12.5,
                      height: 1.4,
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

  Widget _line(MeritFeeLine l) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 3),
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: l.color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.label,
                style: GoogleFonts.kanit(
                  color: AppColors.deepText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l.detail,
                style: GoogleFonts.kanit(
                  color: AppColors.mutedText,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(l.fraction * 100).round()}%',
          style: GoogleFonts.fraunces(
            color: MeritColors.accentDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Wish input ──────────────────────────────────────────────────────────────

/// A premium, faith-toned wish/dedication input ("คำอธิษฐาน"). Live counter,
/// gentle prompt, candle accent — feels like writing on temple paper.
class MeritWishInput extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final String label;
  final String hint;

  const MeritWishInput({
    super.key,
    required this.controller,
    this.maxLength = 200,
    this.label = 'คำอธิษฐาน',
    this.hint = 'เขียนสิ่งที่ปรารถนา เพื่อให้ทีมงานกล่าวอธิษฐานแทนคุณ…',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MeritColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MeritColors.accent.withValues(alpha: 0.3)),
        boxShadow: MeritUI.softShadow(blur: 10, y: 6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SvgIcon(AppIcons.pray, size: 16, color: MeritColors.accentDark),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.kanit(
                  color: AppColors.deepText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) => Text(
                  '${value.text.characters.length}/$maxLength',
                  style: GoogleFonts.fraunces(
                    color: AppColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            maxLines: 3,
            maxLength: maxLength,
            style: GoogleFonts.kanit(color: AppColors.deepText, fontSize: 14, height: 1.5),
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              hintStyle: GoogleFonts.kanit(color: MeritColors.textHint, fontSize: 13.5, height: 1.5),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: MeritColors.accent.withValues(alpha: 0.6)),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status timeline ─────────────────────────────────────────────────────────

class MeritTimelineStep {
  final String title;
  final String subtitle;
  final String? timestamp;
  final String icon;

  const MeritTimelineStep({
    required this.title,
    required this.subtitle,
    this.timestamp,
    this.icon = AppIcons.checkCircle,
  });
}

/// A vertical, candle-lit progress timeline for a คำสั่งบุญ (merit order).
///
/// Steps up to [currentIndex] read as completed (filled gold node + connector),
/// the current step pulses softly, and future steps are dimmed. Honest, calm,
/// and reassuring — the user always knows exactly where their merit is.
class MeritStatusTimeline extends StatelessWidget {
  final List<MeritTimelineStep> steps;
  final int currentIndex;

  const MeritStatusTimeline({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MeritColors.cardBackground,
        borderRadius: BorderRadius.circular(MeritUI.cardRadius),
        border: Border.all(color: AppColors.divider),
        boxShadow: MeritUI.softShadow(),
      ),
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++)
            _StepRow(
              step: steps[i],
              isFirst: i == 0,
              isLast: i == steps.length - 1,
              done: i < currentIndex,
              active: i == currentIndex,
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatefulWidget {
  final MeritTimelineStep step;
  final bool isFirst;
  final bool isLast;
  final bool done;
  final bool active;

  const _StepRow({
    required this.step,
    required this.isFirst,
    required this.isLast,
    required this.done,
    required this.active,
  });

  @override
  State<_StepRow> createState() => _StepRowState();
}

class _StepRowState extends State<_StepRow> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.active) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _StepRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.active && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reached = widget.done || widget.active;
    final connectorColor =
        widget.done ? MeritColors.accent.withValues(alpha: 0.55) : AppColors.divider;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Node + connectors column.
          Column(
            children: [
              SizedBox(
                height: 2,
                child: widget.isFirst
                    ? const SizedBox()
                    : Container(width: 2, color: connectorColor),
              ),
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  final glow = widget.active ? (0.3 + _pulse.value * 0.5) : 0.0;
                  return Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: reached ? MeritUI.accentGradient : null,
                      color: reached ? null : MeritColors.cardBackground,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: reached
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.divider,
                        width: 1.4,
                      ),
                      boxShadow: widget.active
                          ? [
                              BoxShadow(
                                color: MeritColors.accent.withValues(alpha: glow),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: SvgIcon(
                        widget.done ? AppIcons.checkCircle : widget.step.icon,
                        size: 15,
                        color: reached ? Colors.white : AppColors.mutedText,
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: widget.isLast
                    ? const SizedBox()
                    : Container(width: 2, color: connectorColor),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Text column.
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 22, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.step.title,
                          style: GoogleFonts.kanit(
                            color: reached
                                ? AppColors.deepText
                                : AppColors.mutedText,
                            fontSize: 15.5,
                            fontWeight:
                                widget.active ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (widget.active)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: MeritColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'กำลังดำเนินการ',
                            style: GoogleFonts.kanit(
                              color: MeritColors.accentDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.step.subtitle,
                    style: GoogleFonts.kanit(
                      color: AppColors.mutedText,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  if (widget.step.timestamp != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const SvgIcon(AppIcons.clock, size: 12, color: AppColors.mutedText),
                        const SizedBox(width: 5),
                        Text(
                          widget.step.timestamp!,
                          style: GoogleFonts.fraunces(
                            color: AppColors.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Proof gallery ───────────────────────────────────────────────────────────

class MeritProofItem {
  final String? imageUrl; // network proof image (null → gradient placeholder)
  final bool isVideo;
  final List<Color> placeholderGradient;
  final String? caption;

  const MeritProofItem({
    this.imageUrl,
    this.isVideo = false,
    this.placeholderGradient = const [Color(0xFFF2C879), Color(0xFFFFB0A0)],
    this.caption,
  });
}

/// A grid of merit-delivery proofs ("ดูหลักฐาน"). Tapping opens a fullscreen
/// viewer. Falls back to candle-gradient placeholders when image URLs are not
/// present yet (UI-only mock state).
class MeritProofGallery extends StatelessWidget {
  final List<MeritProofItem> items;

  const MeritProofGallery({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MeritPressScale(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openViewer(context, index),
          child: Hero(
            tag: 'merit-proof-$index',
            child: _ProofThumb(item: item),
          ),
        );
      },
    );
  }

  void _openViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        pageBuilder: (_, __, ___) =>
            _ProofViewer(items: items, initialIndex: initialIndex),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

class _ProofThumb extends StatelessWidget {
  final MeritProofItem item;

  const _ProofThumb({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (item.imageUrl != null)
            Image.network(
              item.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _placeholder(),
            )
          else
            _placeholder(),
          if (item.isVideo)
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
              ),
            ),
          // Silk hairline frame.
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.placeholderGradient,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const SvgIcon(AppIcons.temple, size: 22, color: AppColors.deepText),
        ),
      ),
    );
  }
}

class _ProofViewer extends StatefulWidget {
  final List<MeritProofItem> items;
  final int initialIndex;

  const _ProofViewer({required this.items, required this.initialIndex});

  @override
  State<_ProofViewer> createState() => _ProofViewerState();
}

class _ProofViewerState extends State<_ProofViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_index];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final it = widget.items[i];
              return Center(
                child: Hero(
                  tag: 'merit-proof-$i',
                  child: InteractiveViewer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: it.imageUrl != null
                            ? Image.network(it.imageUrl!, fit: BoxFit.cover)
                            : DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: it.placeholderGradient,
                                  ),
                                ),
                                child: const Center(
                                  child: SvgIcon(AppIcons.temple,
                                      size: 64, color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Close button.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
            ),
          ),
          // Caption + counter.
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 28,
            child: Column(
              children: [
                if (item.caption != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      item.caption!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kanit(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                Text(
                  '${_index + 1} / ${widget.items.length}',
                  style: GoogleFonts.fraunces(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    letterSpacing: 2,
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

// ── Digital อนุโมทนา / proof certificate card ───────────────────────────────

/// A shareable digital "ใบอนุโมทนา" — the emotional + trust payoff after a
/// merit order completes. Reads like a temple certificate: silk-gold frame,
/// destination temple, dedication, timestamp and a reference number, sealed
/// with an อนุโมทนา blessing.
class MeritAnumothanaCard extends StatelessWidget {
  final String templeName;
  final String dedicatedTo;
  final String? wish;
  final String referenceNo;
  final String completedAt;
  final VoidCallback? onShare;
  final VoidCallback? onViewProof;

  const MeritAnumothanaCard({
    super.key,
    required this.templeName,
    required this.dedicatedTo,
    required this.referenceNo,
    required this.completedAt,
    this.wish,
    this.onShare,
    this.onViewProof,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFDF8), Color(0xFFFFF6E9)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: MeritColors.accent.withValues(alpha: 0.55), width: 1.4),
        boxShadow: MeritUI.goldGlow(alpha: 0.22, blur: 26, y: 14),
      ),
      child: Column(
        children: [
          // Header band — candle medallion + blessing.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
            decoration: const BoxDecoration(
              gradient: MeritUI.accentGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: SvgIcon(AppIcons.pray, size: 32, color: AppColors.deepText),
                  ),
                ),
                const SizedBox(height: 12),
                const MeritOverline('Certificate of Merit', color: Color(0xFF5A4326)),
                const SizedBox(height: 6),
                Text(
                  'ใบอนุโมทนาบุญ',
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'สาธุ · ขออนุโมทนาบุญร่วมกัน',
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: Column(
              children: [
                _row('สถานที่ทำบุญปลายทาง', templeName, AppIcons.temple),
                _divider(),
                _row('อุทิศ / ขอพรให้', dedicatedTo, AppIcons.heart),
                if (wish != null && wish!.isNotEmpty) ...[
                  _divider(),
                  _wishRow(wish!),
                ],
                _divider(),
                _row('วันเวลาที่ทำบุญสำเร็จ', completedAt, AppIcons.clock),
                _divider(),
                _row('เลขอ้างอิงใบอนุโมทนา', referenceNo, AppIcons.checkCircle,
                    mono: true),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (onViewProof != null)
                      Expanded(
                        child: _secondaryButton(
                          icon: AppIcons.gallery,
                          label: 'ดูหลักฐาน',
                          onTap: onViewProof!,
                        ),
                      ),
                    if (onViewProof != null && onShare != null)
                      const SizedBox(width: 12),
                    if (onShare != null)
                      Expanded(
                        child: _primaryButton(
                          icon: AppIcons.share,
                          label: 'แบ่งปันอนุโมทนา',
                          onTap: onShare!,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, String icon, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgIcon(icon, size: 15, color: MeritColors.accentDark),
          const SizedBox(width: 10),
          SizedBox(
            width: 124,
            child: Text(
              label,
              style: GoogleFonts.kanit(
                color: AppColors.mutedText,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: mono
                  ? GoogleFonts.fraunces(
                      color: AppColors.deepText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    )
                  : GoogleFonts.kanit(
                      color: AppColors.deepText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wishRow(String wish) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MeritColors.accent.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คำอธิษฐาน',
              style: GoogleFonts.kanit(
                color: AppColors.mutedText,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '“$wish”',
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontSize: 14,
                height: 1.45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: _DashedLine(color: MeritColors.accent.withValues(alpha: 0.3)),
      );

  Widget _primaryButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return MeritPressScale(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: MeritUI.accentGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: MeritUI.goldGlow(blur: 12, y: 6, alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.kanit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return MeritPressScale(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: MeritColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MeritColors.accent.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(icon, size: 16, color: MeritColors.accentDark),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.kanit(
                  color: MeritColors.accentDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  final Color color;

  const _DashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashedLinePainter(color: color)),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 5.0;
    const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(math.min(x + dash, size.width), 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

// ── Sticky CTA bar ──────────────────────────────────────────────────────────

/// A bottom sticky call-to-action used on the order form: shows the live total
/// and a strong "ร่วมบุญ" gradient button, lifted above a frosted gradient
/// scrim so content scrolls cleanly underneath.
class MeritStickyCTA extends StatelessWidget {
  final String priceLabel;
  final String? priceCaption;
  final String ctaLabel;
  final String ctaIcon;
  final VoidCallback onTap;
  final bool enabled;

  const MeritStickyCTA({
    super.key,
    required this.priceLabel,
    required this.ctaLabel,
    required this.onTap,
    this.priceCaption,
    this.ctaIcon = AppIcons.heart,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        16,
        18,
        16 + MediaQuery.of(context).padding.bottom * 0.5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cream.withValues(alpha: 0.0),
            AppColors.cream.withValues(alpha: 0.92),
            AppColors.cream,
          ],
          stops: const [0.0, 0.35, 1.0],
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                priceCaption ?? 'ยอดร่วมบุญ',
                style: GoogleFonts.kanit(
                  color: AppColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                priceLabel,
                style: GoogleFonts.fraunces(
                  color: MeritColors.accentDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: MeritPressScale(
              borderRadius: BorderRadius.circular(18),
              onTap: enabled ? onTap : null,
              child: Opacity(
                opacity: enabled ? 1 : 0.5,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: MeritUI.accentGradient,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                    boxShadow: MeritUI.goldGlow(blur: 16, y: 8, alpha: 0.45),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgIcon(ctaIcon, size: 19, color: Colors.white),
                      const SizedBox(width: 9),
                      Text(
                        ctaLabel,
                        style: GoogleFonts.kanit(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Destination temple banner ───────────────────────────────────────────────

/// Emphasises the real destination (temple/foundation) of a merit order — a
/// premium glass card with the temple medallion, belief, and an optional
/// "verified destination" mark. Used on catalog detail + order screens.
class MeritDestinationBanner extends StatelessWidget {
  final String templeName;
  final String belief;
  final String? subline;
  final bool verified;

  const MeritDestinationBanner({
    super.key,
    required this.templeName,
    required this.belief,
    this.subline,
    this.verified = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: MeritUI.accentGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: MeritUI.silkHairline, width: 1),
        boxShadow: MeritUI.goldGlow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
                ),
                child: const SvgIcon(AppIcons.temple, size: 28, color: AppColors.deepText),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'สถานที่ปลายทาง',
                          style: GoogleFonts.kanit(
                            color: AppColors.deepText.withValues(alpha: 0.7),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (verified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SvgIcon(AppIcons.checkCircle,
                                    size: 11, color: AppColors.success),
                                const SizedBox(width: 4),
                                Text(
                                  'ยืนยันแล้ว',
                                  style: GoogleFonts.kanit(
                                    color: AppColors.success,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      templeName,
                      style: GoogleFonts.kanit(
                        color: AppColors.deepText,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const SvgIcon(AppIcons.sparkle, size: 16, color: AppColors.deepText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    belief,
                    style: GoogleFonts.kanit(
                      color: AppColors.deepText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (subline != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                SvgIcon(AppIcons.clock, size: 14,
                    color: AppColors.deepText.withValues(alpha: 0.75)),
                const SizedBox(width: 6),
                Text(
                  subline!,
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText.withValues(alpha: 0.85),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
