import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/app_icons.dart';

class TarotSpreadCard extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final String? svgIconPath;
  final VoidCallback onTap;

  const TarotSpreadCard({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.svgIconPath,
    required this.onTap,
  }) : super(key: key);

  @override
  State<TarotSpreadCard> createState() => _TarotSpreadCardState();
}

class _TarotSpreadCardState extends State<TarotSpreadCard> {
  bool _pressed = false;

  // Pick a soft pastel accent per spread for gentle variety.
  Color get _accent {
    if (widget.title.contains('1')) return AppColors.suitCups; // soft blue
    if (widget.title.contains('3')) return AppColors.majorArcana; // rose
    if (widget.title.contains('กางเขน')) return AppColors.suitPentacles; // green
    if (widget.title.contains('เซลติก')) return AppColors.primary; // lavender
    return AppColors.primary;
  }

  // A short editorial overline label for each spread.
  String get _overline {
    if (widget.title.contains('1')) return 'I · SINGLE';
    if (widget.title.contains('3')) return 'III · PAST · NOW · NEXT';
    if (widget.title.contains('กางเขน')) return 'V · THE CROSS';
    if (widget.title.contains('เซลติก')) return 'X · CELTIC';
    return 'SPREAD';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accent.withValues(alpha: _pressed ? 0.4 : 0.18),
              width: 1,
            ),
            boxShadow: [
              // Soft ambient lift.
              BoxShadow(
                color: accent.withValues(alpha: 0.16),
                blurRadius: 22,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
              // Tight contact shadow for layered depth.
              BoxShadow(
                color: AppColors.deepText.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 118,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.28),
                      AppColors.cream.withValues(alpha: 0.55),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Faint inner top-light for a glassy depth on the header.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.35),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Soft celestial sparkle accents.
                    Positioned(
                      top: 12,
                      right: 16,
                      child: SvgIcon(
                        AppIcons.sparkle,
                        size: 16,
                        color: AppColors.accent.withValues(alpha: 0.85),
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 14,
                      child: SvgIcon(
                        AppIcons.star,
                        size: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.85),
                              Colors.white.withValues(alpha: 0.55),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.55),
                            width: 1.5,
                          ),
                          boxShadow: [
                            // Inner-ish glow halo around the emblem.
                            BoxShadow(
                              color: accent.withValues(alpha: 0.28),
                              blurRadius: 16,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SvgIcon(
                            widget.svgIconPath ?? AppIcons.divination,
                            size: 34,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _overline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fraunces(
                        color: accent.withValues(alpha: 0.85),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.title,
                      style: GoogleFonts.kanit(
                        color: AppColors.deepText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: GoogleFonts.kanit(
                        color: AppColors.mutedText,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'เลือก',
                                style: GoogleFonts.kanit(
                                  color: accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              SvgIcon(
                                AppIcons.arrowForward,
                                size: 12,
                                color: accent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
