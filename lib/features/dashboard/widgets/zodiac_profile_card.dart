import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ZodiacProfileCard extends StatelessWidget {
  final String zodiacSign;
  final String element;
  final String planet;

  const ZodiacProfileCard({
    Key? key,
    required this.zodiacSign,
    required this.element,
    required this.planet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ivorySilk, AppColors.ricePaper],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: AppColors.warmCardBorder.withValues(alpha: 0.7),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.templeIndigo.withValues(alpha: 0.16),
            blurRadius: 22.0,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Zodiac icon
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: AppColors.zodiacFire.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getZodiacIcon(),
                    color: AppColors.zodiacFire,
                    size: 32.0,
                  ),
                ),
                const SizedBox(width: 16.0),
                // Zodiac info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zodiacSign,
                        style: GoogleFonts.kanit(
                          color: AppColors.deepText,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '21 มีนาคม - 19 เมษายน',
                        style: GoogleFonts.kanit(
                          color: AppColors.mutedText,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit button
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.mutedText,
                  ),
                  onPressed: () {
                    // Navigate to edit profile
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Zodiac details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.local_fire_department,
                    label: 'ธาตุ',
                    value: element,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.public,
                    label: 'ดาวประจำราศี',
                    value: planet,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiLine = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 16.0,
            ),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: GoogleFonts.kanit(
                color: AppColors.softInk,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: GoogleFonts.kanit(
            color: AppColors.deepText,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
          maxLines: isMultiLine ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  IconData _getZodiacIcon() {
    switch (zodiacSign) {
      case 'ราศีเมษ':
        return Icons.filter_vintage;
      case 'ราศีพฤษภ':
        return Icons.spa;
      case 'ราศีเมถุน':
        return Icons.people;
      case 'ราศีกรกฎ':
        return Icons.water;
      case 'ราศีสิงห์':
        return Icons.pets;
      case 'ราศีกันย์':
        return Icons.eco;
      case 'ราศีตุลย์':
        return Icons.balance;
      case 'ราศีพิจิก':
        return Icons.bug_report;
      case 'ราศีธนู':
        return Icons.adjust;
      case 'ราศีมังกร':
        return Icons.terrain;
      case 'ราศีกุมภ์':
        return Icons.waves;
      case 'ราศีมีน':
        return Icons.water_drop;
      default:
        return Icons.star;
    }
  }
} 