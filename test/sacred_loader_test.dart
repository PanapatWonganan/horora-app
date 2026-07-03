import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/core/theme/app_colors.dart';
import 'package:astrology_app/core/theme/sacred_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget loader) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Center(child: loader)),
    ));
  }

  group('SacredLoader without a label', () {
    testWidgets('renders a ring with no label text', (tester) async {
      await pump(tester, const SacredLoader());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('default size uses sizeInline (28)', (tester) async {
      await pump(tester, const SacredLoader());
      await tester.pump();

      final sizedBoxes = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((b) => b.width == SacredLoader.sizeInline);
      expect(sizedBoxes, isNotEmpty);
    });

    testWidgets('.large constructor uses sizeLarge (48)', (tester) async {
      await pump(tester, const SacredLoader.large());
      await tester.pump();

      final sizedBoxes = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((b) => b.width == SacredLoader.sizeLarge);
      expect(sizedBoxes, isNotEmpty);
    });
  });

  group('SacredLoader with a label', () {
    testWidgets('renders the label text below the ring', (tester) async {
      await pump(tester, const SacredLoader(label: 'กำลังโหลด...'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('กำลังโหลด...'), findsOneWidget);
    });

    testWidgets('label is centered under the ring in a Column',
        (tester) async {
      await pump(tester, const SacredLoader(label: 'รอสักครู่'));
      await tester.pump();

      expect(find.byType(Column), findsWidgets);
      expect(find.text('รอสักครู่'), findsOneWidget);
    });
  });

  group('SacredLoader color', () {
    testWidgets('uses candleGold by default', (tester) async {
      await pump(tester, const SacredLoader());
      await tester.pump();

      final indicator = tester
          .widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      final valueColor = indicator.valueColor as AlwaysStoppedAnimation<Color>?;
      expect(valueColor?.value, AppColors.candleGold);
    });

    testWidgets('honors a custom color', (tester) async {
      await pump(tester, const SacredLoader(color: Colors.blue));
      await tester.pump();

      final indicator = tester
          .widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      final valueColor = indicator.valueColor as AlwaysStoppedAnimation<Color>?;
      expect(valueColor?.value, Colors.blue);
    });
  });
}
