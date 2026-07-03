import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_icons.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ทางลัด',
          style: GoogleFonts.kanit(
            color: AppColors.onBackdrop,
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickActionButtonSvg(
                context,
                svgIcon: AppIcons.calendar,
                label: 'ดูดวงวันนี้',
                color: AppColors.zodiacFire,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.dailyHoroscope);
                },
              ),
              _buildQuickActionButtonSvg(
                context,
                svgIcon: AppIcons.sparkle,
                label: 'เปิดไพ่ 1 ใบ',
                color: AppColors.tarotMajor,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.tarotReading);
                },
              ),
              _buildQuickActionButtonSvg(
                context,
                svgIcon: AppIcons.chat,
                label: 'แชทใหม่',
                color: AppColors.chatBubble,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.newChat);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButtonSvg(
    BuildContext context, {
    required String svgIcon,
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
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: SvgIcon(
                  svgIcon,
                  size: 28.0,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: GoogleFonts.kanit(
              color: AppColors.onBackdropMuted,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
