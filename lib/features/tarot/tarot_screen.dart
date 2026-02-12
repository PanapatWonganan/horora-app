import 'package:flutter/material.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../../core/services/ad_service.dart';
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              const Color(0xFF1A1A2E),
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
            Text(
              'ไพ่ทาโรต์',
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ค้นพบความลึกลับของชีวิต',
              style: TextStyle(
                color: AppColors.lightText.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
        SvgIcon(
          AppIcons.divination,
          size: 48,
        ),
      ],
    );
  }

  Widget _buildIntroduction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgIcon(
                AppIcons.divination,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'ยินดีต้อนรับสู่โลกแห่งไพ่ทาโรต์',
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'ไพ่ทาโรต์เป็นเครื่องมือในการทำนายและให้คำแนะนำที่มีประวัติศาสตร์ยาวนาน ช่วยให้คุณเข้าใจตัวเองและสถานการณ์ในชีวิตได้ลึกซึ้งยิ่งขึ้น',
            style: TextStyle(
              color: AppColors.lightText.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          GradientButton(
            text: 'เริ่มการอ่านไพ่',
            onPressed: () {
              context.navigateWithAd(AppRoutes.tarotReading);
            },
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            icon: SvgIcon(
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
        Text(
          'รูปแบบการอ่านไพ่',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TarotSpreadCard(
                title: 'ไพ่ 1 ใบ',
                description: 'คำตอบรวดเร็วสำหรับคำถามเฉพาะเจาะจง',
                imagePath: 'assets/images/tarot/spread_single.webp',
                onTap: () {
                  context.navigateWithAd(AppRoutes.tarotReading,
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
                  context.navigateWithAd(AppRoutes.tarotReading,
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
                  context.navigateWithAd(AppRoutes.tarotReading,
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
                  context.navigateWithAd(AppRoutes.tarotReading,
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
        Text(
          'การอ่านไพ่ที่บันทึกไว้',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // TODO: Implement saved readings list when data is available
        Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                SvgIcon(
                  AppIcons.bookmarkOutline,
                  size: 48,
                  color: AppColors.lightText.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'ยังไม่มีการอ่านไพ่ที่บันทึกไว้',
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'เมื่อคุณบันทึกการอ่านไพ่ คุณจะสามารถกลับมาดูได้ที่นี่',
                  style: TextStyle(
                    color: AppColors.lightText.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedGradientButton(
                  text: 'เริ่มการอ่านไพ่ใหม่',
                  onPressed: () {
                    context.navigateWithAd(AppRoutes.tarotReading);
                  },
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  icon: SvgIcon(
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
