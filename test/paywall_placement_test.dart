import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:astrology_app/core/routes/app_router.dart';
import 'package:astrology_app/core/routes/app_routes.dart';
import 'package:astrology_app/features/onboarding/screens/conversion/conversion_onboarding_screen.dart';
import 'package:astrology_app/features/onboarding/screens/conversion/paywall_page.dart';
import 'package:astrology_app/features/onboarding/services/ab_test_service.dart';

/// Covers the PaywallPlacement A/B variant added on top of Task 16's
/// PaywallVariant scaffold (see ab_test_service.dart). Task 19 brief.
///
/// These are ADDITIONAL tests — they do not modify or replace the 4
/// pre-existing conversion_onboarding_test.dart control-path tests, which
/// must keep passing unchanged (see that file).
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // A minimal MaterialApp with a route table so AppRouter.navigateAndClearStack
  // (called by _finishAsGuest) can resolve '/home' without pulling in the
  // real HomeScreen (which needs Firebase/AuthService singletons — avoided in
  // widget tests elsewhere in this suite, e.g. register_guest_resume_test.dart).
  Future<void> pumpOnboarding(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: (settings) {
        // Stub out '/home' only (the real HomeScreen needs Firebase/auth
        // singletons not available in widget tests — same constraint as
        // register_guest_resume_test.dart). Every other route (notably
        // AppRoutes.paywall, which _onRevealLockTapped pushes) goes through
        // the real AppRouter so the deferred-paywall route actually resolves.
        if (settings.name == AppRoutes.home) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('HOME STUB')),
          );
        }
        if (settings.name == '/onboarding-under-test') {
          return MaterialPageRoute(
            builder: (_) => const ConversionOnboardingScreen(),
          );
        }
        return AppRouter.generateRoute(settings);
      },
      initialRoute: '/onboarding-under-test',
    ));
    await tester.pumpAndSettle();
  }

  Future<void> walkToNotifications(WidgetTester tester) async {
    await tester.tap(find.text('เริ่มต้น'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TikTok'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ถัดไป'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('โชคลาภ การเงิน'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ถัดไป'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'พิมพ์ใจ');
    await tester.pumpAndSettle();
    await tester.tap(find.text('ถัดไป'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('แตะเพื่อเลือกวันเกิด'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ถัดไป'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('สัปดาห์ละครั้ง'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ดูแนวทางของฉัน'));
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('YOUR GUIDANCE'), findsOneWidget);
    await tester.tap(find.text('ดูแนวทางทั้งหมด'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ดำเนินการต่อ'));
    await tester.pumpAndSettle();
  }

  group('ABTestService.getPaywallPlacement', () {
    test('defaults to onboardingEnd when kPaywallDeferredWeight is 0.0', () async {
      final placement = await ABTestService.instance.getPaywallPlacement();
      expect(placement, PaywallPlacement.onboardingEnd);
      expect(kPaywallDeferredWeight, 0.0);
    });

    test('persists a forced placement across cache resets', () async {
      await ABTestService.instance
          .setPaywallPlacement(PaywallPlacement.afterFirstReading);
      expect(await ABTestService.instance.getPaywallPlacement(),
          PaywallPlacement.afterFirstReading);

      // Simulate a fresh app start: re-reads from SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('paywall_ab_placement'), 'afterFirstReading');
    });

    test('reset() clears the persisted placement', () async {
      await ABTestService.instance
          .setPaywallPlacement(PaywallPlacement.afterFirstReading);
      await ABTestService.instance.reset();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('paywall_ab_placement'), isNull);
    });
  });

  group('onboardingEnd placement (control path)', () {
    testWidgets('reaching the last page shows the paywall page as before',
        (tester) async {
      await ABTestService.instance
          .setPaywallPlacement(PaywallPlacement.onboardingEnd);
      await pumpOnboarding(tester);
      await walkToNotifications(tester);

      await tester.tap(find.text('ไว้ทีหลัง'));
      await tester.pumpAndSettle();

      expect(find.text('฿599'), findsOneWidget);
      expect(find.text('เริ่มทดลองฟรี 7 วัน'), findsOneWidget);
    });

    testWidgets('reveal-card lock is inert (no navigation) for onboardingEnd',
        (tester) async {
      await ABTestService.instance
          .setPaywallPlacement(PaywallPlacement.onboardingEnd);
      await pumpOnboarding(tester);

      await tester.tap(find.text('เริ่มต้น'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TikTok'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('โชคลาภ การเงิน'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'พิมพ์ใจ');
      await tester.pumpAndSettle();
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('แตะเพื่อเลือกวันเกิด'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('สัปดาห์ละครั้ง'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ดูแนวทางของฉัน'));
      for (var i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('YOUR GUIDANCE'), findsOneWidget);

      // Tap the reveal-card lock — should do nothing (still on this screen,
      // no DeferredPaywallScreen pushed).
      await tester.tap(find.text('🔒 ดูฉบับเต็ม'));
      await tester.pumpAndSettle();
      expect(find.text('YOUR GUIDANCE'), findsOneWidget);
      expect(find.byType(DeferredPaywallScreen), findsNothing);
    });
  });

  group('afterFirstReading placement (deferred path)', () {
    testWidgets(
        'onboarding skips the paywall page and finishes as guest to home',
        (tester) async {
      await ABTestService.instance
          .setPaywallPlacement(PaywallPlacement.afterFirstReading);
      await pumpOnboarding(tester);
      await walkToNotifications(tester);

      await tester.tap(find.text('ไว้ทีหลัง'));
      await tester.pumpAndSettle();

      // No paywall content anywhere — onboarding finished straight to home.
      expect(find.text('฿599'), findsNothing);
      expect(find.text('เริ่มทดลองฟรี 7 วัน'), findsNothing);
      expect(find.text('HOME STUB'), findsOneWidget);
    });

    testWidgets(
        'reveal-card lock opens the deferred paywall as a full-screen route',
        (tester) async {
      await ABTestService.instance
          .setPaywallPlacement(PaywallPlacement.afterFirstReading);
      await pumpOnboarding(tester);

      await tester.tap(find.text('เริ่มต้น'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TikTok'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('โชคลาภ การเงิน'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'พิมพ์ใจ');
      await tester.pumpAndSettle();
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('แตะเพื่อเลือกวันเกิด'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('สัปดาห์ละครั้ง'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ดูแนวทางของฉัน'));
      for (var i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('YOUR GUIDANCE'), findsOneWidget);

      // Tap the reveal-card lock — this is the first full-version lock the
      // user reaches, so it should open the deferred paywall.
      await tester.tap(find.text('🔒 ดูฉบับเต็ม'));
      await tester.pumpAndSettle();

      expect(find.byType(DeferredPaywallScreen), findsOneWidget);
      expect(find.text('฿599'), findsOneWidget);
      expect(find.text('เริ่มทดลองฟรี 7 วัน'), findsOneWidget);

      // Skip from the deferred modal pops back cleanly to onboarding — the
      // reveal-card screen underneath, not the finished/home state.
      await tester.tap(find.text('ข้ามไปก่อน'));
      await tester.pumpAndSettle();

      expect(find.byType(DeferredPaywallScreen), findsNothing);
      expect(find.text('YOUR GUIDANCE'), findsOneWidget);
      expect(find.text('HOME STUB'), findsNothing);
    });

    testWidgets('close (X) from the deferred modal also returns cleanly',
        (tester) async {
      await ABTestService.instance
          .setPaywallPlacement(PaywallPlacement.afterFirstReading);
      await pumpOnboarding(tester);

      await tester.tap(find.text('เริ่มต้น'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TikTok'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('โชคลาภ การเงิน'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'พิมพ์ใจ');
      await tester.pumpAndSettle();
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('แตะเพื่อเลือกวันเกิด'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('สัปดาห์ละครั้ง'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ดูแนวทางของฉัน'));
      for (var i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.tap(find.text('🔒 ดูฉบับเต็ม'));
      await tester.pumpAndSettle();
      expect(find.byType(DeferredPaywallScreen), findsOneWidget);

      await tester.tap(find.text('✕'));
      await tester.pumpAndSettle();

      expect(find.byType(DeferredPaywallScreen), findsNothing);
      expect(find.text('YOUR GUIDANCE'), findsOneWidget);
    });
  });
}
