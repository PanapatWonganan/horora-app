import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/features/journey/models/reminder_time_logic.dart';

void main() {
  group('nextCheckinReminderTime', () {
    test('ก่อน 19:00 และยังไม่เช็คอิน → วันนี้ 19:00', () {
      final now = DateTime(2026, 7, 7, 10, 30);
      final next = nextCheckinReminderTime(now: now, checkedInToday: false);
      expect(next, DateTime(2026, 7, 7, 19));
    });

    test('เช็คอินวันนี้แล้ว (แม้ยังไม่ถึง 19:00) → พรุ่งนี้ 19:00', () {
      final now = DateTime(2026, 7, 7, 10, 30);
      final next = nextCheckinReminderTime(now: now, checkedInToday: true);
      expect(next, DateTime(2026, 7, 8, 19));
    });

    test('เลย 19:00 มาแล้ว (ยังไม่เช็คอิน) → พรุ่งนี้ 19:00', () {
      final now = DateTime(2026, 7, 7, 21, 15);
      final next = nextCheckinReminderTime(now: now, checkedInToday: false);
      expect(next, DateTime(2026, 7, 8, 19));
    });

    test('19:00 เป๊ะ ยังไม่เช็คอิน → ไม่ตั้งย้อนหลัง เลื่อนเป็นพรุ่งนี้', () {
      final now = DateTime(2026, 7, 7, 19, 0);
      final next = nextCheckinReminderTime(now: now, checkedInToday: false);
      expect(next, DateTime(2026, 7, 8, 19));
    });

    test('ข้ามสิ้นเดือน: เช็คอินแล้ววันที่ 31 → 1 เดือนถัดไป 19:00', () {
      final now = DateTime(2026, 7, 31, 20, 0);
      final next = nextCheckinReminderTime(now: now, checkedInToday: true);
      expect(next, DateTime(2026, 8, 1, 19));
    });

    test('ข้ามสิ้นปี: หลัง 19:00 วันที่ 31 ธ.ค. → 1 ม.ค. ปีถัดไป', () {
      final now = DateTime(2026, 12, 31, 23, 59);
      final next = nextCheckinReminderTime(now: now, checkedInToday: true);
      expect(next, DateTime(2027, 1, 1, 19));
    });
  });
}
