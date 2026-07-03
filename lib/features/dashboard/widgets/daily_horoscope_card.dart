import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DailyHoroscopeCard extends StatelessWidget {
  final String date;
  final String overview;
  final int loveRating;
  final int careerRating;
  final int healthRating;
  final String luckyNumber;
  final String luckyColor;

  const DailyHoroscopeCard({
    Key? key,
    required this.date,
    required this.overview,
    required this.loveRating,
    required this.careerRating,
    required this.healthRating,
    required this.luckyNumber,
    required this.luckyColor,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22.0),
                topRight: Radius.circular(22.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ดวงประจำวัน',
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.kanit(
                    color: AppColors.mutedText,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          
          // Overview
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ภาพรวม',
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  overview,
                  style: GoogleFonts.kanit(
                    color: AppColors.mutedText,
                    fontSize: 14.0,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 16.0),
                
                // Ratings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRatingItem('ความรัก', loveRating, AppColors.accent),
                    _buildRatingItem(
                        'การงาน', careerRating, AppColors.deepGoldBrown),
                    _buildRatingItem(
                        'สุขภาพ', healthRating, AppColors.bodhiGreen),
                  ],
                ),
                
                const SizedBox(height: 16.0),
                
                // Lucky items
                Row(
                  children: [
                    Expanded(
                      child: _buildLuckyItem(
                        icon: Icons.format_list_numbered,
                        label: 'เลขนำโชค',
                        value: luckyNumber,
                      ),
                    ),
                    Expanded(
                      child: _buildLuckyItem(
                        icon: Icons.color_lens,
                        label: 'สีมงคล',
                        value: luckyColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16.0),
                
                // View full horoscope button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to full horoscope
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepGoldBrown,
                      side: BorderSide(
                          color: AppColors.candleGold.withValues(alpha: 0.7),
                          width: 1.2),
                      backgroundColor:
                          AppColors.candleGold.withValues(alpha: 0.10),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: Text(
                      'ดูดวงเพิ่มเติม',
                      style: GoogleFonts.kanit(
                        color: AppColors.deepGoldBrown,
                        fontWeight: FontWeight.w600,
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

  Widget _buildRatingItem(String label, int rating, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.kanit(
            color: AppColors.softInk,
            fontSize: 12.0,
          ),
        ),
        const SizedBox(height: 4.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: index < rating ? color : AppColors.divider,
              size: 16.0,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLuckyItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20.0,
        ),
        const SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.kanit(
                color: AppColors.softInk,
                fontSize: 12.0,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 