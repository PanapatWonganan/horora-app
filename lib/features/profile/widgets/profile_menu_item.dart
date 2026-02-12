import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/app_icons.dart';

class ProfileMenuItem extends StatelessWidget {
  final String? svgIconPath;
  final IconData? icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const ProfileMenuItem({
    Key? key,
    this.svgIconPath,
    this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: svgIconPath != null
                    ? SvgIcon(
                        svgIconPath!,
                        size: 20,
                        color: AppColors.primary,
                      )
                    : Icon(
                        icon ?? Icons.circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                SvgIcon(
                  AppIcons.arrowForward,
                  size: 16,
                  color: AppColors.lightText.withValues(alpha: 0.5),
                ),
          ],
        ),
      ),
    );
  }
}
