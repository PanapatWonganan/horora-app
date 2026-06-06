import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_icons.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                iconPath: AppIcons.home,
                activeIconPath: AppIcons.homeFilled,
                label: 'หน้าหลัก',
              ),
              _buildNavItem(
                context: context,
                index: 1,
                iconPath: AppIcons.sparkle,
                activeIconPath: AppIcons.sparkleFilled,
                label: 'ดูดวง',
              ),
              // ทำบุญ — core feature, raised center tab
              _buildMeritTab(context),
              _buildNavItem(
                context: context,
                index: 3,
                iconPath: AppIcons.chat,
                activeIconPath: AppIcons.chatFilled,
                label: 'สนทนา',
              ),
              _buildNavItem(
                context: context,
                index: 4,
                iconPath: AppIcons.person,
                activeIconPath: AppIcons.personFilled,
                label: 'โปรไฟล์',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String iconPath,
    required String activeIconPath,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.mutedText;

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(
              isSelected ? activeIconPath : iconPath,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ทำบุญ — the core feature: a raised, gold-accented center tab.
  Widget _buildMeritTab(BuildContext context) {
    final isSelected = currentIndex == 2;
    return GestureDetector(
      onTap: () => _handleNavigation(context, 2),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -14),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.lightSurface, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: SvgIcon(AppIcons.pray, size: 26, color: Colors.white),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -10),
            child: Text(
              'ทำบุญ',
              style: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.deepText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // ไม่ต้องนำทางถ้าอยู่ที่แท็บเดียวกันแล้ว
    if (index == currentIndex) return;

    // ใช้เส้นทางที่เหมาะสมกับแต่ละแท็บ (ทำบุญ = core, ตรงกลาง index 2)
    String route;
    switch (index) {
      case 0:
        route = AppRoutes.home;
        break;
      case 1:
        route = AppRoutes.tarot;
        break;
      case 2:
        route = AppRoutes.merit;
        break;
      case 3:
        route = AppRoutes.chat;
        break;
      case 4:
        route = AppRoutes.profile;
        break;
      default:
        route = AppRoutes.home;
    }

    // นำทางไปยังเส้นทางที่กำหนด พร้อม interstitial ad (70% probability)
    Navigator.pushReplacementNamed(context, route);
  }
}
