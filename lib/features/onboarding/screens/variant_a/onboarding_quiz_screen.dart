import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter/material.dart' as material show TimeOfDay;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
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
      body: Container(
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
          child: Column(
            children: [
              // Header with back button and progress
              if (_currentPage > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _previousPage,
                        icon: SvgIcon(AppIcons.arrowBack, size: 20, color: Colors.white),
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SvgIcon(
              AppIcons.sparkleFilled,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),

          const Text(
            'ค้นพบเส้นทางมงคล\nของคุณ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'ตอบคำถามง่ายๆ 4 ข้อ\nเพื่อรับคำทำนายที่เหมาะกับคุณโดยเฉพาะ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'เริ่มต้นการเดินทาง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgIcon(AppIcons.arrowForward, size: 20, color: Colors.white),
                ],
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
          const Text(
            'คุณต้องการเสริมดวง\nด้านไหนมากที่สุด?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เลือก 1 ข้อที่ตรงกับคุณมากที่สุด',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),

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
                      _data = _data.copyWith(primaryInterest: interest);
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
          const Text(
            'วันเกิดของคุณ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เพื่อวิเคราะห์ดวงชะตาตามราศีและปีนักษัตร',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
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
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _data.birthDate != null
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  SvgIcon(
                    AppIcons.calendar,
                    color: _data.birthDate != null
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.5),
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _data.birthDate != null
                        ? _formatThaiDate(_data.birthDate!)
                        : 'แตะเพื่อเลือกวันเกิด',
                    style: TextStyle(
                      color: _data.birthDate != null
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Optional: Birth time
          GestureDetector(
            onTap: () => _selectTime(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _data.birthTime != null
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  SvgIcon(
                    AppIcons.clock,
                    color: Colors.white.withValues(alpha: 0.5),
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
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'ไม่จำเป็นต้องใส่',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
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
            child: ElevatedButton(
              onPressed: _data.birthDate != null ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'ถัดไป',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
          const Text(
            'คุณชอบเสริมดวง\nแบบไหน?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เราจะแนะนำบริการที่เหมาะกับคุณ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Celebration icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700),
                  const Color(0xFFFF8C00),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: SvgIcon(
              AppIcons.sparkleFilled,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'ผลวิเคราะห์ของคุณ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Result cards
          _buildResultCard(
            svgIconPath: AppIcons.starFilled,
            title: 'ราศี',
            value: result.zodiacSign,
          ),
          const SizedBox(height: 12),
          _buildResultCard(
            svgIconPath: AppIcons.dragon,
            title: 'ปีนักษัตร',
            value: result.chineseZodiac,
          ),
          const SizedBox(height: 12),
          _buildResultCard(
            svgIconPath: AppIcons.palette,
            title: 'สีมงคล',
            value: result.luckyColor,
          ),
          const SizedBox(height: 12),
          _buildResultCard(
            svgIconPath: AppIcons.numbers,
            title: 'เลขมงคล',
            value: result.luckyNumber,
          ),
          const SizedBox(height: 24),

          // Fortune preview (blurred/locked)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.secondary.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                SvgIcon(
                  AppIcons.lock,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                const Text(
                  'คำทำนายประจำวันของคุณ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'สมัครสมาชิกเพื่อดูคำทำนายฉบับเต็ม\nและรับการแจ้งเตือนวันมงคล',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // CTA
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'สมัครเพื่อดูคำทำนายเต็ม',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgIcon(svgIconPath, size: 28, color: AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
          const Text(
            'สมัครสมาชิก',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'รับคำทำนายส่วนตัวและการแจ้งเตือนวันมงคล',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
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

          // Continue to register
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                await _abTest.completeOnboarding();
                if (mounted) {
                  // Pass onboarding data to register screen
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.register,
                    arguments: _data,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'สมัครสมาชิกฟรี',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Login option
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: Text(
                'มีบัญชีแล้ว? เข้าสู่ระบบ',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({required String svgIconPath, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: SvgIcon(svgIconPath, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
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
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.darkSurface,
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
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.darkSurface,
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

