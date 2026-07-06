/// Logic เวลาเตือนเช็คอินรายวัน — pure function ไม่ผูก plugin ใดๆ
/// เพื่อให้ unit test ได้ตรงๆ (ดู test/local_reminder_logic_test.dart)
library;

/// ชั่วโมงที่เตือนเช็คอินรายวัน (19:00 ตามเวลาเครื่อง)
const int kCheckinReminderHour = 19;

/// คืนเวลาเตือนเช็คอินครั้งถัดไป:
/// - ยังไม่เช็คอินวันนี้ และตอนนี้ยังไม่ถึง 19:00 → วันนี้ 19:00
/// - นอกนั้น (เช็คอินแล้ว หรือเลย 19:00 มาแล้ว) → พรุ่งนี้ 19:00
DateTime nextCheckinReminderTime({
  required DateTime now,
  required bool checkedInToday,
}) {
  final todayAtReminder =
      DateTime(now.year, now.month, now.day, kCheckinReminderHour);
  if (!checkedInToday && now.isBefore(todayAtReminder)) {
    return todayAtReminder;
  }
  // ใช้ day + 1 ผ่าน constructor ให้ DateTime normalize ข้ามสิ้นเดือน/ปีเอง
  return DateTime(now.year, now.month, now.day + 1, kCheckinReminderHour);
}
