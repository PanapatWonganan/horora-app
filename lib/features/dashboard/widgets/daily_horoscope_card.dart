import 'package:flutter/material.dart';
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
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: AppColors.darkSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ดวงประจำวัน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
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
                const Text(
                  'ภาพรวม',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  overview,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14.0,
                  ),
                ),
                
                const SizedBox(height: 16.0),
                
                // Ratings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRatingItem('ความรัก', loveRating, Colors.pink),
                    _buildRatingItem('การงาน', careerRating, Colors.blue),
                    _buildRatingItem('สุขภาพ', healthRating, Colors.green),
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
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: const Text('ดูดวงเพิ่มเติม'),
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
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12.0,
          ),
        ),
        const SizedBox(height: 4.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: index < rating ? color : Colors.grey[600],
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
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12.0,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
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