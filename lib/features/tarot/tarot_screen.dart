import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/celestial_effects.dart';
import '../../core/theme/sacred_ui.dart';
import '../../core/utils/app_icons.dart';
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
        decoration: const BoxDecoration(gradient: celestialBackdrop),
        child: Stack(
          children: [
            // Layered celestial atmosphere behind the content.
            const Positioned(
              top: -100,
              right: -80,
              child: CelestialGlow(
                size: 240,
                color: AppColors.primary,
                intensity: 0.28,
              ),
            ),
            const Positioned(
              top: 200,
              left: -90,
              child: CelestialGlow(
                size: 220,
                color: AppColors.secondary,
                intensity: 0.22,
              ),
            ),
            const Positioned(
              bottom: -60,
              right: -40,
              child: CelestialGlow(
                size: 200,
                color: AppColors.tertiary,
                intensity: 0.2,
              ),
            ),
            const Positioned.fill(child: GrainOverlay(opacity: 0.03)),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StaggeredReveal(index: 0, child: _buildHeader()),
                    const SizedBox(height: 24),
                    StaggeredReveal(index: 1, child: _buildIntroduction()),
                    const SizedBox(height: 32),
                    _buildTarotSpreads(),
                    const SizedBox(height: 32),
                    StaggeredReveal(index: 6, child: _buildSavedReadings()),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
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
              'THE ORACLE · ทาโรต์',
              style: GoogleFonts.fraunces(
                color: AppColors.onBackdropMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'ไพ่ทาโรต์',
                  style: GoogleFonts.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
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
                color: AppColors.onBackdropMuted,
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
              // This coin floats directly on the dark celestial backdrop, so
              // a plum shadow barely reads — use a low-alpha candle-gold glow
              // instead.
              BoxShadow(
                color: AppColors.candleGold.withValues(alpha: 0.16),
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

  // Section titles now use the shared SacredSectionTitle (see sacred_ui.dart)
  // instead of a hand-rolled copy, so tarot reads identically to
  // Horoscope/Chat.

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
          SacredPrimaryButton(
            label: 'เริ่มการอ่านไพ่',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.tarotReading);
            },
            trailingSvg: AppIcons.arrowForward,
            filled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTarotSpreads() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SacredSectionTitle('รูปแบบการอ่านไพ่', overline: 'CHOOSE A SPREAD'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StaggeredReveal(
                index: 2,
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StaggeredReveal(
                index: 3,
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
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StaggeredReveal(
                index: 4,
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StaggeredReveal(
                index: 5,
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
        const SacredSectionTitle('การอ่านไพ่ที่บันทึกไว้', overline: 'YOUR ARCHIVE'),
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
              SacredPrimaryButton(
                label: 'เริ่มการอ่านไพ่ใหม่',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.tarotReading);
                },
                trailingSvg: AppIcons.divination,
                filled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
