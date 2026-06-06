import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/app_icons.dart';
import '../shared/widgets/gradient_button.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import 'widgets/tarot_spread_card.dart';

class TarotScreen extends StatefulWidget {
  const TarotScreen({Key? key}) : super(key: key);

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightBackground,
              AppColors.surfaceMuted,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildIntroduction(),
                const SizedBox(height: 32),
                _buildTarotSpreads(),
                const SizedBox(height: 32),
                _buildSavedReadings(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ไพ่ทาโรต์',
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                const SvgIcon(
                  AppIcons.sparkle,
                  size: 18,
                  color: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'ค้นพบความลึกลับของชีวิต',
              style: GoogleFonts.kanit(
                color: AppColors.mutedText,
                fontSize: 15,
              ),
            ),
          ],
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: AppColors.mysticalGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: SvgIcon(
              AppIcons.divination,
              size: 32,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.kanit(
            color: AppColors.deepText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildIntroduction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightSurface,
            AppColors.cream.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SvgIcon(
                AppIcons.divination,
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ยินดีต้อนรับสู่โลกแห่งไพ่ทาโรต์',
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'ไพ่ทาโรต์เป็นเครื่องมือในการทำนายและให้คำแนะนำที่มีประวัติศาสตร์ยาวนาน ช่วยให้คุณเข้าใจตัวเองและสถานการณ์ในชีวิตได้ลึกซึ้งยิ่งขึ้น',
            style: GoogleFonts.kanit(
              color: AppColors.mutedText,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          GradientButton(
            text: 'เริ่มการอ่านไพ่',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.tarotReading);
            },
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            icon: const SvgIcon(
              AppIcons.arrowForward,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarotSpreads() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('รูปแบบการอ่านไพ่'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TarotSpreadCard(
                title: 'ไพ่ 1 ใบ',
                description: 'คำตอบรวดเร็วสำหรับคำถามเฉพาะเจาะจง',
                imagePath: 'assets/images/tarot/spread_single.webp',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.tarotReading,
                      arguments: {'spreadType': 'single'});
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TarotSpreadCard(
                title: 'ไพ่ 3 ใบ',
                description: 'อดีต ปัจจุบัน และอนาคต',
                imagePath: 'assets/images/tarot/spread_three.webp',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.tarotReading,
                      arguments: {'spreadType': 'three'});
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TarotSpreadCard(
                title: 'ไพ่กางเขน',
                description: 'การวิเคราะห์สถานการณ์อย่างละเอียด',
                imagePath: 'assets/images/tarot/spread_cross.webp',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.tarotReading,
                      arguments: {'spreadType': 'cross'});
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TarotSpreadCard(
                title: 'ไพ่เซลติก',
                description: 'การอ่านไพ่แบบครอบคลุมทุกด้าน',
                imagePath: 'assets/images/tarot/spread_celtic.webp',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.tarotReading,
                      arguments: {'spreadType': 'celtic'});
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSavedReadings() {
    // TODO: Replace with actual saved readings from repository
    // When implementing, replace this with actual data check

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('การอ่านไพ่ที่บันทึกไว้'),
        const SizedBox(height: 16),
        // TODO: Implement saved readings list when data is available
        Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceMuted,
                  ),
                  child: Center(
                    child: SvgIcon(
                      AppIcons.bookmarkOutline,
                      size: 36,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีการอ่านไพ่ที่บันทึกไว้',
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'เมื่อคุณบันทึกการอ่านไพ่ คุณจะสามารถกลับมาดูได้ที่นี่',
                  style: GoogleFonts.kanit(
                    color: AppColors.mutedText,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                OutlinedGradientButton(
                  text: 'เริ่มการอ่านไพ่ใหม่',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.tarotReading);
                  },
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  icon: const SvgIcon(
                    AppIcons.divination,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
