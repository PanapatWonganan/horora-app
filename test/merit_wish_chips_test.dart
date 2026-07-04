import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/features/merit/screens/merit_weekly_order_screen.dart';

/// Covers Task 21.B's two pure helpers on the merit order form:
///  - [applyWishChip] — fill (empty box) vs append (non-empty box) logic for
///    tapping a wish suggestion chip, always capped at [kMeritWishMaxLength].
///  - [wishSuggestionsForBelief] — picks belief-relevant suggestions + always
///    includes the generic catch-all, capped at 4 chips.
void main() {
  group('applyWishChip', () {
    test('fills an empty wish box with the chip text', () {
      expect(applyWishChip('', 'ขอให้สุขภาพแข็งแรง'), 'ขอให้สุขภาพแข็งแรง');
    });

    test('treats a whitespace-only box as empty (fill, not append)', () {
      expect(applyWishChip('   ', 'ขอให้สุขภาพแข็งแรง'), 'ขอให้สุขภาพแข็งแรง');
    });

    test('appends to existing text with a single space separator', () {
      expect(
        applyWishChip('ขอให้ลูกสอบผ่าน', 'ขอให้สุขภาพแข็งแรง'),
        'ขอให้ลูกสอบผ่าน ขอให้สุขภาพแข็งแรง',
      );
    });

    test('never exceeds the max length — truncates the combined string', () {
      final longExisting = 'ก' * 195;
      final result = applyWishChip(longExisting, 'ขอให้สุขภาพแข็งแรง');
      expect(result.length, lessThanOrEqualTo(kMeritWishMaxLength));
      expect(result.length, kMeritWishMaxLength);
    });

    test('respects a custom maxLength override', () {
      final result = applyWishChip('abc', 'defgh', maxLength: 5);
      expect(result.length, 5);
      expect(result, 'abc d');
    });
  });

  group('wishSuggestionsForBelief', () {
    test('เงิน/โชคลาภ belief includes the money-luck suggestion first', () {
      final chips = wishSuggestionsForBelief('โชคลาภ ความมั่งคั่ง ความอุดมสมบูรณ์');
      expect(chips.first.label, 'ขอให้การเงินคล่องตัว มีโชคลาภ');
    });

    test('ความรัก/คู่ครอง belief includes the love suggestion', () {
      final chips = wishSuggestionsForBelief('ความรัก คู่ครอง ความสัมพันธ์');
      expect(chips.any((c) => c.label == 'ขอให้พบคู่ที่ดี ความรักราบรื่น'), isTrue);
    });

    test('unrelated belief still gets the generic catch-all chip', () {
      final chips = wishSuggestionsForBelief('การศึกษา ศิลปะ ความสำเร็จ');
      expect(chips.any((c) => c.label == 'ขอให้ชีวิตราบรื่น สิ่งดี ๆ เข้ามา'), isTrue);
    });

    test('is capped at 4 chips', () {
      final chips = wishSuggestionsForBelief(
        'โชคลาภ การเงิน ความรัก คู่ครอง สุขภาพ การงาน ความสำเร็จ',
      );
      expect(chips.length, lessThanOrEqualTo(4));
    });

    test('generic catch-all is always present exactly once', () {
      final chips = wishSuggestionsForBelief('โชคลาภ ความรัก สุขภาพ การงาน');
      final genericCount =
          chips.where((c) => c.label == 'ขอให้ชีวิตราบรื่น สิ่งดี ๆ เข้ามา').length;
      expect(genericCount, 1);
    });
  });
}
