import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// A/B Test Variants สำหรับ Onboarding
enum OnboardingVariant {
  variantA, // Full Quiz Flow (6 หน้า)
  variantB, // Simple 3-Step Flow
}

/// A/B Test Variants สำหรับ Paywall (screen 11 of the conversion flow).
///
/// `control` = today's paywall exactly as shipped (hard "ข้ามไปก่อน" skip,
/// no extra copy). `softGate` = same paywall plus one small secondary line
/// under the CTA nudging a free daily reading. See [kPaywallSoftGateWeight]
/// for the rollout weighting.
enum PaywallVariant {
  control,
  softGate,
}

/// Rollout weight for [PaywallVariant.softGate], as a fraction 0.0–1.0.
///
/// IMPORTANT: this is pinned to 0.0 (100% control) so shipping this scaffold
/// does NOT change production behavior. To run the experiment, the team
/// edits this single constant (e.g. 0.5 for a 50/50 split) and ships a new
/// build — new installs will then be randomly assigned per this weight.
/// Existing installs keep whatever variant they were already assigned
/// (see [ABTestService.getPaywallVariant]).
const double kPaywallSoftGateWeight = 0.0;

/// Debug-only override to preview [PaywallVariant.softGate] without touching
/// [kPaywallSoftGateWeight]. Only ever honored when `kDebugMode` is true, so
/// this can never affect release builds.
///
/// Preview it by launching with:
///   flutter run --dart-define=PREVIEW_PAYWALL_VARIANT=softGate
/// Any other value (or omitting the flag) falls back to normal assignment.
const String _kPreviewPaywallVariantDefine =
    String.fromEnvironment('PREVIEW_PAYWALL_VARIANT');

/// Service สำหรับจัดการ A/B Testing
class ABTestService {
  static final ABTestService _instance = ABTestService._internal();
  static ABTestService get instance => _instance;

  ABTestService._internal();

  static const String _onboardingVariantKey = 'onboarding_ab_variant';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _conversionTrackedKey = 'conversion_tracked';
  static const String _paywallVariantKey = 'paywall_ab_variant';

  OnboardingVariant? _cachedVariant;
  PaywallVariant? _cachedPaywallVariant;

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

  /// กำหนด/อ่าน Paywall Variant สำหรับผู้ใช้ (assigned once, then persisted).
  ///
  /// Weighting comes from [kPaywallSoftGateWeight] — currently 0.0, so this
  /// always resolves to [PaywallVariant.control] in production. In debug
  /// builds only, [_kPreviewPaywallVariantDefine] can force a variant for
  /// local preview without touching the weight constant.
  Future<PaywallVariant> getPaywallVariant() async {
    if (_cachedPaywallVariant != null) return _cachedPaywallVariant!;

    if (kDebugMode && _kPreviewPaywallVariantDefine.isNotEmpty) {
      final forced = PaywallVariant.values.where(
        (v) => v.name == _kPreviewPaywallVariantDefine,
      );
      if (forced.isNotEmpty) {
        _cachedPaywallVariant = forced.first;
        debugPrint(
            'AB Test: Paywall variant forced via dart-define -> ${forced.first.name}');
        return _cachedPaywallVariant!;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_paywallVariantKey);

    if (saved != null) {
      _cachedPaywallVariant = PaywallVariant.values.firstWhere(
        (v) => v.name == saved,
        orElse: () => PaywallVariant.control,
      );
    } else {
      _cachedPaywallVariant =
          Random().nextDouble() < kPaywallSoftGateWeight
              ? PaywallVariant.softGate
              : PaywallVariant.control;
      await prefs.setString(_paywallVariantKey, _cachedPaywallVariant!.name);
      debugPrint(
          'AB Test: Assigned paywall variant ${_cachedPaywallVariant!.name}');
    }

    return _cachedPaywallVariant!;
  }

  /// Force set paywall variant (สำหรับ testing).
  Future<void> setPaywallVariant(PaywallVariant variant) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paywallVariantKey, variant.name);
    _cachedPaywallVariant = variant;
    debugPrint('AB Test: Force set paywall variant ${variant.name}');
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

  /// Track a paywall funnel event, tagged with the paywall variant.
  ///
  /// Trigger points (fired from the paywall page in
  /// conversion_onboarding_screen.dart): paywall_shown,
  /// paywall_plan_selected, paywall_start_trial_tapped, paywall_skipped,
  /// paywall_closed.
  ///
  /// Lands in the same place as [trackFunnelStep] today (debugPrint only) —
  /// wiring a real analytics backend (Firebase/Mixpanel/etc.) is a TODO.
  Future<void> trackPaywallEvent(String eventName, {String? detail}) async {
    final variant = await getPaywallVariant();
    final suffix = detail != null ? ', detail=$detail' : '';
    debugPrint(
        'AB Test Paywall: variant=${variant.name}, event=$eventName$suffix');

    // TODO: ส่งไป Analytics (Firebase, Mixpanel, etc.)
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
    await prefs.remove(_paywallVariantKey);
    _cachedVariant = null;
    _cachedPaywallVariant = null;
    debugPrint('AB Test: Reset all data');
  }

  /// Get A/B test report
  Future<Map<String, dynamic>> getReport() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'variant': _cachedVariant?.name ?? 'not_assigned',
      'paywall_variant': _cachedPaywallVariant?.name ?? 'not_assigned',
      'onboarding_completed': prefs.getBool(_onboardingCompletedKey) ?? false,
      'conversion_tracked': prefs.getBool(_conversionTrackedKey) ?? false,
    };
  }
}
