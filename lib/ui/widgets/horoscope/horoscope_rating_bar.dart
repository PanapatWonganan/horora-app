import 'package:flutter/material.dart';

class HoroscopeRatingBar extends StatelessWidget {
  final String label;
  final int rating;
  final Color color;
  final int maxRating;

  const HoroscopeRatingBar({
    Key? key,
    required this.label,
    required this.rating,
    required this.color,
    this.maxRating = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Text(
              '$rating/$maxRating',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildRatingBar(),
      ],
    );
  }

  Widget _buildRatingBar() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // Background (unfilled)
                Container(
                  height: 12,
                  color: Colors.grey[300],
                ),
                // Filled rating
                FractionallySizedBox(
                  widthFactor: rating / maxRating,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
