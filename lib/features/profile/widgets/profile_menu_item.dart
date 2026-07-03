import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/sacred_ui.dart';
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
          border: Border.all(
            color: AppColors.warmCardBorder.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.candleGold.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: svgIconPath != null
                    ? SvgIcon(
                        svgIconPath!,
                        size: 20,
                        color: AppColors.deepGoldBrown,
                      )
                    : Icon(
                        icon ?? Icons.circle,
                        color: AppColors.deepGoldBrown,
                        size: 20,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: SacredText.kanit(
                  color: AppColors.deepText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                SvgIcon(
                  AppIcons.arrowForward,
                  size: 16,
                  color: AppColors.mutedText.withValues(alpha: 0.6),
                ),
          ],
        ),
      ),
    );
  }
}
