import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/core/theme/sacred_ui.dart';
import 'package:astrology_app/core/utils/app_icons.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget button) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: button)),
    ));
  }

  group('SacredPrimaryButton rendering (no styleOverride)', () {
    testWidgets('outlined (filled: false, default) renders the label',
        (tester) async {
      await pump(
        tester,
        SacredPrimaryButton(label: 'ยืนยัน', onTap: () {}),
      );
      await tester.pump();

      expect(find.text('ยืนยัน'), findsOneWidget);
      final button = tester.widget<SacredPrimaryButton>(
          find.byType(SacredPrimaryButton));
      expect(button.filled, isFalse);
    });

    testWidgets('filled: true renders the label with white label color',
        (tester) async {
      await pump(
        tester,
        SacredPrimaryButton(label: 'เริ่มต้น', onTap: () {}, filled: true),
      );
      await tester.pump();

      expect(find.text('เริ่มต้น'), findsOneWidget);

      final text = tester.widget<Text>(find.text('เริ่มต้น'));
      expect(text.style?.color, Colors.white);
    });

    testWidgets('isLoading shows a spinner instead of the label and blocks tap',
        (tester) async {
      var tapCount = 0;
      await pump(
        tester,
        SacredPrimaryButton(
          label: 'บันทึก',
          onTap: () => tapCount++,
          isLoading: true,
        ),
      );
      await tester.pump();

      // Label text is not rendered while loading.
      expect(find.text('บันทึก'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(SacredPrimaryButton));
      await tester.pump();
      expect(tapCount, 0);
    });

    testWidgets('enabled: false blocks tap (onTap never fires)',
        (tester) async {
      var tapCount = 0;
      await pump(
        tester,
        SacredPrimaryButton(
          label: 'ปิดใช้งาน',
          onTap: () => tapCount++,
          enabled: false,
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(SacredPrimaryButton));
      await tester.pump();
      expect(tapCount, 0);
    });

    testWidgets('enabled: true (default) allows tap to fire onTap',
        (tester) async {
      var tapCount = 0;
      await pump(
        tester,
        SacredPrimaryButton(label: 'ไปต่อ', onTap: () => tapCount++),
      );
      await tester.pump();

      await tester.tap(find.byType(SacredPrimaryButton));
      await tester.pump();
      expect(tapCount, 1);
    });

    testWidgets('null onTap blocks tap without throwing', (tester) async {
      await pump(
        tester,
        const SacredPrimaryButton(label: 'ไม่มีฟังก์ชัน', onTap: null),
      );
      await tester.pump();

      await tester.tap(find.byType(SacredPrimaryButton));
      await tester.pump();
      // No exception => the null-onTap branch (on = false) is handled safely.
    });

    testWidgets('leadingSvg renders an SvgPicture before the label',
        (tester) async {
      await pump(
        tester,
        SacredPrimaryButton(
          label: 'มีไอคอนนำหน้า',
          onTap: () {},
          leadingSvg: AppIcons.sparkleFilled,
        ),
      );
      await tester.pump();

      expect(find.byType(SvgIcon), findsOneWidget);
      expect(find.text('มีไอคอนนำหน้า'), findsOneWidget);
    });

    testWidgets('trailingSvg renders an SvgPicture after the label',
        (tester) async {
      await pump(
        tester,
        SacredPrimaryButton(
          label: 'มีไอคอนตามหลัง',
          onTap: () {},
          trailingSvg: AppIcons.sparkleFilled,
        ),
      );
      await tester.pump();

      expect(find.byType(SvgIcon), findsOneWidget);
      expect(find.text('มีไอคอนตามหลัง'), findsOneWidget);
    });

    testWidgets('both leadingSvg and trailingSvg render two icons',
        (tester) async {
      await pump(
        tester,
        SacredPrimaryButton(
          label: 'สองไอคอน',
          onTap: () {},
          leadingSvg: AppIcons.sparkleFilled,
          trailingSvg: AppIcons.sparkleFilled,
        ),
      );
      await tester.pump();

      expect(find.byType(SvgIcon), findsNWidgets(2));
    });

    testWidgets('no leadingSvg/trailingSvg renders zero icons',
        (tester) async {
      await pump(
        tester,
        SacredPrimaryButton(label: 'ไม่มีไอคอน', onTap: () {}),
      );
      await tester.pump();

      expect(find.byType(SvgIcon), findsNothing);
    });
  });

  group('SacredPrimaryButton with styleOverride', () {
    testWidgets(
        'styleOverride.labelColorOverride wins over the filled/outlined '
        'default label color', (tester) async {
      await pump(
        tester,
        SacredPrimaryButton(
          label: 'สีพิเศษ',
          onTap: () {},
          filled: true,
          styleOverride: const SacredButtonStyle(
            labelColorOverride: Color(0xFF123456),
          ),
        ),
      );
      await tester.pump();

      final text = tester.widget<Text>(find.text('สีพิเศษ'));
      expect(text.style?.color, const Color(0xFF123456));
    });
  });
}
