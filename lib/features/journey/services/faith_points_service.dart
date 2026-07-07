import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/constants.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/device_id_service.dart';
import '../models/faith_models.dart';

/// ผลการขอคูปองส่วนลด — [code] เป็น null ถ้าออกโค้ดไม่สำเร็จ
/// (ออฟไลน์/server พลาด) → หน้าจอให้ผู้ใช้ลองใหม่ ไม่แจกโค้ดกลางที่แชร์ต่อได้
class FaithCouponResult {
  final String? code;
  const FaithCouponResult({this.code});

  bool get isSuccess => code != null && code!.isNotEmpty;
}

/// สถานะระบบ "เส้นทางสายมู" ที่หน้าจอใช้แสดงผล
class FaithState {
  final int points;
  final int streak;
  final Set<String> claimedMilestoneIds;

  /// เคยฝากมูจริงอย่างน้อย 1 ครั้ง (ปลดล็อกรางวัลกลุ่มวอลเปเปอร์)
  final bool hasMeritOrder;

  const FaithState({
    required this.points,
    required this.streak,
    required this.claimedMilestoneIds,
    this.hasMeritOrder = false,
  });

  int get level => faithLevelForPoints(points);
  String get levelName => faithLevelName(level);
}

/// เก็บ/อัปเดตพลังศรัทธา ✦ streak และรางวัลที่รับแล้ว — ต่อเครื่อง
/// (SharedPreferences) แบบเดียวกับสิทธิ์มูฟรี
///
/// TODO(backend): ย้ายแต้ม/สถานะรางวัลขึ้นเซิร์ฟเวอร์ — รางวัลที่มีมูลค่าเงิน
/// (คูปอง/วอลเปเปอร์) ปัจจุบันรีเซ็ตได้ด้วยการลบแอปลงใหม่
class FaithPointsService {
  FaithPointsService._();
  static final FaithPointsService instance = FaithPointsService._();

  ApiClient? _api;
  ApiClient get _client => _api ??= ApiClient();

