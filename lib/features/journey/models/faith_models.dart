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

/// โบนัสรายสัปดาห์: ทำภารกิจรายวันครบ 3/3 อย่างน้อย
/// [kFaithWeeklyBonusTargetDays] วันในสัปดาห์เดียวกัน (จันทร์–อาทิตย์)
const int kFaithWeeklyBonusPoints = 30;
const int kFaithWeeklyBonusTargetDays = 3;

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

  /// รางวัลที่ต้อง "เคยฝากมูจริงอย่างน้อย 1 ครั้ง" ถึงปลดล็อก — แต้มถึง
  /// อย่างเดียวไม่พอ (ทำให้วอลเปเปอร์เป็นของที่ตามหลังออเดอร์เสมอ →
  /// เส้นทางรางวัลทำหน้าที่ upsell ไม่ใช่ของแจกง่าย)
  final bool requiresMeritOrder;

  const FaithMilestone({
    required this.id,
    required this.points,
    required this.emoji,
    required this.title,
    required this.description,
    required this.reward,
    this.premiumOnly = false,
    this.requiresMeritOrder = false,
  });

  /// เส้นทาง Level 1 → 2 — รางวัลใจ (spiritual) มาก่อน, คูปองมาก่อน
  /// วอลเปเปอร์เพื่อเร่ง "ออเดอร์แรก" (+50 ✦ จากฝากมูคือทางลัดสู่ 150)
  /// และของพรีเมียม (วอลเปเปอร์) อยู่ท้ายเส้นทาง ผูกกับการฝากมูจริง
  static const List<FaithMilestone> defaults = [
    FaithMilestone(
      id: 'lucky_numbers',
      points: 30,
      emoji: '🔢',
      title: 'เลขนำโชค + บทสวดเฉพาะคุณ',
      description: 'เลขมงคลประจำสัปดาห์และบทสวดเสริมดวงตามวันเกิดของคุณ',
      reward: FaithRewardType.luckyNumbers,
    ),
    FaithMilestone(
      id: 'merit_coupon',
      points: 70,
      emoji: '🎟️',
      title: 'ส่วนลดฝากมู ฿30',
      description: 'ใช้ได้กับทุกแพ็คภายใน 14 วันหลังกดรับ',
      reward: FaithRewardType.meritCoupon,
    ),
    FaithMilestone(
      id: 'wallpaper_teaser',
      points: 150,
      emoji: '🖼️',
      title: 'วอลเปเปอร์มงคล 1 ภาพ',
      description: 'ภาพจากคอลเลคชั่นมงคล มูลค่า ฿199 — ปลดล็อกเมื่อเคย'
          'ฝากมูอย่างน้อย 1 ครั้ง',
      reward: FaithRewardType.wallpaperTeaser,
      requiresMeritOrder: true,
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

enum FaithMilestoneState {
  locked,

  /// แต้มถึงแล้ว แต่ติดเงื่อนไข "ต้องเคยฝากมู" — โชว์ CTA พาไปฝากมูแทน
  lockedNeedsMerit,
  claimable,
  claimed,
}

FaithMilestoneState faithMilestoneState({
  required FaithMilestone milestone,
  required int points,
  required Set<String> claimedIds,
  bool hasMeritOrder = false,
}) {
  if (claimedIds.contains(milestone.id)) return FaithMilestoneState.claimed;
  if (points < milestone.points) return FaithMilestoneState.locked;
  if (milestone.requiresMeritOrder && !hasMeritOrder) {
    return FaithMilestoneState.lockedNeedsMerit;
  }
  return FaithMilestoneState.claimable;
}

// ── วันพระ (แต้มคูณ 2 ทุกกิจกรรม) ───────────────────────────────────────────

/// วันพระ ก.ค.–ธ.ค. 2569 (2026) — อ้างอิงปฏิทินวันธรรมสวนะ
/// TODO(2027): เติมตารางปีถัดไปก่อนสิ้นปี (หรือย้ายไปดึงจาก backend config)
const Set<String> kFaithHolyDays = {
  '2026-07-07', '2026-07-14', '2026-07-22', '2026-07-29', '2026-07-30',
  '2026-08-06', '2026-08-13', '2026-08-21', '2026-08-28',
  '2026-09-05', '2026-09-11', '2026-09-19', '2026-09-26',
  '2026-10-04', '2026-10-11', '2026-10-19', '2026-10-26',
  '2026-11-03', '2026-11-09', '2026-11-17', '2026-11-24',
  '2026-12-02', '2026-12-09', '2026-12-17', '2026-12-24',
};

/// วันนี้เป็นวันพระไหม — เทียบด้วย key รายวันเดียวกับ [faithDayKey]
/// (ตารางด้านบนใช้ format YYYY-MM-DD ตรงกัน)
bool faithIsHolyDay(DateTime d) => kFaithHolyDays.contains(faithDayKey(d));

// ── Check-in (pure) ──────────────────────────────────────────────────────────

class FaithCheckinResult {
  /// วันนี้เป็นวันใหม่ (ได้แต้ม) หรือเช็คอินไปแล้ว
  final bool isNewDay;
  final int pointsEarned;
  final int newStreak;

  /// วันนี้เป็นวันพระ (แต้มคูณ 2) — ใช้แต่งข้อความ feedback ฝั่ง UI
  final bool isHolyDay;

  const FaithCheckinResult({
    required this.isNewDay,
    required this.pointsEarned,
    required this.newStreak,
    this.isHolyDay = false,
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
///
/// วันพระ: แต้มที่ได้ทั้งก้อน (รวมโบนัส streak) คูณ 2
FaithCheckinResult computeFaithCheckin({
  required String? lastCheckinDayKey,
  required int currentStreak,
  required DateTime now,
}) {
  final today = faithDayKey(now);
  final isHolyDay = faithIsHolyDay(now);
  if (lastCheckinDayKey == today) {
    return FaithCheckinResult(
      isNewDay: false,
      pointsEarned: 0,
      newStreak: currentStreak,
      isHolyDay: isHolyDay,
    );
  }

  final yesterday = faithDayKey(now.subtract(const Duration(days: 1)));
  final newStreak = (lastCheckinDayKey == yesterday) ? currentStreak + 1 : 1;

  var earned = kFaithDailyCheckin;
  if (newStreak == 3) earned += kFaithStreak3Bonus;
  if (newStreak == 7) earned += kFaithStreak7Bonus;
  if (isHolyDay) earned *= 2;

  return FaithCheckinResult(
    isNewDay: true,
    pointsEarned: earned,
    newStreak: newStreak,
    isHolyDay: isHolyDay,
  );
}

// ── โบนัสภารกิจรายสัปดาห์ (pure) ────────────────────────────────────────────

/// แปลง DateTime → ISO week key เช่น '2026-W28' (จันทร์เป็นวันแรกของสัปดาห์)
/// ใช้กติกา ISO 8601: สัปดาห์เป็นของปีที่ "วันพฤหัสของสัปดาห์นั้น" ตกอยู่
/// — ครอบเคสคาบปีอัตโนมัติ (เช่น 1 ม.ค. 2027 อยู่ '2026-W53')
String faithWeekKey(DateTime d) {
  // เลื่อนไปวันพฤหัสของสัปดาห์เดียวกัน (constructor ปรับ overflow วันให้เอง)
  final thursday =
      DateTime(d.year, d.month, d.day + (DateTime.thursday - d.weekday));
  final jan1 = DateTime(thursday.year, 1, 1);
  final week = thursday.difference(jan1).inDays ~/ 7 + 1;
  return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
}

class FaithWeeklyQuestResult {
  /// วันนี้นับเป็น "วันครบภารกิจ" วันใหม่ (false = วันนี้นับไปแล้ว)
  final bool countsToday;

  /// จำนวนวันครบภารกิจของสัปดาห์นี้หลังนับวันนี้
  final int newDaysThisWeek;

  /// แต้มโบนัสที่ได้ (0 = ยังไม่แตะเป้า/รับโบนัสสัปดาห์นี้ไปแล้ว)
  final int pointsEarned;

  const FaithWeeklyQuestResult({
    required this.countsToday,
    required this.newDaysThisWeek,
    required this.pointsEarned,
  });
}

/// คำนวณผลการนับ "วันครบภารกิจ 3/3" ของสัปดาห์ — ไม่แตะ storage
///
/// [daysThisWeek] และ [bonusClaimed] เป็นค่าของ week key ปัจจุบัน (ฝั่ง
/// service เก็บ key แยกรายสัปดาห์ → ข้ามสัปดาห์แล้วเริ่มนับ 0 ใหม่เอง)
/// โบนัสให้ครั้งเดียวต่อสัปดาห์ตอนแตะ [kFaithWeeklyBonusTargetDays] วัน
/// และคูณ 2 เมื่อวันนั้นเป็นวันพระ
FaithWeeklyQuestResult computeFaithWeeklyQuest({
  required String? lastFullQuestDayKey,
  required int daysThisWeek,
  required bool bonusClaimed,
  required DateTime now,
}) {
  if (lastFullQuestDayKey == faithDayKey(now)) {
    return FaithWeeklyQuestResult(
      countsToday: false,
      newDaysThisWeek: daysThisWeek,
      pointsEarned: 0,
    );
  }
  final newDays = daysThisWeek + 1;
  var earned = 0;
  if (newDays >= kFaithWeeklyBonusTargetDays && !bonusClaimed) {
    earned = kFaithWeeklyBonusPoints;
    if (faithIsHolyDay(now)) earned *= 2;
  }
  return FaithWeeklyQuestResult(
    countsToday: true,
    newDaysThisWeek: newDays,
    pointsEarned: earned,
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

/// อายุคูปองส่วนลดฝากมู (วัน) — โค้ดจริงออกรายคนจาก server (FAITH-XXXX)
/// ไม่มีโค้ดกลางฝั่ง client อีกต่อไป (กันแชร์ต่อ)
const int kFaithMeritCouponDays = 14;

// ── แถบภารกิจบนหน้า Home (quest strip) ──────────────────────────────────────

/// รางวัลถัดไปที่ควรชี้บนหน้า Home = สถานีแรก (เรียงตามแต้ม) ที่ยังไม่รับ
/// — ถ้าแต้มถึงแล้วแต่ยังไม่กดรับ ก็ยังเป็น "ถัดไป" (สถานะ claimable)
/// คืน null เมื่อรับครบทุกสถานีแล้ว
FaithMilestone? faithNextMilestone(Set<String> claimedIds) {
  for (final m in FaithMilestone.defaults) {
    if (!claimedIds.contains(m.id)) return m;
  }
  return null;
}

/// ความคืบหน้า "ช่วงปัจจุบัน" สำหรับขีดบน Home — วิ่งจากสถานีก่อนหน้า →
/// สถานีถัดไป (ไม่ใช่ 0 → เป้า Level ซึ่งจะดูเต็มช้าจนน่าท้อ)
/// goal-gradient: เป้าใกล้ = แรงจูงใจแรง
double faithSegmentProgress({
  required int points,
  required FaithMilestone next,
}) {
  final idx = FaithMilestone.defaults.indexWhere((m) => m.id == next.id);
  final prevPoints = idx <= 0 ? 0 : FaithMilestone.defaults[idx - 1].points;
  final span = next.points - prevPoints;
  if (span <= 0) return 1.0;
  return ((points - prevPoints) / span).clamp(0.0, 1.0);
}
