import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/app_router.dart';

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
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightText.withOpacity(0.5),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'ไพ่ทาโร่',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'สนทนา',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ],
        onTap: (index) => _handleNavigation(context, index),
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

    // นำทางไปยังเส้นทางที่กำหนด
    AppRouter.navigateToReplacement(context, route);
  }
}
