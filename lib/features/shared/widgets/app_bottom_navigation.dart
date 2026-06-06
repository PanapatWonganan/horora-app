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
        color: AppColors.darkSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                label: 'ไพ่ทาโร่',
              ),
              _buildNavItem(
                context: context,
                index: 2,
                iconPath: AppIcons.chat,
                activeIconPath: AppIcons.chatFilled,
                label: 'สนทนา',
              ),
              _buildNavItem(
                context: context,
                index: 3,
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
    final color = isSelected ? AppColors.primary : AppColors.lightText.withValues(alpha: 0.5);

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

  void _handleNavigation(BuildContext context, int index) {
    // ไม่ต้องนำทางถ้าอยู่ที่แท็บเดียวกันแล้ว
    if (index == currentIndex) return;

    // ใช้เส้นทางที่เหมาะสมกับแต่ละแท็บ
    String route;
    switch (index) {
      case 0:
        route = AppRoutes.home;
        break;
      case 1:
        route = AppRoutes.tarot;
        break;
      case 2:
        route = AppRoutes.chat;
        break;
      case 3:
        route = AppRoutes.profile;
        break;
      default:
        route = AppRoutes.home;
    }

    // นำทางไปยังเส้นทางที่กำหนด พร้อม interstitial ad (70% probability)
    Navigator.pushReplacementNamed(context, route);
  }
}