  Future<FaithState> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    return FaithState(
      points: prefs.getInt(StorageConstants.faithPoints) ?? 0,
      streak: prefs.getInt(StorageConstants.faithStreak) ?? 0,
      claimedMilestoneIds:
          (prefs.getStringList(StorageConstants.faithClaimedMilestones) ?? [])
              .toSet(),
      hasMeritOrder:
          prefs.getBool(StorageConstants.faithHasMeritOrder) ?? false,
    );
  }

  /// เช็คอินรายวัน — เรียกตอนผู้ใช้เปิดดูดวงประจำวัน (หน้า Home)
  /// วันแรกของวัน: +แต้ม/อัปเดต streak แล้วคืนผลไว้โชว์ feedback
  /// เรียกซ้ำในวันเดียวกัน: no-op (isNewDay=false)
  Future<FaithCheckinResult> dailyCheckin({DateTime? now}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = computeFaithCheckin(
        lastCheckinDayKey: prefs.getString(StorageConstants.faithLastCheckin),
        currentStreak: prefs.getInt(StorageConstants.faithStreak) ?? 0,
        now: now ?? DateTime.now(),
      );
      if (result.isNewDay) {
        await prefs.setString(StorageConstants.faithLastCheckin,
            faithDayKey(now ?? DateTime.now()));
        await prefs.setInt(StorageConstants.faithStreak, result.newStreak);
        await prefs.setInt(
          StorageConstants.faithPoints,
          (prefs.getInt(StorageConstants.faithPoints) ?? 0) +
              result.pointsEarned,
        );
        unawaited(syncToServer());
      }
      return result;
    } catch (e) {
      debugPrint('FaithPointsService.dailyCheckin error: $e');
      return const FaithCheckinResult(
          isNewDay: false, pointsEarned: 0, newStreak: 0);
    }
  }

  /// กิจกรรมรายวัน (ถาม AI / เปิดไพ่) — ให้แต้มวันละครั้งต่อประเภท
  /// คืนแต้มที่ได้ (0 = วันนี้รับไปแล้ว) — วันพระคูณ 2
  Future<int> awardDailyActivity(String activityKey, {DateTime? now}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${StorageConstants.faithActivityPrefix}$activityKey';
      final ts = now ?? DateTime.now();
      final today = faithDayKey(ts);
      if (prefs.getString(key) == today) return 0;
      final earned =
          faithIsHolyDay(ts) ? kFaithActivityPoints * 2 : kFaithActivityPoints;
      await prefs.setString(key, today);
      await prefs.setInt(
        StorageConstants.faithPoints,
        (prefs.getInt(StorageConstants.faithPoints) ?? 0) + earned,
      );
      return earned;
    } catch (e) {
      debugPrint('FaithPointsService.awardDailyActivity error: $e');
      return 0;
    }
  }

  /// ฝากมูสำเร็จ (ไม่มีเพดานรายวัน — หนึ่งออเดอร์หนึ่งครั้ง เรียกจากจุด
  /// สร้างออเดอร์สำเร็จเท่านั้น) — ฝากมูวันพระได้คูณ 2 (+100 ✦) ตั้งใจให้
  /// เป็นแรงจูงใจสั่งออเดอร์ในวันพระ
  Future<int> awardMeritOrder({DateTime? now}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final earned = faithIsHolyDay(now ?? DateTime.now())
          ? kFaithMeritPoints * 2
          : kFaithMeritPoints;
      await prefs.setInt(
        StorageConstants.faithPoints,
        (prefs.getInt(StorageConstants.faithPoints) ?? 0) + earned,
      );
      // ปลดล็อกเงื่อนไข "เคยฝากมูแล้ว" ของรางวัลกลุ่มวอลเปเปอร์
      await prefs.setBool(StorageConstants.faithHasMeritOrder, true);
      unawaited(syncToServer());
      return earned;
    } catch (e) {
      debugPrint('FaithPointsService.awardMeritOrder error: $e');
      return 0;
    }
  }

  /// บันทึกว่า "วันนี้ทำภารกิจครบ 3/3" — เรียกจากจุดที่ dailyQuestsDone แตะ 3
  /// นับได้วันละครั้ง สะสมรายสัปดาห์ (ISO week, จันทร์เริ่ม) ครบ
  /// [kFaithWeeklyBonusTargetDays] วัน → โบนัส +[kFaithWeeklyBonusPoints] ✦
  /// ครั้งเดียวต่อสัปดาห์ (วันพระคูณ 2) — คืนแต้มโบนัสที่ได้ (0 = ไม่มี)
  Future<int> recordFullQuestDay({DateTime? now}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = now ?? DateTime.now();
      final weekKey = faithWeekKey(ts);
      final daysKey = '${StorageConstants.faithWeekDaysPrefix}$weekKey';
      final bonusKey = '${StorageConstants.faithWeekBonusPrefix}$weekKey';
      final result = computeFaithWeeklyQuest(
        lastFullQuestDayKey:
            prefs.getString(StorageConstants.faithLastFullQuestDay),
        daysThisWeek: prefs.getInt(daysKey) ?? 0,
        bonusClaimed: prefs.getBool(bonusKey) ?? false,
        now: ts,
      );
      if (!result.countsToday) return 0;
      await prefs.setString(
          StorageConstants.faithLastFullQuestDay, faithDayKey(ts));
      await prefs.setInt(daysKey, result.newDaysThisWeek);
      if (result.pointsEarned > 0) {
        await prefs.setBool(bonusKey, true);
        await prefs.setInt(
          StorageConstants.faithPoints,
          (prefs.getInt(StorageConstants.faithPoints) ?? 0) +
              result.pointsEarned,
        );
        unawaited(syncToServer());
      }
      return result.pointsEarned;
    } catch (e) {
      debugPrint('FaithPointsService.recordFullQuestDay error: $e');
      return 0;
    }
  }

  /// บันทึกว่ารับรางวัล milestone นี้แล้ว (กันรับซ้ำ)
  Future<void> markMilestoneClaimed(String milestoneId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final claimed =
          prefs.getStringList(StorageConstants.faithClaimedMilestones) ?? [];
      if (!claimed.contains(milestoneId)) {
        claimed.add(milestoneId);
        await prefs.setStringList(
            StorageConstants.faithClaimedMilestones, claimed);
      }
      // คูปองส่วนลด: เก็บวันหมดอายุไว้โชว์/ตรวจ (แจ้งโค้ดผ่าน LINE)
      // — ถ้า requestCoupon() ได้ค่าจาก server มาแล้ว จะมี expiry อยู่ก่อน
      // ไม่ทับ (ค่า server แม่นกว่า)
      if (milestoneId == 'merit_coupon' &&
          !prefs.containsKey(StorageConstants.faithCouponExpiry)) {
        await prefs.setString(
          StorageConstants.faithCouponExpiry,
          DateTime.now()
              .add(const Duration(days: kFaithMeritCouponDays))
              .toIso8601String(),
        );
      }
      unawaited(syncToServer());
    } catch (e) {
      debugPrint('FaithPointsService.markMilestoneClaimed error: $e');
    }
  }

  /// ขอคูปองส่วนลดรายคนจาก server (โค้ด FAITH-XXXX ผูกกับเครื่อง —
  /// กันโค้ดกลางหลุดไปแชร์ต่อ) — ขอซ้ำได้ใบเดิมจนกว่าจะหมดอายุ/ถูกใช้
  ///
  /// ออกโค้ดไม่สำเร็จ (ออฟไลน์/server พลาด) → คืน code = null ให้หน้าจอ
  /// แจ้งผู้ใช้ลองใหม่ — **ไม่แจกโค้ดกลางที่แชร์ต่อได้** (โค้ดต้องมาจาก
  /// server เท่านั้น เพราะเป็นส่วนลดที่มีมูลค่าเงิน)
  Future<FaithCouponResult> requestCoupon() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // มีโค้ดรายคนอยู่แล้ว → ใช้ใบเดิม
      final saved = prefs.getString(StorageConstants.faithCouponCode);
      if (saved != null && saved.isNotEmpty) {
        return FaithCouponResult(code: saved);
      }
      final deviceId = await DeviceIdService.instance.getOrCreate();
      final response = await _client
          .post(ApiConstants.faithCouponsPath, data: {'device_id': deviceId})
          .timeout(const Duration(seconds: 5));
      final code = response is Map ? response['code'] : null;
      if (code is String && code.isNotEmpty) {
        await prefs.setString(StorageConstants.faithCouponCode, code);
        final expiresAt = response['expires_at'];
        if (expiresAt is String && DateTime.tryParse(expiresAt) != null) {
          await prefs.setString(StorageConstants.faithCouponExpiry, expiresAt);
        }
        return FaithCouponResult(code: code);
      }
    } catch (e) {
      debugPrint('FaithPointsService.requestCoupon error: $e');
    }
    return const FaithCouponResult(code: null);
  }

  /// Mirror แต้ม/สถานะขึ้น server (fire-and-forget) — เพื่อ visibility /
  /// ตรวจ abuse ฝั่งแอดมิน server เก็บ max(points) เอง client ส่งค่าจริงได้
  /// TODO(backend): ระยะยาวย้ายเป็น server-authoritative แล้ว client อ่านกลับ
  Future<void> syncToServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = await DeviceIdService.instance.getOrCreate();
      await _client.post(ApiConstants.faithSyncPath, data: {
        'device_id': deviceId,
        'points': prefs.getInt(StorageConstants.faithPoints) ?? 0,
        'streak': prefs.getInt(StorageConstants.faithStreak) ?? 0,
        'last_checkin_date':
            prefs.getString(StorageConstants.faithLastCheckin),
        'has_merit_order':
            prefs.getBool(StorageConstants.faithHasMeritOrder) ?? false,
        'claimed_milestones':
            prefs.getStringList(StorageConstants.faithClaimedMilestones) ?? [],
      }).timeout(const Duration(seconds: 5));
    } catch (e) {
      // เงียบ — sync พลาดไม่กระทบ UX (รอบหน้า sync ใหม่เอง)
      debugPrint('FaithPointsService.syncToServer skipped: $e');
    }
  }

  /// นับ "ภารกิจวันนี้" ที่ทำแล้ว (0-3): เช็คอินดวงรายวัน / ถาม AI / เปิดไพ่
  /// ใช้โชว์ x/3 บนแถบภารกิจหน้า Home — อ่านจาก flag รายวันที่มีอยู่แล้ว
  Future<int> dailyQuestsDone({DateTime? now}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = faithDayKey(now ?? DateTime.now());
      var done = 0;
      if (prefs.getString(StorageConstants.faithLastCheckin) == today) done++;
      if (prefs.getString('${StorageConstants.faithActivityPrefix}ai_chat') ==
          today) {
        done++;
      }
      if (prefs.getString('${StorageConstants.faithActivityPrefix}tarot') ==
          today) {
        done++;
      }
      return done;
    } catch (e) {
      debugPrint('FaithPointsService.dailyQuestsDone error: $e');
      return 0;
    }
  }

  /// วันหมดอายุคูปอง ฿30 (null = ยังไม่เคยรับ)
  Future<DateTime?> couponExpiry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(StorageConstants.faithCouponExpiry);
      return raw == null ? null : DateTime.tryParse(raw);
    } catch (_) {
      return null;
    }
  }
}
