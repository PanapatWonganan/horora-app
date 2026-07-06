import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/constants.dart';
import '../models/faith_models.dart';

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
      }
      return result;
    } catch (e) {
      debugPrint('FaithPointsService.dailyCheckin error: $e');
      return const FaithCheckinResult(
          isNewDay: false, pointsEarned: 0, newStreak: 0);
    }
  }

  /// กิจกรรมรายวัน (ถาม AI / เปิดไพ่) — ให้แต้มวันละครั้งต่อประเภท
  /// คืนแต้มที่ได้ (0 = วันนี้รับไปแล้ว)
  Future<int> awardDailyActivity(String activityKey, {DateTime? now}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${StorageConstants.faithActivityPrefix}$activityKey';
      final today = faithDayKey(now ?? DateTime.now());
      if (prefs.getString(key) == today) return 0;
      await prefs.setString(key, today);
      await prefs.setInt(
        StorageConstants.faithPoints,
        (prefs.getInt(StorageConstants.faithPoints) ?? 0) +
            kFaithActivityPoints,
      );
      return kFaithActivityPoints;
    } catch (e) {
      debugPrint('FaithPointsService.awardDailyActivity error: $e');
      return 0;
    }
  }

  /// ฝากมูสำเร็จ (ไม่มีเพดานรายวัน — หนึ่งออเดอร์หนึ่งครั้ง เรียกจากจุด
  /// สร้างออเดอร์สำเร็จเท่านั้น)
  Future<int> awardMeritOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        StorageConstants.faithPoints,
        (prefs.getInt(StorageConstants.faithPoints) ?? 0) + kFaithMeritPoints,
      );
      // ปลดล็อกเงื่อนไข "เคยฝากมูแล้ว" ของรางวัลกลุ่มวอลเปเปอร์
      await prefs.setBool(StorageConstants.faithHasMeritOrder, true);
      return kFaithMeritPoints;
    } catch (e) {
      debugPrint('FaithPointsService.awardMeritOrder error: $e');
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
      if (milestoneId == 'merit_coupon') {
        await prefs.setString(
          StorageConstants.faithCouponExpiry,
          DateTime.now()
              .add(const Duration(days: kFaithMeritCouponDays))
              .toIso8601String(),
        );
      }
    } catch (e) {
      debugPrint('FaithPointsService.markMilestoneClaimed error: $e');
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
