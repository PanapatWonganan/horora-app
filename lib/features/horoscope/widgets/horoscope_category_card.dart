import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

class HoroscopeCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final int rating;
  final VoidCallback onTap;

  const HoroscopeCategoryCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.rating,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                color: AppColors.lightText.withOpacity(0.7),
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: index < rating ? color : color.withOpacity(0.3),
                      size: 16,
                    ),
                  );
                }),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.lightText.withOpacity(0.5),
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 