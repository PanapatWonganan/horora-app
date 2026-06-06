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
    // Stronger contrast: selected = brand lavender, unselected = a deeper
    // muted ink (not the faint #8A82A0) so icons keep presence on white.
    final color =
        isSelected ? AppColors.primary : const Color(0xFF6E6688);

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected items sit on a soft lavender pill for a premium,
            // clearly-active feel.
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SvgIcon(
                isSelected ? activeIconPath : iconPath,
                size: 26,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Deeper, richer gold ramp so a pure-white glyph reads with
                // strong contrast (the old #F2C879→peach was too pale).
                gradient: const LinearGradient(
                  colors: [Color(0xFFF6B544), Color(0xFFE89A3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.lightSurface, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE89A3C).withValues(alpha: 0.50),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              // Clean single-stroke temple glyph in pure white with a subtle
              // shadow halo — clearly visible and intentional on the gold tab.
              // (The old pray.svg was an 80x80 multi-colour illustration whose
              // colorFilter flattened it into an invisible white blob.)
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8A5A14).withValues(alpha: 0.30),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const SvgIcon(
                    AppIcons.temple,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -10),
            child: Text(
              'ทำบุญ',
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFD98A2B)
                    : AppColors.deepText,
                fontSize: 11.5,
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
