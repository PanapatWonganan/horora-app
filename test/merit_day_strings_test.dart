import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/features/merit/models/merit_models.dart';

/// Guards the "วันวันศุกร์" regression: displayName must be exactly "วัน" +
/// the Thai day name, with no double "วัน" prefix and no day missing it.
void main() {
  group('MeritDayX.displayName', () {
    const expected = {
      MeritDay.monday: 'วันจันทร์',
      MeritDay.tuesday: 'วันอังคาร',
      MeritDay.wednesday: 'วันพุธ',
      MeritDay.thursday: 'วันพฤหัสบดี',
      MeritDay.friday: 'วันศุกร์',
      MeritDay.saturday: 'วันเสาร์',
      MeritDay.sunday: 'วันอาทิตย์',
    };

    for (final entry in expected.entries) {
      test('${entry.key} -> "${entry.value}"', () {
        expect(entry.key.displayName, entry.value);
      });
    }

    test('every day\'s displayName starts with exactly one "วัน" prefix', () {
      for (final day in MeritDay.values) {
        final name = day.displayName;
        expect(name.startsWith('วัน'), isTrue,
            reason: '$day displayName "$name" missing วัน prefix');
        // Guards the "วันวันศุกร์" regression specifically: stripping the
        // leading วัน once must not leave another วัน immediately after.
        final withoutPrefix = name.substring('วัน'.length);
        expect(withoutPrefix.startsWith('วัน'), isFalse,
            reason: '$day displayName "$name" has a doubled วัน prefix');
      }
    });

    test('all 7 displayName values are unique', () {
      final names = MeritDay.values.map((d) => d.displayName).toSet();
      expect(names.length, 7);
    });
  });

  group('MeritDayX.shortName', () {
    const expectedShort = {
      MeritDay.monday: 'จ.',
      MeritDay.tuesday: 'อ.',
      MeritDay.wednesday: 'พ.',
      MeritDay.thursday: 'พฤ.',
      MeritDay.friday: 'ศ.',
      MeritDay.saturday: 'ส.',
      MeritDay.sunday: 'อา.',
    };

    for (final entry in expectedShort.entries) {
      test('${entry.key} -> "${entry.value}"', () {
        expect(entry.key.shortName, entry.value);
      });
    }
  });

  group('MeritDayX.weekdayNumber', () {
    test('matches DateTime.weekday convention (1=Mon..7=Sun)', () {
      expect(MeritDay.monday.weekdayNumber, 1);
      expect(MeritDay.tuesday.weekdayNumber, 2);
      expect(MeritDay.wednesday.weekdayNumber, 3);
      expect(MeritDay.thursday.weekdayNumber, 4);
      expect(MeritDay.friday.weekdayNumber, 5);
      expect(MeritDay.saturday.weekdayNumber, 6);
      expect(MeritDay.sunday.weekdayNumber, 7);
    });
  });

  group('MeritDayX.fromWeekday', () {
    test('maps every ISO weekday number back to its MeritDay', () {
      for (var w = 1; w <= 7; w++) {
        expect(MeritDayX.fromWeekday(w).weekdayNumber, w);
      }
    });

    test('falls back to monday for an out-of-range weekday', () {
      expect(MeritDayX.fromWeekday(0), MeritDay.monday);
      expect(MeritDayX.fromWeekday(8), MeritDay.monday);
    });
  });
}
