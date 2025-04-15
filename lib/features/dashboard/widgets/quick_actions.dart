import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ทางลัด',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickActionButton(
                context,
                icon: Icons.today,
                label: 'ดูดวงวันนี้',
                color: AppColors.zodiacFire,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.dailyHoroscope);
                },
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.shuffle,
                label: 'เปิดไพ่ 1 ใบ',
                color: AppColors.tarotMajor,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.tarotReading);
                },
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.favorite,
                label: 'ดูดวงความรัก',
                color: Colors.pink,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.compatibilityCheck);
                },
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.chat_bubble_outline,
                label: 'แชทใหม่',
                color: AppColors.chatBubble,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.newChat);
                },
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.self_improvement,
                label: 'นั่งสมาธิ',
                color: AppColors.focusMeditation,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.focusSession);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: color.withOpacity(0.5),
                  width: 1.0,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28.0,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
