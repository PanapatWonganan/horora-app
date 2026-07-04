import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/features/merit/models/merit_models.dart';

/// Covers Task 20's two new model-layer helpers:
///  - [MeritDayX.nextOccurrenceDate] — the single source of truth for "next
///    occurrence" dates, shared by the landing day chips and the schedule
///    detail's "รอบถัดไป" line.
///  - [WeeklyOrderPackage.cheapestPrice] / [WeeklyMeritSchedule.cheapestPackagePrice]
///    — the "เริ่มต้น ฿xxx" price shown before the order form.
void main() {
  group('MeritDayX.nextOccurrenceDate', () {
    test('today counts as the next occurrence (not pushed to next week)', () {
      // Sat Jul 4 2026 is a Saturday (weekday 6).
      final saturday = DateTime(2026, 7, 4);
      final result = MeritDay.saturday.nextOccurrenceDate(from: saturday);
      expect(result, DateTime(2026, 7, 4));
    });

    test('an earlier-in-week day rolls forward to next week', () {
      // Sat Jul 4 2026 -> Monday should resolve to Mon Jul 6 (2 days later),
      // not the Monday that already passed this week.
      final saturday = DateTime(2026, 7, 4);
      final result = MeritDay.monday.nextOccurrenceDate(from: saturday);
      expect(result, DateTime(2026, 7, 6));
    });

    test('matches the brief\'s example: Sat Jul 4 -> Friday chip reads Jul 10',
        () {
      final saturday = DateTime(2026, 7, 4);
      final result = MeritDay.friday.nextOccurrenceDate(from: saturday);
      expect(result, DateTime(2026, 7, 10));
    });

    test('time-of-day on `from` does not change the resolved date', () {
      final withTime = DateTime(2026, 7, 4, 23, 59);
      final result = MeritDay.saturday.nextOccurrenceDate(from: withTime);
      expect(result, DateTime(2026, 7, 4));
    });

    test('defaults to DateTime.now() when [from] is omitted', () {
      final result = MeritDay.monday.nextOccurrenceDate();
      expect(result.weekday, DateTime.monday);
      // Never resolves to a date more than 6 days in the past or future.
      final today = DateTime.now();
      final diff = result
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
      expect(diff, inInclusiveRange(0, 6));
    });
  });

  group('WeeklyOrderPackage.cheapestPrice', () {
    test('is the minimum price across all default packages', () {
      final prices =
          WeeklyOrderPackage.defaultPackages.map((p) => p.price).toList();
      expect(WeeklyOrderPackage.cheapestPrice, prices.reduce((a, b) => a < b ? a : b));
    });

    test('matches the brief\'s expected starting price of ฿299', () {
      expect(WeeklyOrderPackage.cheapestPrice, 299);
    });
  });

  group('WeeklyOrderPackage.byId', () {
    test('finds an existing package by id', () {
      final pkg = WeeklyOrderPackage.byId('standard');
      expect(pkg, isNotNull);
      expect(pkg!.price, 499);
    });

    test('returns null for an unknown id instead of throwing', () {
      expect(WeeklyOrderPackage.byId('does_not_exist'), isNull);
    });
  });

  group('WeeklyMeritSchedule.cheapestPackagePrice', () {
    test('reads from the same single source of truth as the order form', () {
      final schedule = WeeklyMeritSchedule.defaultSchedule.first;
      expect(schedule.cheapestPackagePrice, WeeklyOrderPackage.cheapestPrice);
    });
  });
}
