import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/core/services/thai_zodiac_service.dart';

void main() {
  group('ThaiZodiacService.getThaiZodiac', () {
    test('1984 is the base year (ปีชวด / Year of Rat)', () {
      final z = ThaiZodiacService.getThaiZodiac(1984);
      expect(z.animalName, 'ชวด');
      expect(z.englishName, 'Year of Rat');
    });

    test('12-year cycle wraps: 1996 is also ปีชวด', () {
      expect(ThaiZodiacService.getThaiZodiac(1996).animalName, 'ชวด');
      expect(ThaiZodiacService.getThaiZodiac(1972).animalName, 'ชวด');
    });

    test('consecutive years advance the animal correctly', () {
      expect(ThaiZodiacService.getThaiZodiac(1985).animalName, 'ฉลู'); // Ox
      expect(ThaiZodiacService.getThaiZodiac(1986).animalName, 'ขาล'); // Tiger
      expect(ThaiZodiacService.getThaiZodiac(2012).animalName, 'มะโรง'); // Dragon
    });

    // Known-year spot check matching the brief's example: 1991 -> มะแม
    // (Year of Goat). animalIndex = (1991 - 1984 + 4) % 12 = 11, which is
    // 'มะแม' in the service's _zodiacAnimals ordering.
    test('1991 is ปีมะแม (Year of Goat)', () {
      expect(ThaiZodiacService.getThaiZodiac(1991).animalName, 'มะแม');
      expect(ThaiZodiacService.getThaiZodiac(1991).englishName, 'Year of Goat');
    });

    test('element follows a 10-year (5-element) cycle', () {
      // elementIndex = year % 10 ; 0,1->ทอง 2,3->น้ำ 4,5->ไม้ 6,7->ไฟ 8,9->ดิน
      expect(ThaiZodiacService.getThaiZodiac(2020).element, 'ทอง'); // 2020 % 10 = 0
      expect(ThaiZodiacService.getThaiZodiac(2022).element, 'น้ำ'); // 2
      expect(ThaiZodiacService.getThaiZodiac(2024).element, 'ไม้'); // 4
      expect(ThaiZodiacService.getThaiZodiac(2026).element, 'ไฟ'); // 6
      expect(ThaiZodiacService.getThaiZodiac(2028).element, 'ดิน'); // 8
    });

    test('elementThai is prefixed with ธาตุ', () {
      expect(ThaiZodiacService.getThaiZodiac(2020).elementThai, 'ธาตุทอง');
    });

    test('lucky colors and numbers are populated for every animal', () {
      for (var year = 1984; year < 1984 + 12; year++) {
        final z = ThaiZodiacService.getThaiZodiac(year);
        expect(z.luckyColors, isNotEmpty,
            reason: 'colors empty for ${z.animalName}');
        expect(z.luckyNumbers, isNotEmpty,
            reason: 'numbers empty for ${z.animalName}');
      }
    });

    test('getThaiZodiacFromDate uses the year of the date', () {
      final fromDate =
          ThaiZodiacService.getThaiZodiacFromDate(DateTime(2024, 6, 6));
      final fromYear = ThaiZodiacService.getThaiZodiac(2024);
      expect(fromDate.animalName, fromYear.animalName);
      expect(fromDate.element, fromYear.element);
    });
  });

  group('ThaiZodiacService.getDailyFortune', () {
    test('all scores stay within 1..5', () {
      final z = ThaiZodiacService.getThaiZodiac(2024);
      // sweep a range of dates to exercise the modulo math
      for (var d = 1; d <= 28; d++) {
        final fortune =
            ThaiZodiacService.getDailyFortune(z, DateTime(2026, 6, d));
        for (final key in ['overall_luck', 'love', 'career', 'health']) {
          final score = fortune[key] as int;
          expect(score, inInclusiveRange(1, 5), reason: '$key=$score on day $d');
        }
      }
    });

    test('returns a lucky number and color from the zodiac', () {
      final z = ThaiZodiacService.getThaiZodiac(2024);
      final fortune =
          ThaiZodiacService.getDailyFortune(z, DateTime(2026, 6, 6));
      expect(z.luckyNumbers, contains(fortune['lucky_number']));
      expect(z.luckyColors, contains(fortune['lucky_color']));
    });

    test('does not throw / divide-by-zero when lucky lists are empty', () {
      const empty = ThaiZodiac(
        animalName: 'x',
        thaiName: 'x',
        englishName: 'x',
        element: 'x',
        elementThai: 'x',
        luckyColors: [],
        luckyNumbers: [],
        characteristics: 'x',
        compatibility: 'x',
      );
      final fortune =
          ThaiZodiacService.getDailyFortune(empty, DateTime(2026, 6, 6));
      expect(fortune['lucky_number'], 0);
      expect(fortune['lucky_color'], '');
    });
  });

  group('ThaiZodiacService lists', () {
    test('getAllAnimals returns 12 unique animals', () {
      final animals = ThaiZodiacService.getAllAnimals();
      expect(animals.length, 12);
      expect(animals.toSet().length, 12);
    });

    test('getAllElements returns the 5 elements', () {
      expect(ThaiZodiacService.getAllElements(),
          ['ทอง', 'น้ำ', 'ไม้', 'ไฟ', 'ดิน']);
    });
  });

  group('ThaiZodiacService.getCompatibility', () {
    test('matching compatibility text returns the best result', () {
      final rat = ThaiZodiacService.getThaiZodiac(2020); // ชวด
      final ox = ThaiZodiacService.getThaiZodiac(2021); // ฉลู (เข้ากันดีกับปีชวด)
      expect(ThaiZodiacService.getCompatibility(rat, ox),
          'เข้ากันดีมาก มีความสุขร่วมกัน');
    });
  });
}
