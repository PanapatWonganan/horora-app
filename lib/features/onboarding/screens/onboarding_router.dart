import 'package:flutter/material.dart';
import '../services/ab_test_service.dart';
import 'variant_a/onboarding_quiz_screen.dart';

/// Router สำหรับ Onboarding - ใช้ Full Quiz Flow (6 หน้า)
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
    // ใช้ Full Quiz Flow (6 หน้า) เป็นหลัก
    return const OnboardingQuizScreen();
  }
}
