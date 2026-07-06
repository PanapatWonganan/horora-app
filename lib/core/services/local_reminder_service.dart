import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/journey/models/reminder_time_logic.dart';

/// Local notification เพื่อ retention loop — ไม่พึ่งเซิร์ฟเวอร์/OneSignal:
/// 1) เตือนเช็คอินรายวัน 19:00 (id 1001) — one-shot ครั้งถัดไป แล้ว
///    reschedule ใหม่ทุกครั้งที่เปิดแอป จึงต่อเนื่องเอง
/// 2) เตือนออเดอร์ฝากมูค้าง 24 ชม. (id 1002) — ตั้งตอนเข้าหน้าเลือกแพ็ค
///    แล้วยกเลิกเมื่อสร้างออเดอร์สำเร็จ
///
/// ทุกเมธอดห่อ try/catch — notification พังห้ามพาแอปพัง
/// หมายเหตุ permission: Android 13 POST_NOTIFICATIONS ถูกขอโดย OneSignal
/// ตอน init แล้ว จึงไม่ขอซ้ำที่นี่ (iOS ก็เช่นกัน — ปิด request ตอน init)
class LocalReminderService {
  LocalReminderService._();
  static final LocalReminderService instance = LocalReminderService._();

  static const int _checkinNotificationId = 1001;
  static const int _abandonedOrderNotificationId = 1002;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Channel เดียวสำหรับการเตือนทั้งหมดของแอป — importance default
  /// (ไม่เด้ง heads-up รบกวน แค่ขึ้นแถบแจ้งเตือน)
  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'horora_reminders',
    'การแจ้งเตือน Horora',
    channelDescription: 'เตือนเช็คอินรายวันและรายการฝากมูที่ค้างอยู่',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  static const NotificationDetails _details = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  /// Init plugin + timezone database — เรียกครั้งเดียวจาก main.dart
  /// (ต่อจาก NotificationService) ล้มเหลว = ปิดฟีเจอร์เงียบๆ ทั้ง service
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (e) {
        // หา timezone เครื่องไม่ได้ — ใช้ค่า default ของ tz (UTC) ดีกว่าพัง
        debugPrint('LocalReminderService: timezone fallback: $e');
      }
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // ไม่ขอ permission ซ้ำ — OneSignal จัดการ prompt แล้วตอน init
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      final ok = await _plugin.initialize(initSettings);
      _initialized = ok ?? false;
    } catch (e) {
      debugPrint('LocalReminderService.initialize error: $e');
      _initialized = false;
    }
  }

  /// ตั้งเตือนเช็คอินครั้งถัดไป (19:00) — cancel ของเดิมก่อนเสมอกันซ้อน
  /// [checkedInToday] = true เมื่อผู้ใช้เช็คอินวันนี้แล้ว (เปิดแอป = เช็คอิน
  /// อัตโนมัติ) → เตือนพรุ่งนี้ 19:00
  Future<void> scheduleDailyCheckinReminder({
    required int streak,
    required bool checkedInToday,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_checkinNotificationId);
      final next = nextCheckinReminderTime(
        now: DateTime.now(),
        checkedInToday: checkedInToday,
      );
      final body = streak >= 2
          ? 'อย่าให้ streak $streak วันติดขาดนะคะ — เช็คอินรับ +10 ✦'
          : 'เช็คอินรับ +10 ✦ แล้วดูดวงประจำวันกันค่ะ';
      await _plugin.zonedSchedule(
        _checkinNotificationId,
        '✦ ดวงวันนี้ของคุณมาแล้ว',
        body,
        tz.TZDateTime.from(next, tz.local),
        _details,
        // inexact พอสำหรับ reminder รายวัน — ไม่ขอ SCHEDULE_EXACT_ALARM
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('LocalReminderService.scheduleDailyCheckinReminder error: $e');
    }
  }

  /// ตั้งเตือนออเดอร์ค้างอีก 24 ชม. — เรียกตอนผู้ใช้เข้าหน้าเลือกแพ็ค
  /// (intent สูง) ตั้งซ้ำได้เพราะ cancel ของเดิมก่อนทุกครั้ง
  Future<void> scheduleAbandonedOrderReminder() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_abandonedOrderNotificationId);
      await _plugin.zonedSchedule(
        _abandonedOrderNotificationId,
        '🛕 ยังฝากมูไม่เสร็จนะคะ',
        'ของที่เลือกไว้ยังอยู่ครบ กลับมาฝากมูต่อได้เลยค่ะ',
        tz.TZDateTime.now(tz.local).add(const Duration(hours: 24)),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint(
          'LocalReminderService.scheduleAbandonedOrderReminder error: $e');
    }
  }

  /// ยกเลิกเตือนออเดอร์ค้าง — เรียกเมื่อสร้างออเดอร์สำเร็จ (ฟรี/จ่ายเงิน)
  Future<void> cancelAbandonedOrderReminder() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_abandonedOrderNotificationId);
    } catch (e) {
      debugPrint(
          'LocalReminderService.cancelAbandonedOrderReminder error: $e');
    }
  }
}
