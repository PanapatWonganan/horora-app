/// โมเดล + pure logic ของระบบ "เส้นทางสายมู" (retention journey)
///
/// แต้มเรียกว่า "พลังศรัทธา ✦" — จงใจไม่ใช้คำว่า "แต้มบุญ" เพื่อไม่สื่อว่า
/// บุญเป็นของสะสม/ซื้อได้ ซึ่งจะกระทบความน่าเชื่อถือของ merit funnel จริง
///
/// logic ทั้งหมดในไฟล์นี้เป็น pure function (ไม่แตะ storage/เวลาจริง)
/// เพื่อให้เทสได้ตรงๆ — ฝั่งเก็บสถานะอยู่ใน FaithPointsService
library;

// ── ค่าคงที่ของระบบ ──────────────────────────────────────────────────────────

/// แต้มเช็คอินรายวัน (ให้อัตโนมัติเมื่อเปิดดูดวงประจำวันครั้งแรกของวัน)
const int kFaithDailyCheckin = 10;

/// โบนัส streak: ครบ 3 วันติด / 7 วันติด (ให้ตอนข้ามหลักพอดีเท่านั้น)
const int kFaithStreak3Bonus = 15;
const int kFaithStreak7Bonus = 40;

/// กิจกรรมรายวัน (ถาม AI / เปิดไพ่) — วันละครั้งต่อประเภท
const int kFaithActivityPoints = 5;

/// ฝากมูสำเร็จ (รวมมูฟรีครั้งแรก)
const int kFaithMeritPoints = 50;

/// เป้า Level 2 — ผู้ใช้สม่ำเสมอ ~2 สัปดาห์
const int kFaithLevel2Points = 200;

// ── Level ────────────────────────────────────────────────────────────────────

int faithLevelForPoints(int points) => points >= kFaithLevel2Points ? 2 : 1;

String faithLevelName(int level) =>
    level >= 2 ? 'ศิษย์สายมู' : 'ผู้เริ่มต้นศรัทธา';

// ── Milestones ───────────────────────────────────────────────────────────────

enum FaithRewardType {
  /// วอลเปเปอร์มงคลตัวอย่าง 1 ภาพ (teaser ของคอลเลคชั่นเต็ม) — ส่งผ่าน LINE OA
  wallpaperTeaser,

  /// เลขนำโชคพิเศษ + บทสวดตามวันเกิด — สร้างในแอปได้เลย
  luckyNumbers,

  /// คูปองส่วนลดฝากมู ฿30 (แจ้งโค้ดใน LINE หลังฝากมู — flow ชำระเงินเป็น
  /// manual transfer อยู่แล้ว การ redeem ผ่านทีมงานจึงตรง flow จริง)
  meritCoupon,

  /// กล่องรางวัล Level 2: คอลเลคชั่นวอลเปเปอร์มงคล ฿199 (เฉพาะ Premium)
  level2Box,
}

class FaithMilestone {
  final String id;
  final int points;
  final String emoji;
  final String title;
  final String description;
  final FaithRewardType reward;

  /// รางวัลที่ต้องเป็นสมาชิก Premium ถึงจะรับได้ (แสดง 👑 บนเส้นทาง)
  final bool premiumOnly;

  const FaithMilestone({
    required this.id,
    required this.points,
    required this.emoji,
    required this.title,
    required this.description,
    required this.reward,
    this.premiumOnly = false,
  });

  /// เส้นทาง Level 1 → 2 — สลับรางวัลใจ (spiritual) กับรางวัลขาย
  /// (commercial) เพื่อไม่ให้เส้นทางรู้สึกเป็นแค่คูปองลดราคา
  static const List<FaithMilestone> defaults = [
    FaithMilestone(
      id: 'wallpaper_teaser',
      points: 30,
      emoji: '🖼️',
      title: 'วอลเปเปอร์มงคล 1 ภาพ',
      description: 'ภาพตัวอย่างจากคอลเลคชั่นมงคล มูลค่า ฿199 — รับผ่าน LINE',
      reward: FaithRewardType.wallpaperTeaser,
    ),
    FaithMilestone(
      id: 'lucky_numbers',
      points: 70,
      emoji: '🔢',
      title: 'เลขนำโชค + บทสวดเฉพาะคุณ',
      description: 'เลขมงคลประจำสัปดาห์และบทสวดเสริมดวงตามวันเกิดของคุณ',
      reward: FaithRewardType.luckyNumbers,
    ),
    FaithMilestone(
      id: 'merit_coupon',
      points: 120,
      emoji: '🎟️',
      title: 'ส่วนลดฝากมู ฿30',
      description: 'ใช้ได้กับทุกแพ็คภายใน 14 วันหลังกดรับ',
      reward: FaithRewardType.meritCoupon,
    ),
    FaithMilestone(
      id: 'level2_box',
      points: kFaithLevel2Points,
      emoji: '👑',
      title: 'Level 2 · คอลเลคชั่นวอลเปเปอร์มงคล',
      description: 'คอลเลคชั่นเต็ม มูลค่า ฿199 สำหรับสมาชิก Premium',
      reward: FaithRewardType.level2Box,
      premiumOnly: true,
    ),
  ];
}

