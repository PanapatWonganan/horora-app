import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/app_icons.dart';
import '../shared/widgets/gradient_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightBackground,
              AppColors.mysticalGradient[1].withValues(alpha: 0.45),
              AppColors.cosmicGradient[1].withValues(alpha: 0.35),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Soft celestial sparkle accents
            Positioned(
              top: size.height * 0.10,
              left: 28,
              child: const Opacity(
                opacity: 0.55,
                child: SvgIcon(AppIcons.sparkle,
                    size: 22, color: AppColors.accent),
              ),
            ),
            Positioned(
              top: size.height * 0.16,
              right: 36,
              child: const Opacity(
                opacity: 0.45,
                child: SvgIcon(AppIcons.star,
                    size: 16, color: AppColors.primary),
              ),
            ),
            Positioned(
              top: size.height * 0.30,
              right: 24,
              child: const Opacity(
                opacity: 0.5,
                child: SvgIcon(AppIcons.sparkle,
                    size: 18, color: AppColors.tertiary),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 28),
                  _buildHeader(),
                  _buildAnimation(size),
                  _buildBottomSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ).createShader(bounds),
          child: Text(
            'ASTROLOGY',
            style: GoogleFonts.kanit(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'ค้นพบดวงชะตาของคุณ',
          style: GoogleFonts.kanit(
            color: AppColors.mutedText,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimation(Size size) {
    final diameter = math.min(size.width * 0.7, size.height * 0.42);

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.lightSurface.withValues(alpha: 0.9),
            AppColors.surfaceMuted.withValues(alpha: 0.4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 50,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.18),
            blurRadius: 60,
            spreadRadius: 2,
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
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      child: Column(
        children: [
          Text(
            'ค้นหาความลับของดวงดาว ดูดวง และอ่านไพ่ทาโรต์',
            textAlign: TextAlign.center,
            style: GoogleFonts.kanit(
              color: AppColors.deepText.withValues(alpha: 0.85),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          GradientButton(
            text: 'เริ่มต้นการเดินทาง',
            onPressed: () {
              AppRouter.navigateToReplacement(context, AppRoutes.onboarding);
            },
            icon: const SvgIcon(AppIcons.sparkle, size: 20, color: Colors.white),
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            width: double.infinity,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'มีบัญชีอยู่แล้ว? ',
                style: GoogleFonts.kanit(
                  color: AppColors.mutedText,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  AppRouter.navigateToReplacement(context, AppRoutes.login);
                },
                child: Text(
                  'เข้าสู่ระบบ',
                  style: GoogleFonts.kanit(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
