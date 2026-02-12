import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../shared/widgets/gradient_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              _buildAnimation(size),
              _buildBottomSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'ASTROLOGY',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ค้นพบดวงชะตาของคุณ',
          style: TextStyle(
            color: AppColors.lightText.withValues(alpha: 0.8),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimation(Size size) {
    return Container(
      width: size.width * 0.7,
      height: size.width * 0.7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 15,
          ),
        ],
      ),
      child: Lottie.asset(
        'assets/animations/horowheel.json',
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Text(
            'ค้นหาความลับของดวงดาว ดูดวง และอ่านไพ่ทาโรต์',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.lightText.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          GradientButton(
            text: 'เริ่มต้นการเดินทาง',
            onPressed: () {
              AppRouter.navigateToReplacement(context, AppRoutes.onboarding);
            },
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            width: double.infinity,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'มีบัญชีอยู่แล้ว? ',
                style: TextStyle(
                  color: AppColors.lightText.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  AppRouter.navigateToReplacement(context, AppRoutes.login);
                },
                child: Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
