import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/core/utils/zodiac_utils.dart';

void main() {
  group('ZodiacUtils.getZodiacSign', () {
    test('maps representative mid-range dates to the correct sign', () {
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 4, 1)), 'aries');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 5, 1)), 'taurus');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 6, 1)), 'gemini');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 7, 1)), 'cancer');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 8, 1)), 'leo');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 9, 1)), 'virgo');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 10, 1)), 'libra');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 11, 1)), 'scorpio');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 12, 1)), 'sagittarius');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 1, 1)), 'capricorn');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 2, 1)), 'aquarius');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 3, 1)), 'pisces');
    });

    test('handles boundary dates inclusively (cusp days)', () {
      // Aries runs 21 Mar - 19 Apr
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 3, 20)), 'pisces');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 3, 21)), 'aries');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 4, 19)), 'aries');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 4, 20)), 'taurus');
      // Capricorn wraps the year boundary 22 Dec - 19 Jan
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 12, 22)), 'capricorn');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 1, 19)), 'capricorn');
      expect(ZodiacUtils.getZodiacSign(DateTime(2000, 1, 20)), 'aquarius');
    });
  });

  group('ZodiacUtils.getZodiacSignThai', () {
    test('translates each sign to its Thai name', () {
      expect(ZodiacUtils.getZodiacSignThai(DateTime(2000, 4, 1)), 'ราศีเมษ');
      expect(ZodiacUtils.getZodiacSignThai(DateTime(2000, 1, 1)), 'ราศีมังกร');
    });

    test('uses the provided zodiacSign override instead of the date', () {
      // Date would compute to aries, but override wins.
      final result = ZodiacUtils.getZodiacSignThai(
        DateTime(2000, 4, 1),
        zodiacSign: 'leo',
      );
      expect(result, 'ราศีสิงห์');
    });

    test('returns a fallback for an unknown sign override', () {
      final result = ZodiacUtils.getZodiacSignThai(
        DateTime(2000, 4, 1),
        zodiacSign: 'not_a_sign',
      );
      expect(result, 'ไม่ทราบราศี');
    });
  });

  group('ZodiacUtils.getZodiacDateRange', () {
    test('returns a non-empty range for a valid sign and empty for unknown', () {
      expect(ZodiacUtils.getZodiacDateRange('aries'), isNotEmpty);
      expect(ZodiacUtils.getZodiacDateRange('ARIES'), isNotEmpty); // case-insensitive
      expect(ZodiacUtils.getZodiacDateRange('unknown'), '');
    });
  });
}
