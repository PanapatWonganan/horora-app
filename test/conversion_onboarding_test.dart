import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:astrology_app/features/onboarding/screens/conversion/conversion_onboarding_screen.dart';
import 'package:astrology_app/features/onboarding/screens/conversion/conversion_widgets.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pump(WidgetTester tester) async {
    // Drive at a realistic phone viewport so layouts match the design target.
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      home: ConversionOnboardingScreen(),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('welcome screen renders hero copy and primary CTA',
      (tester) async {
    await pump(tester);
    expect(find.text('ทำบุญ ดูดวง\nอย่างสบายใจ'), findsOneWidget);
    expect(find.text('เริ่มต้น'), findsOneWidget);
    expect(find.text('WELCOME'), findsOneWidget);
  });

  testWidgets('next is gated until a referral source is chosen', (tester) async {
    await pump(tester);

    // Go to screen 2 (how did you hear)
    await tester.tap(find.text('เริ่มต้น'));
    await tester.pumpAndSettle();
    expect(find.text('คุณรู้จักเรา\nจากที่ไหน?'), findsOneWidget);

    // CTA exists but is disabled (no selection yet): tapping does not advance.
    await tester.tap(find.text('ถัดไป'));
    await tester.pumpAndSettle();
    expect(find.text('คุณรู้จักเรา\nจากที่ไหน?'), findsOneWidget);

    // Select a source, then it advances to the goal screen.
    await tester.tap(find.text('TikTok'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ถัดไป'));
    await tester.pumpAndSettle();
    expect(find.text('ตอนนี้ คุณอยากเสริม\nเรื่องใดมากที่สุด?'), findsOneWidget);
  });

  testWidgets('goal screen supports multi-select', (tester) async {
    await pump(tester);
    await tester.tap(find.text('เริ่มต้น'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TikTok'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ถัดไป'));
    await tester.pumpAndSettle();

    // Pick two goals — both tiles report selected via Semantics.
    await tester.tap(find.text('โชคลาภ การเงิน'));
    await tester.tap(find.text('ความรัก'));
    await tester.pumpAndSettle();

    final selectedTiles = tester
        .widgetList<CvGoalTile>(find.byType(CvGoalTile))
        .where((t) => t.selected)
        .length;
    expect(selectedTiles, 2);
  });

  testWidgets('walks the full flow to the paywall with no overflow',
      (tester) async {
    await pump(tester);

    // 1 welcome -> 2
    await tester.tap(find.text('เริ่มต้น'));
    await tester.pumpAndSettle();
    // 2 referral -> 3
    await tester.tap(find.text('TikTok'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ถัดไป'));
    await tester.pumpAndSettle();
    // 3 goal -> 4
    await tester.tap(find.text('โชคลาภ การเงิน'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ถัดไป'));
    await tester.pumpAndSettle();
    // 4 name -> 5
    await tester.enterText(find.byType(TextField), 'พิมพ์ใจ');
    await tester.pumpAndSettle();
    await tester.tap(find.text('ถัดไป'));
    await tester.pumpAndSettle();
    // 5 birthdate: set a date directly via the picker dialog would be heavy;
    // tap the date surface and confirm the default highlighted date.
    await tester.tap(find.text('แตะเพื่อเลือกวันเกิด'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ถัดไป'));
    await tester.pumpAndSettle();
    // 6 frequency -> analyzing
    await tester.tap(find.text('สัปดาห์ละครั้ง'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ดูแนวทางของฉัน'));
    // 7 analyzing: a periodic timer drives the ring so pumpAndSettle would
    // never settle. Pump fixed frames to cross the ~3.4s auto-advance.
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('YOUR GUIDANCE'), findsOneWidget);
    // 8 result -> 9 trust
    await tester.tap(find.text('ดูแนวทางทั้งหมด'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ดำเนินการต่อ'));
    await tester.pumpAndSettle();
    // 10 notifications -> 11 paywall
    await tester.tap(find.text('ไว้ทีหลัง'));
    await tester.pumpAndSettle();

    // Paywall renders with both plans, the savings badge and trial CTA.
    expect(find.text('฿599'), findsOneWidget);
    expect(find.text('฿99'), findsOneWidget);
    expect(find.text('ประหยัด 50%'), findsOneWidget);
    expect(find.text('เริ่มทดลองฟรี 7 วัน'), findsOneWidget);
    expect(find.text('ข้ามไปก่อน'), findsOneWidget);
  });
}