enum FaithMilestoneState { locked, claimable, claimed }

FaithMilestoneState faithMilestoneState({
  required FaithMilestone milestone,
  required int points,
  required Set<String> claimedIds,
}) {
  if (claimedIds.contains(milestone.id)) return FaithMilestoneState.claimed;
  if (points >= milestone.points) return FaithMilestoneState.claimable;
  return FaithMilestoneState.locked;
}

// ── Check-in (pure) ──────────────────────────────────────────────────────────

class FaithCheckinResult {
  /// วันนี้เป็นวันใหม่ (ได้แต้ม) หรือเช็คอินไปแล้ว
  final bool isNewDay;
  final int pointsEarned;
  final int newStreak;

  const FaithCheckinResult({
    required this.isNewDay,
    required this.pointsEarned,
    required this.newStreak,
  });
}

/// แปลง DateTime → key รายวัน (เทียบ "วัน" ตามเวลาท้องถิ่น ไม่ใช่ 24 ชม.)
String faithDayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// คำนวณผลเช็คอินจากสถานะเดิม — ไม่แตะ storage
///
/// กติกา streak: เช็คอินวันถัดจากครั้งล่าสุด → streak+1, เว้นวัน → เริ่ม 1 ใหม่
/// โบนัสให้เฉพาะตอน streak "แตะ" 3 หรือ 7 พอดี (ขาดแล้วสร้างใหม่จนแตะอีก
/// ครั้งก็ได้อีก — จงใจ เพื่อจูงใจให้กลับมาต่อ streak ใหม่)
FaithCheckinResult computeFaithCheckin({
  required String? lastCheckinDayKey,
  required int currentStreak,
  required DateTime now,
}) {
  final today = faithDayKey(now);
  if (lastCheckinDayKey == today) {
    return FaithCheckinResult(
      isNewDay: false,
      pointsEarned: 0,
      newStreak: currentStreak,
    );
  }

  final yesterday = faithDayKey(now.subtract(const Duration(days: 1)));
  final newStreak = (lastCheckinDayKey == yesterday) ? currentStreak + 1 : 1;

  var earned = kFaithDailyCheckin;
  if (newStreak == 3) earned += kFaithStreak3Bonus;
  if (newStreak == 7) earned += kFaithStreak7Bonus;

  return FaithCheckinResult(
    isNewDay: true,
    pointsEarned: earned,
    newStreak: newStreak,
  );
}

// ── เลขนำโชค + บทสวด (รางวัล milestone 70 ✦) ────────────────────────────────

/// เลขนำโชค 3 ตัว (1-99) — deterministic จากวันเกิด + สัปดาห์ของปี เพื่อให้
/// "ประจำสัปดาห์" จริง (เปิดซ้ำในสัปดาห์เดียวกันได้เลขเดิม) และต่างกันต่อคน
List<int> faithLuckyNumbers({DateTime? birthDate, required DateTime now}) {
  final dayOfYear = int.parse(
      '${now.difference(DateTime(now.year, 1, 1)).inDays}');
  final week = dayOfYear ~/ 7;
  final seed = (birthDate?.day ?? 9) * 31 +
      (birthDate?.month ?? 9) * 7 +
      week * 13 +
      now.year;
  final numbers = <int>{};
  var x = seed;
  while (numbers.length < 3) {
    x = (x * 1103515245 + 12345) & 0x7fffffff;
    numbers.add((x % 99) + 1);
  }
  final list = numbers.toList()..sort();
  return list;
}

/// บทสวดสั้นเสริมดวงตามวันเกิด (วันในสัปดาห์) — คำแนะนำสายมูทั่วไป
String faithMantraForWeekday(int? weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'อิติปิโส ภะคะวา (สวด 15 จบ) — เสริมเมตตามหานิยม';
    case DateTime.tuesday:
      return 'ปัตติปิโส ภะคะวา (สวด 8 จบ) — เสริมอำนาจ ชนะอุปสรรค';
    case DateTime.wednesday:
      return 'พุทธะสังมิ (สวด 17 จบ) — เสริมการเจรจา ค้าขายคล่อง';
    case DateTime.thursday:
      return 'ภะสัมสัมวิสะเทภะ (สวด 19 จบ) — เสริมปัญญา การเรียนการงาน';
    case DateTime.friday:
      return 'วาโธโนอะมะมะวา (สวด 21 จบ) — เสริมเสน่ห์ ความรักราบรื่น';
    case DateTime.saturday:
      return 'โสมาณะกะริถาโธ (สวด 10 จบ) — คุ้มครองแคล้วคลาด';
    case DateTime.sunday:
      return 'อะวิชสุนุตสานุสติ (สวด 6 จบ) — เสริมบารมี ผู้ใหญ่เมตตา';
    default:
      return 'อิติปิโส ภะคะวา — สวดพระคาถาประจำวันเกิดเพื่อความเป็นสิริมงคล';
  }
}

/// โค้ดคูปองส่วนลดฝากมู (แจ้งทีมงานใน LINE ระหว่างยืนยันยอด)
const String kFaithMeritCouponCode = 'FAITH30';
const int kFaithMeritCouponDays = 14;
