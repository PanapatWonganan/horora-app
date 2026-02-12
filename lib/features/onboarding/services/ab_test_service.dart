import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// A/B Test Variants สำหรับ Onboarding
enum OnboardingVariant {
  variantA, // Full Quiz Flow (6 หน้า)
  variantB, // Simple 3-Step Flow
}

/// Service สำหรับจัดการ A/B Testing
class ABTestService {
  static final ABTestService _instance = ABTestService._internal();
  static ABTestService get instance => _instance;

  ABTestService._internal();

  static const String _onboardingVariantKey = 'onboarding_ab_variant';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _conversionTrackedKey = 'conversion_tracked';

  OnboardingVariant? _cachedVariant;

  /// กำหนด Variant สำหรับผู้ใช้ใหม่ (50/50 split)
  /// TODO: เปลี่ยนกลับเป็น random เมื่อ production
  Future<OnboardingVariant> getOnboardingVariant() async {
    if (_cachedVariant != null) return _cachedVariant!;

    final prefs = await SharedPreferences.getInstance();
    final savedVariant = prefs.getString(_onboardingVariantKey);

    if (savedVariant != null) {
      _cachedVariant = OnboardingVariant.values.firstWhere(
        (v) => v.name == savedVariant,
        orElse: () => OnboardingVariant.variantA,
      );
    } else {
      // TODO: Uncomment for production (50/50 random split)
      // _cachedVariant = Random().nextBool()
      //     ? OnboardingVariant.variantA
      //     : OnboardingVariant.variantB;

      // Force Variant A for testing (6 หน้า)
      _cachedVariant = OnboardingVariant.variantA;

      await prefs.setString(_onboardingVariantKey, _cachedVariant!.name);
      debugPrint('AB Test: Assigned variant ${_cachedVariant!.name}');
    }

    return _cachedVariant!;
  }

  /// Force set variant (สำหรับ testing)
  Future<void> setVariant(OnboardingVariant variant) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_onboardingVariantKey, variant.name);
    _cachedVariant = variant;
    debugPrint('AB Test: Force set variant ${variant.name}');
  }

  /// Track conversion (สมัครสมาชิกสำเร็จ)
  Future<void> trackConversion() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyTracked = prefs.getBool(_conversionTrackedKey) ?? false;

    if (!alreadyTracked) {
      final variant = await getOnboardingVariant();

      // Log conversion event
      debugPrint('AB Test Conversion: variant=${variant.name}');

      // TODO: ส่งไป Analytics (Firebase, Mixpanel, etc.)
      // await FirebaseAnalytics.instance.logEvent(
      //   name: 'onboarding_conversion',
      //   parameters: {
      //     'variant': variant.name,
      //     'timestamp': DateTime.now().toIso8601String(),
      //   },
      // );

      await prefs.setBool(_conversionTrackedKey, true);
    }
  }

  /// Track funnel step
  Future<void> trackFunnelStep(String stepName) async {
    final variant = await getOnboardingVariant();
    debugPrint('AB Test Funnel: variant=${variant.name}, step=$stepName');

    // TODO: ส่งไป Analytics
  }

  /// Track drop-off
  Future<void> trackDropOff(String stepName) async {
    final variant = await getOnboardingVariant();
    debugPrint('AB Test DropOff: variant=${variant.name}, step=$stepName');

    // TODO: ส่งไป Analytics
  }

  /// Check if onboarding completed
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    await trackFunnelStep('onboarding_completed');
  }

  /// Reset for testing
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingVariantKey);
    await prefs.remove(_onboardingCompletedKey);
    await prefs.remove(_conversionTrackedKey);
    _cachedVariant = null;
    debugPrint('AB Test: Reset all data');
  }

  /// Get A/B test report
  Future<Map<String, dynamic>> getReport() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'variant': _cachedVariant?.name ?? 'not_assigned',
      'onboarding_completed': prefs.getBool(_onboardingCompletedKey) ?? false,
      'conversion_tracked': prefs.getBool(_conversionTrackedKey) ?? false,
    };
  }
}
