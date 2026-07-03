import 'package:flutter/material.dart';
import '../services/ab_test_service.dart';
import 'conversion/conversion_onboarding_screen.dart';

/// Router สำหรับ Onboarding - ใช้ High-Conversion Flow (11 หน้า)
class OnboardingRouter extends StatefulWidget {
  const OnboardingRouter({Key? key}) : super(key: key);

  @override
  State<OnboardingRouter> createState() => _OnboardingRouterState();
}

class _OnboardingRouterState extends State<OnboardingRouter> {
  @override
  void initState() {
    super.initState();
    // Track that user started onboarding
    ABTestService.instance.trackFunnelStep('onboarding_started');
  }

  @override
  Widget build(BuildContext context) {
    // ใช้ High-Conversion Flow (11 หน้า) เป็นหลัก
    return const ConversionOnboardingScreen();
  }
}
