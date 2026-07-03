import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/features/chat/widgets/chat_empty_state.dart';

void main() {
  group('ChatEmptyState', () {
    testWidgets('renders the headline and all 3 suggestion chips',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ChatEmptyState(onQuestionTap: (_) {})),
        ),
      );
      await tester.pump();

      expect(find.text('ทักทายนักพยากรณ์ได้เลยนะ'), findsOneWidget);
      for (final q in ChatEmptyState.suggestedQuestions) {
        expect(find.text(q), findsOneWidget);
      }
      expect(ChatEmptyState.suggestedQuestions.length, 3);
    });

    testWidgets('tapping a suggestion chip invokes onQuestionTap with its text',
        (tester) async {
      String? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatEmptyState(onQuestionTap: (q) => tapped = q),
          ),
        ),
      );
      await tester.pump();

      final firstQuestion = ChatEmptyState.suggestedQuestions.first;
      await tester.tap(find.text(firstQuestion));
      await tester.pump();

      expect(tapped, firstQuestion);
    });

    testWidgets('tapping a different chip reports that chip\'s own text',
        (tester) async {
      final tappedQuestions = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatEmptyState(onQuestionTap: tappedQuestions.add),
          ),
        ),
      );
      await tester.pump();

      final secondQuestion = ChatEmptyState.suggestedQuestions[1];
      await tester.tap(find.text(secondQuestion));
      await tester.pump();

      expect(tappedQuestions, [secondQuestion]);
    });
  });
}
