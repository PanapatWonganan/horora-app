import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/app_icons.dart';

class TarotSpreadCard extends StatelessWidget {
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

  // Pick a soft pastel accent per spread for gentle variety.
  Color get _accent {
    if (title.contains('1')) return AppColors.suitCups; // soft blue
    if (title.contains('3')) return AppColors.majorArcana; // rose
    if (title.contains('กางเขน')) return AppColors.suitPentacles; // green
    if (title.contains('เซลติก')) return AppColors.primary; // lavender
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accent.withValues(alpha: 0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.14),
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 8),
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
                        color: Colors.white.withValues(alpha: 0.7),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.55),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgIcon(
                          svgIconPath ?? AppIcons.divination,
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
                    title,
                    style: GoogleFonts.kanit(
                      color: AppColors.deepText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.kanit(
                      color: AppColors.mutedText,
                      fontSize: 13,
                      height: 1.35,
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
    );
  }
} 