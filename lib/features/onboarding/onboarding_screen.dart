import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../shared/widgets/gradient_button.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'ดูดวงรายวัน',
      description: 'รับคำทำนายดวงชะตาประจำวันที่แม่นยำ ครอบคลุมทั้งเรื่องความรัก การงาน และสุขภาพ',
      imagePath: 'assets/images/onboarding/horoscope.png',
      backgroundColor: const Color(0xFF1A1A2E),
      icon: Icons.star,
    ),
    OnboardingPageData(
      title: 'อ่านไพ่ทาโรต์',
      description: 'ค้นหาคำตอบและแนวทางในชีวิตผ่านการอ่านไพ่ทาโรต์ที่ลึกซึ้งและแม่นยำ',
      imagePath: 'assets/images/onboarding/tarot.png',
      backgroundColor: const Color(0xFF16213E),
      icon: Icons.auto_awesome,
    ),
    OnboardingPageData(
      title: 'สนทนากับที่ปรึกษาดวงดาว',
      description: 'พูดคุยกับ AI ที่ปรึกษาด้านดวงดาวของเราเพื่อรับคำแนะนำและคำทำนายที่เฉพาะเจาะจงสำหรับคุณ',
      imagePath: 'assets/images/onboarding/chat.png',
      backgroundColor: const Color(0xFF0F3460),
      icon: Icons.chat_bubble_outline,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    // TODO: Save that onboarding is completed
    AppRouter.navigateAndClearStack(context, AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                data: _pages[index],
              );
            },
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Page indicator
            SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppColors.primary,
                dotColor: Colors.white.withOpacity(0.5),
                spacing: 8,
              ),
            ),
            
            // Next/Finish button
            GradientButton(
              text: _currentPage == _pages.length - 1 ? 'เริ่มต้นใช้งาน' : 'ถัดไป',
              onPressed: _nextPage,
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              width: 150,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
} 