import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter/material.dart' as material show TimeOfDay;
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/sacred_ui.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/guest_session_service.dart';
import '../../../../core/utils/app_icons.dart';
import '../../models/onboarding_models.dart';
import '../../services/ab_test_service.dart';
import '../../widgets/quiz_option_card.dart';
import '../../widgets/progress_indicator_dots.dart';

typedef FlutterTimeOfDay = material.TimeOfDay;

/// Variant A: Full Quiz Flow (6 หน้า)
/// Flow: Welcome -> Interest -> Birthdate -> Style -> Result -> Register
class OnboardingQuizScreen extends StatefulWidget {
  const OnboardingQuizScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingQuizScreen> createState() => _OnboardingQuizScreenState();
}

class _OnboardingQuizScreenState extends State<OnboardingQuizScreen> {
  final PageController _pageController = PageController();
  final ABTestService _abTest = ABTestService.instance;

  int _currentPage = 0;
  OnboardingData _data = const OnboardingData();

  final int _totalPages = 6;

  @override
  void initState() {
    super.initState();
    _abTest.trackFunnelStep('variant_a_started');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.templeIndigo,
      body: SacredBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and progress
              if (_currentPage > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.onBackdrop.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.onBackdrop.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _previousPage,
                          icon: const SvgIcon(AppIcons.arrowBack,
                              size: 20, color: AppColors.onBackdrop),
                        ),
                      ),
                      Expanded(
                        child: ProgressIndicatorDots(
                          currentIndex: _currentPage,
                          totalCount: _totalPages,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance
                    ],
                  ),
                ),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    _abTest.trackFunnelStep('variant_a_page_$index');
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildInterestPage(),
                    _buildBirthdatePage(),
                    _buildStylePage(),
                    _buildResultPage(),
                    _buildRegisterPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Page 1: Welcome
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo/Icon
          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 36,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.22),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const SvgIcon(
              AppIcons.sparkleFilled,
              size: 58,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),

          Text(
            'ค้นพบเส้นทางมงคล\nของคุณ',
            textAlign: TextAlign.center,
            style: GoogleFonts.kanit(
              color: AppColors.onBackdrop,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'ตอบคำถามง่ายๆ 4 ข้อ\nเพื่อรับคำทำนายที่เหมาะกับคุณโดยเฉพาะ',
            textAlign: TextAlign.center,
            style: GoogleFonts.kanit(
              color: AppColors.onBackdropMuted,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 58,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'เริ่มต้นการเดินทาง',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const SvgIcon(AppIcons.arrowForward,
                        size: 20, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Page 2: Primary Interest
  Widget _buildInterestPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'คุณต้องการเสริมดวง\nด้านไหนมากที่สุด?',
            style: GoogleFonts.kanit(
              color: AppColors.onBackdrop,
              fontSize: 27,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เลือก 1 ข้อที่ตรงกับคุณมากที่สุด',
            style: GoogleFonts.kanit(
              color: AppColors.onBackdropMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),

          Expanded(
            child: ListView.separated(
              itemCount: PrimaryInterest.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final interest = PrimaryInterest.values[index];
                final isSelected = _data.primaryInterest == interest;

                return QuizOptionCard(
                  svgIconPath: interest.svgIconPath,
                  title: interest.thaiName,
                  subtitle: interest.description,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _data = _data.copyWith(interests: {interest});
                    });
                    Future.delayed(const Duration(milliseconds: 300), _nextPage);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Page 3: Birthdate
  Widget _buildBirthdatePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'วันเกิดของคุณ',
            style: GoogleFonts.kanit(
              color: AppColors.onBackdrop,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เพื่อวิเคราะห์ดวงชะตาตามราศีและปีนักษัตร',
            style: GoogleFonts.kanit(
              color: AppColors.onBackdropMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 40),

          // Date display
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _data.birthDate != null
                      ? AppColors.primary
                      : AppColors.divider,
                  width: _data.birthDate != null ? 2 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                        alpha: _data.birthDate != null ? 0.16 : 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SvgIcon(
                    AppIcons.calendar,
                    color: _data.birthDate != null
                        ? AppColors.primary
                        : AppColors.mutedText,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _data.birthDate != null
                        ? _formatThaiDate(_data.birthDate!)
                        : 'แตะเพื่อเลือกวันเกิด',
                    style: GoogleFonts.kanit(
                      color: _data.birthDate != null
                          ? AppColors.deepText
                          : AppColors.mutedText,
                      fontSize: 18,
                      fontWeight: _data.birthDate != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Optional: Birth time
          GestureDetector(
            onTap: () => _selectTime(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _data.birthTime != null
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  SvgIcon(
                    AppIcons.clock,
                    color: _data.birthTime != null
                        ? AppColors.primary
                        : AppColors.mutedText,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _data.birthTime != null
                              ? 'เวลาเกิด: ${_data.birthTime}'
                              : 'เวลาเกิด (ถ้าทราบ)',
                          style: GoogleFonts.kanit(
                            color: AppColors.deepText.withValues(alpha: 0.85),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'ไม่จำเป็นต้องใส่',
                          style: GoogleFonts.kanit(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Continue button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: _data.birthDate != null
                    ? const LinearGradient(colors: AppColors.primaryGradient)
                    : null,
                color: _data.birthDate != null ? null : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(18),
                boxShadow: _data.birthDate != null
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.30),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: _data.birthDate != null ? _nextPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: AppColors.mutedText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'ถัดไป',
                  style: GoogleFonts.kanit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Page 4: Spiritual Style
  Widget _buildStylePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'คุณชอบเสริมดวง\nแบบไหน?',
            style: GoogleFonts.kanit(
              color: AppColors.onBackdrop,
              fontSize: 27,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เราจะแนะนำบริการที่เหมาะกับคุณ',
            style: GoogleFonts.kanit(
              color: AppColors.onBackdropMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),

          Expanded(
            child: ListView.separated(
              itemCount: SpiritualStyle.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final style = SpiritualStyle.values[index];
                final isSelected = _data.spiritualStyle == style;

                return QuizOptionCard(
                  svgIconPath: style.svgIconPath,
                  title: style.thaiName,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _data = _data.copyWith(spiritualStyle: style);
                    });
                    Future.delayed(const Duration(milliseconds: 300), _nextPage);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Page 5: Result Preview
  Widget _buildResultPage() {
    final result = _generateQuizResult();

    // Keep the CTA pinned so desktop/web users can always continue even when
    // Flutter's internal scroll area is hard to drive from a browser canvas.
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),

                // Celebration icon
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accent,
                          AppColors.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.40),
                          blurRadius: 26,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const SvgIcon(
                      AppIcons.sparkleFilled,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  'ผลวิเคราะห์ของคุณ',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                // Result cards
                _buildResultCard(
                  svgIconPath: AppIcons.starFilled,
                  title: 'ราศี',
                  value: result.zodiacSign,
                ),
                const SizedBox(height: 10),
                _buildResultCard(
                  svgIconPath: AppIcons.dragon,
                  title: 'ปีนักษัตร',
                  value: result.chineseZodiac,
                ),
                const SizedBox(height: 10),
                _buildResultCard(
                  svgIconPath: AppIcons.palette,
                  title: 'สีมงคล',
                  value: result.luckyColor,
                ),
                const SizedBox(height: 10),
                _buildResultCard(
                  svgIconPath: AppIcons.numbers,
                  title: 'เลขมงคล',
                  value: result.luckyNumber,
                ),
                const SizedBox(height: 16),

                // Fortune preview (blurred/locked)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.14),
                        AppColors.secondary.withValues(alpha: 0.16),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.lightSurface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const SvgIcon(
                          AppIcons.lock,
                          color: AppColors.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'คำทำนายประจำวันของคุณ',
                        style: GoogleFonts.kanit(
                          color: AppColors.onBackdrop,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'สมัครสมาชิกเพื่อดูคำทำนายฉบับเต็ม\nและรับการแจ้งเตือนวันมงคล',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.kanit(
                          color: AppColors.onBackdropMuted,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Sticky CTA: always visible above the fold.
          SizedBox(
            width: double.infinity,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'สมัครเพื่อดูคำทำนายเต็ม',
                  style: GoogleFonts.kanit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String svgIconPath,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgIcon(svgIconPath, size: 24, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.kanit(
                  color: AppColors.mutedText,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.kanit(
                  color: AppColors.deepText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Page 6: Register
  Widget _buildRegisterPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'สมัครสมาชิก',
            style: GoogleFonts.kanit(
              color: AppColors.onBackdrop,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'รับคำทำนายส่วนตัวและการแจ้งเตือนวันมงคล',
            style: GoogleFonts.kanit(
              color: AppColors.onBackdropMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),

          // Benefits
          _buildBenefitItem(
            svgIconPath: AppIcons.sparkleFilled,
            text: 'ดูดวงรายวันที่วิเคราะห์เฉพาะคุณ',
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            svgIconPath: AppIcons.notification,
            text: 'แจ้งเตือนวันมงคลและเวลาดี',
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            svgIconPath: AppIcons.temple,
            text: 'ทำบุญออนไลน์ สะดวก ได้บุญจริง',
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            svgIconPath: AppIcons.history,
            text: 'บันทึกประวัติการดูดวงและทำบุญ',
          ),

          const Spacer(),

          // Primary CTA: เริ่มใช้งานเลย (guest-first — ค่าเริ่มต้น)
          SizedBox(
            width: double.infinity,
            height: 58,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _startAsGuest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'เริ่มใช้งานเลย',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const SvgIcon(AppIcons.arrowForward,
                        size: 20, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary CTA: สมัครเพื่อบันทึก (ไป RegisterScreen พร้อม onboarding data)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () async {
                await _abTest.completeOnboarding();
                if (mounted) {
                  // ส่ง onboarding data ไป register screen เพื่อ prefill
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.register,
                    arguments: _data,
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.lightSurface,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'สมัครเพื่อบันทึก',
                style: GoogleFonts.kanit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Login option
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: Text(
                'มีบัญชีแล้ว? เข้าสู่ระบบ',
                style: GoogleFonts.kanit(
                  color: AppColors.onBackdropMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// เริ่มใช้งานแบบ guest: บันทึก onboarding ลง local แล้วเข้า Home เลย
  /// (guest-first default — ไม่บังคับสมัครก่อน)
  Future<void> _startAsGuest() async {
    await _abTest.completeOnboarding();
    // birthDate ถูกเก็บใน _data แล้วตอนเลือกวันเกิด (หน้า 3 / _selectDate)
    await GuestSessionService.instance.saveOnboarding(_data);
    await GuestSessionService.instance.markOnboardingCompleted();
    if (mounted) {
      AppRouter.navigateAndClearStack(context, AppRoutes.home);
    }
  }

  Widget _buildBenefitItem({required String svgIconPath, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          child: SvgIcon(svgIconPath, color: AppColors.accent, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.kanit(
              color: AppColors.onBackdrop.withValues(alpha: 0.92),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data.birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      locale: const Locale('th', 'TH'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.lightSurface,
              onSurface: AppColors.deepText,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.lightSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _data = _data.copyWith(birthDate: picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const FlutterTimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.lightSurface,
              onSurface: AppColors.deepText,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.lightSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _data = _data.copyWith(
          birthTime: BirthTime(hour: picked.hour, minute: picked.minute),
        );
      });
    }
  }

  String _formatThaiDate(DateTime date) {
    final thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    return '${date.day} ${thaiMonths[date.month - 1]} ${date.year + 543}';
  }

  QuizResult _generateQuizResult() {
    // Simple zodiac calculation based on birthdate
    if (_data.birthDate == null) {
      return const QuizResult(
        zodiacSign: 'กรุณาใส่วันเกิด',
        chineseZodiac: '-',
        luckyColor: '-',
        luckyNumber: '-',
        luckyDay: '-',
        recommendedTemple: '-',
        fortunePreview: '',
        tips: [],
      );
    }

    final zodiac = _getThaiZodiac(_data.birthDate!);
    final chineseZodiac = _getChineseZodiac(_data.birthDate!.year);

    return QuizResult(
      zodiacSign: zodiac,
      chineseZodiac: chineseZodiac,
      luckyColor: _getLuckyColor(zodiac),
      luckyNumber: _getLuckyNumber(zodiac),
      luckyDay: _getLuckyDay(zodiac),
      recommendedTemple: _getRecommendedTemple(_data.primaryInterest),
      fortunePreview: 'ดวงของคุณกำลังจะเปลี่ยนแปลงในทางที่ดี...',
      tips: ['ทำบุญตักบาตรในวันพฤหัสบดี', 'สวมใส่สีมงคลของคุณ'],
    );
  }

  String _getThaiZodiac(DateTime date) {
    final zodiacs = [
      'มังกร', 'กุมภ์', 'มีน', 'เมษ', 'พฤษภ', 'เมถุน',
      'กรกฎ', 'สิงห์', 'กันย์', 'ตุลย์', 'พิจิก', 'ธนู'
    ];
    // Simplified - actual calculation is more complex
    return 'ราศี${zodiacs[date.month - 1]}';
  }

  String _getChineseZodiac(int year) {
    final animals = [
      'ชวด (หนู)', 'ฉลู (วัว)', 'ขาล (เสือ)', 'เถาะ (กระต่าย)',
      'มะโรง (งูใหญ่)', 'มะเส็ง (งูเล็ก)', 'มะเมีย (ม้า)', 'มะแม (แพะ)',
      'วอก (ลิง)', 'ระกา (ไก่)', 'จอ (หมา)', 'กุน (หมู)'
    ];
    return 'ปี${animals[(year - 4) % 12]}';
  }

  String _getLuckyColor(String zodiac) {
    // Simplified mapping
    return 'สีทอง, สีเหลือง';
  }

  String _getLuckyNumber(String zodiac) {
    return '9, 19, 29';
  }

  String _getLuckyDay(String zodiac) {
    return 'วันพฤหัสบดี';
  }

  String _getRecommendedTemple(PrimaryInterest? interest) {
    switch (interest) {
      case PrimaryInterest.finance:
        return 'วัดระฆังโฆสิตาราม';
      case PrimaryInterest.love:
        return 'ศาลพระตรีมูรติ';
      case PrimaryInterest.career:
        return 'พระพิฆเนศ เซ็นทรัลเวิลด์';
      case PrimaryInterest.health:
        return 'วัดพระศรีมหาอุมาเทวี';
      default:
        return 'ศาลพระพรหม เอราวัณ';
    }
  }
}

