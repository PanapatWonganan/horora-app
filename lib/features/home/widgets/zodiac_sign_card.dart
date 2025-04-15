import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

class ZodiacSignCard extends StatelessWidget {
  final String name;
  final String? date;
  final String imagePath;
  final IconData icon;
  final VoidCallback onTap;

  const ZodiacSignCard({
    Key? key,
    required this.name,
    this.date,
    required this.imagePath,
    this.icon = Icons.star,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (date != null) ...[
              const SizedBox(height: 4),
              Text(
                date!,
                style: TextStyle(
                  color: AppColors.lightText.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 