import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/app_icons.dart';

class HoroscopeCategoryCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? svgIconPath;
  final Color color;
  final String description;
  final int rating;
  final VoidCallback onTap;

  const HoroscopeCategoryCard({
    Key? key,
    required this.title,
    this.icon,
    this.svgIconPath,
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
              color: Colors.black.withValues(alpha: 0.1),
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
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: svgIconPath != null
                        ? SvgIcon(
                            svgIconPath!,
                            size: 22,
                          )
                        : Icon(
                            icon,
                            color: color,
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
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
                color: AppColors.lightText.withValues(alpha: 0.7),
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
                    child: SvgIcon(
                      index < rating ? AppIcons.starFilled : AppIcons.starOutline,
                      size: 14,
                      color: index < rating ? color : color.withValues(alpha: 0.3),
                    ),
                  );
                }),
                const Spacer(),
                SvgIcon(
                  AppIcons.arrowForward,
                  size: 12,
                  color: AppColors.lightText.withValues(alpha: 0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 