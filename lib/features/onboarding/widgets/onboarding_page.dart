import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/sacred_ui.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;
  final IconData icon;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
    this.icon = Icons.star,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SacredBackground(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildHeader(),
            const Spacer(),
            _buildImage(size),
            const Spacer(),
            _buildContent(),
            // Space for bottom controls
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ASTROLOGY',
            style: SacredText.display(
              fontSize: 24,
              color: AppColors.onBackdrop,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(Size size) {
    return Container(
      width: size.width * 0.8,
      height: size.width * 0.8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withValues(alpha: 0.08),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.18),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          data.icon,
          size: size.width * 0.4,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: SacredText.kanit(
              color: AppColors.onBackdrop,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: SacredText.kanit(
              color: AppColors.onBackdropMuted,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 