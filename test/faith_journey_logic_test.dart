import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/features/journey/models/faith_models.dart';

void main() {
  group('computeFaithCheckin', () {
    // จันทร์ 3 ส.ค. 2026 — จงใจเลือกสัปดาห์ที่วันถัดๆ ไปไม่ใช่วันพระ
    // (ฐานเดิม 6 ก.ค. มีปัญหา: 7 ก.ค. เป็นวันพระ → แต้มคูณ 2 ตามฟีเจอร์ใหม่)
    final monday = DateTime(2026, 8, 3, 8, 30);

    test('first ever check-in starts streak at 1 with base points', () {
      final r = computeFaithCheckin(
          lastCheckinDayKey: null, currentStreak: 0, now: monday);
      expect(r.isNewDay, isTrue);
      expect(r.newStreak, 1);
      expect(r.pointsEarned, kFaithDailyCheckin);
    });

    test('same-day repeat is a no-op', () {
      final r = computeFaithCheckin(
        lastCheckinDayKey: faithDayKey(monday),
        currentStreak: 4,
        now: monday.add(const Duration(hours: 9)),
      );
      expect(r.isNewDay, isFalse);
      expect(r.pointsEarned, 0);
      expect(r.newStreak, 4);
    });

    test('consecutive day increments streak', () {
      final r = computeFaithCheckin(
        lastCheckinDayKey: faithDayKey(monday),
        currentStreak: 1,
        now: monday.add(const Duration(days: 1)),
      );
      expect(r.isNewDay, isTrue);
      expect(r.newStreak, 2);
      expect(r.pointsEarned, kFaithDailyCheckin);
    });

    test('a missed day resets streak to 1', () {
      final r = computeFaithCheckin(
        lastCheckinDayKey: faithDayKey(monday),
        currentStreak: 6,
        now: monday.add(const Duration(days: 2)),
      );
      expect(r.newStreak, 1);
      expect(r.pointsEarned, kFaithDailyCheckin);
    });

    test('streak bonuses fire exactly when hitting 3 and 7', () {
      final hit3 = computeFaithCheckin(
        lastCheckinDayKey: faithDayKey(monday),
        currentStreak: 2,
        now: monday.add(const Duration(days: 1)),
      );
      expect(hit3.newStreak, 3);
      expect(hit3.pointsEarned, kFaithDailyCheckin + kFaithStreak3Bonus);

      final hit7 = computeFaithCheckin(
        lastCheckinDayKey: faithDayKey(monday),
        currentStreak: 6,
        now: monday.add(const Duration(days: 1)),
      );
      expect(hit7.newStreak, 7);
      expect(hit7.pointsEarned, kFaithDailyCheckin + kFaithStreak7Bonus);

      // วันที่ 4 (หลังผ่าน 3 มาแล้ว) ไม่ได้โบนัสซ้ำ
      final day4 = computeFaithCheckin(
        lastCheckinDayKey: faithDayKey(monday),
        currentStreak: 3,
        now: monday.add(const Duration(days: 1)),
      );
      expect(day4.pointsEarned, kFaithDailyCheckin);
    });

    test('date rollover across midnight counts calendar days, not 24h', () {
      final lateNight = DateTime(2026, 7, 6, 23, 50);
      final earlyNext = DateTime(2026, 7, 7, 0, 10);
      final r = computeFaithCheckin(
        lastCheckinDayKey: faithDayKey(lateNight),
        currentStreak: 1,
        now: earlyNext,
      );
      expect(r.isNewDay, isTrue);
      expect(r.newStreak, 2);
    });
  });

  group('วันพระ — faithIsHolyDay & checkin ×2', () {
    test('faithIsHolyDay matches the table regardless of time of day', () {
      expect(faithIsHolyDay(DateTime(2026, 7, 7)), isTrue);
      expect(faithIsHolyDay(DateTime(2026, 7, 7, 23, 59)), isTrue);
      expect(faithIsHolyDay(DateTime(2026, 12, 24, 6)), isTrue);
      expect(faithIsHolyDay(DateTime(2026, 7, 8)), isFalse);
      expect(faithIsHolyDay(DateTime(2026, 6, 30)), isFalse);
    });

    test('plain check-in on a holy day earns double points', () {
      final r = computeFaithCheckin(
        lastCheckinDayKey: faithDayKey(DateTime(2026, 7, 6)),
        currentStreak: 1,
        now: DateTime(2026, 7, 7, 9), // วันพระ
      );
      expect(r.isNewDay, isTrue);
      expect(r.isHolyDay, isTrue);
      expect(r.newStreak, 2);
      expect(r.pointsEarned, kFaithDailyCheckin * 2);
    });

    test('streak bonus is doubled too when hit on a holy day', () {
      final r = computeFaithCheckin(
        lastCheckinDayKey: faithDayKey(DateTime(2026, 7, 6)),
        currentStreak: 2,
        now: DateTime(2026, 7, 7, 9), // วันพระ + แตะ streak 3 พอดี
      );
      expect(r.newStreak, 3);
      expect(r.pointsEarned, (kFaithDailyCheckin + kFaithStreak3Bonus) * 2);
    });

    test('normal day check-in reports isHolyDay=false, no multiplier', () {
      final r = computeFaithCheckin(
        lastCheckinDayKey: null,
        currentStreak: 0,
        now: DateTime(2026, 7, 8, 9),
      );
      expect(r.isHolyDay, isFalse);
      expect(r.pointsEarned, kFaithDailyCheckin);
    });

    test('same-day repeat on a holy day still flags isHolyDay, earns 0', () {
      final holy = DateTime(2026, 7, 7, 9);
      final r = computeFaithCheckin(
        lastCheckinDayKey: faithDayKey(holy),
        currentStreak: 2,
        now: holy.add(const Duration(hours: 5)),
      );
      expect(r.isNewDay, isFalse);
      expect(r.isHolyDay, isTrue);
      expect(r.pointsEarned, 0);
    });
  });

  group('faithWeekKey', () {
    test('Monday is the first day of the week (ISO)', () {
      expect(faithWeekKey(DateTime(2026, 7, 6)), '2026-W28'); // จันทร์
      expect(faithWeekKey(DateTime(2026, 7, 12)), '2026-W28'); // อาทิตย์เดียวกัน
      expect(faithWeekKey(DateTime(2026, 7, 5)), '2026-W27'); // อาทิตย์ก่อนหน้า
      expect(faithWeekKey(DateTime(2026, 7, 13)), '2026-W29'); // จันทร์ถัดไป
    });

    test('cross-year boundaries follow ISO week-year', () {
      // 1 ม.ค. 2027 (ศุกร์) ยังอยู่สัปดาห์สุดท้ายของปี 2026 (W53)
      expect(faithWeekKey(DateTime(2027, 1, 1)), '2026-W53');
      expect(faithWeekKey(DateTime(2026, 12, 28)), '2026-W53'); // จันทร์
      // 29 ธ.ค. 2025 (จันทร์) เป็นสัปดาห์แรกของปี 2026 (W01)
      expect(faithWeekKey(DateTime(2025, 12, 29)), '2026-W01');
      expect(faithWeekKey(DateTime(2026, 1, 4)), '2026-W01'); // อาทิตย์
    });
  });

  group('weekly quest bonus (pure)', () {
    // สัปดาห์ 3–9 ส.ค. 2026 — 3/4/5 ส.ค. ไม่ใช่วันพระ
    final mon = DateTime(2026, 8, 3, 20);
    final tue = DateTime(2026, 8, 4, 20);
    final wed = DateTime(2026, 8, 5, 20);

    test('days 1 and 2 count but earn no bonus yet', () {
      final d1 = computeFaithWeeklyQuest(
        lastFullQuestDayKey: null,
        daysThisWeek: 0,
        bonusClaimed: false,
        now: mon,
      );
      expect(d1.countsToday, isTrue);
      expect(d1.newDaysThisWeek, 1);
      expect(d1.pointsEarned, 0);

      final d2 = computeFaithWeeklyQuest(
        lastFullQuestDayKey: faithDayKey(mon),
        daysThisWeek: 1,
        bonusClaimed: false,
        now: tue,
      );
      expect(d2.countsToday, isTrue);
      expect(d2.newDaysThisWeek, 2);
      expect(d2.pointsEarned, 0);
    });

    test('third full-quest day of the week earns the +30 bonus', () {
      final d3 = computeFaithWeeklyQuest(
        lastFullQuestDayKey: faithDayKey(tue),
        daysThisWeek: 2,
        bonusClaimed: false,
        now: wed,
      );
      expect(d3.countsToday, isTrue);
      expect(d3.newDaysThisWeek, kFaithWeeklyBonusTargetDays);
      expect(d3.pointsEarned, kFaithWeeklyBonusPoints);
    });

    test('bonus is doubled when the third day lands on a holy day', () {
      final d3holy = computeFaithWeeklyQuest(
        lastFullQuestDayKey: faithDayKey(DateTime(2026, 8, 5)),
        daysThisWeek: 2,
        bonusClaimed: false,
        now: DateTime(2026, 8, 6, 20), // วันพระ
      );
      expect(d3holy.pointsEarned, kFaithWeeklyBonusPoints * 2);
    });

    test('fourth day does not pay the bonus again', () {
      final d4 = computeFaithWeeklyQuest(
        lastFullQuestDayKey: faithDayKey(wed),
        daysThisWeek: 3,
        bonusClaimed: true,
        now: DateTime(2026, 8, 7, 20),
      );
      expect(d4.countsToday, isTrue);
      expect(d4.newDaysThisWeek, 4);
      expect(d4.pointsEarned, 0);
    });

    test('same day never counts twice', () {
      final repeat = computeFaithWeeklyQuest(
        lastFullQuestDayKey: faithDayKey(wed),
        daysThisWeek: 3,
        bonusClaimed: true,
        now: wed.add(const Duration(hours: 2)),
      );
      expect(repeat.countsToday, isFalse);
      expect(repeat.newDaysThisWeek, 3);
      expect(repeat.pointsEarned, 0);
    });

    test('new week starts a fresh count (week keys differ Sun → Mon)', () {
      // service เก็บตัวนับแยกราย week key → สัปดาห์ใหม่อ่านค่าเริ่ม 0 เสมอ
      expect(faithWeekKey(DateTime(2026, 8, 9)),
          isNot(faithWeekKey(DateTime(2026, 8, 10))));
      final freshWeek = computeFaithWeeklyQuest(
        lastFullQuestDayKey: faithDayKey(DateTime(2026, 8, 9)), // อาทิตย์ก่อน
        daysThisWeek: 0, // ค่าใหม่ของ week key ใหม่
        bonusClaimed: false,
        now: DateTime(2026, 8, 10, 20), // จันทร์สัปดาห์ใหม่
      );
      expect(freshWeek.countsToday, isTrue);
      expect(freshWeek.newDaysThisWeek, 1);
      expect(freshWeek.pointsEarned, 0);
    });
  });

  group('level & milestones', () {
    test('level 2 unlocks at the configured threshold', () {
      expect(faithLevelForPoints(0), 1);
      expect(faithLevelForPoints(kFaithLevel2Points - 1), 1);
      expect(faithLevelForPoints(kFaithLevel2Points), 2);
    });

    test('milestone states: locked → claimable → claimed', () {
      final m = FaithMilestone.defaults.first; // 30 ✦
      expect(
        faithMilestoneState(milestone: m, points: 29, claimedIds: {}),
        FaithMilestoneState.locked,
      );
      expect(
        faithMilestoneState(milestone: m, points: 30, claimedIds: {}),
        FaithMilestoneState.claimable,
      );
      expect(
        faithMilestoneState(milestone: m, points: 30, claimedIds: {m.id}),
        FaithMilestoneState.claimed,
      );
    });

    test('wallpaper teaser requires a real merit order, not just points', () {
      final teaser = FaithMilestone.defaults
          .firstWhere((m) => m.id == 'wallpaper_teaser');
      // แต้มถึงแต่ยังไม่เคยฝากมู → ติดล็อกเงื่อนไข (จุด upsell)
      expect(
        faithMilestoneState(
            milestone: teaser, points: 999, claimedIds: {}),
        FaithMilestoneState.lockedNeedsMerit,
      );
      // ฝากมูแล้ว → รับได้
      expect(
        faithMilestoneState(
            milestone: teaser,
            points: teaser.points,
            claimedIds: {},
            hasMeritOrder: true),
        FaithMilestoneState.claimable,
      );
      // แต้มไม่ถึง → locked ปกติ (ยังไม่ต้องพูดเรื่องเงื่อนไข)
      expect(
        faithMilestoneState(
            milestone: teaser, points: 0, claimedIds: {}),
        FaithMilestoneState.locked,
      );
    });

    test('milestones are sorted ascending and end at the Level 2 box', () {
      final pts = FaithMilestone.defaults.map((m) => m.points).toList();
      final sorted = [...pts]..sort();
      expect(pts, sorted);
      expect(FaithMilestone.defaults.last.premiumOnly, isTrue);
      expect(FaithMilestone.defaults.last.points, kFaithLevel2Points);
    });
  });

  group('lucky numbers', () {
    test('deterministic within the same week for the same birthdate', () {
      final birth = DateTime(1991, 6, 15);
      final a = faithLuckyNumbers(
          birthDate: birth, now: DateTime(2026, 7, 6));
      final b = faithLuckyNumbers(
          birthDate: birth, now: DateTime(2026, 7, 8)); // สัปดาห์เดียวกัน
      expect(a, b);
      expect(a.length, 3);
      expect(a.every((n) => n >= 1 && n <= 99), isTrue);
    });

    test('differs for a different birthdate', () {
      final now = DateTime(2026, 7, 6);
      final a =
          faithLuckyNumbers(birthDate: DateTime(1991, 6, 15), now: now);
      final b =
          faithLuckyNumbers(birthDate: DateTime(1988, 1, 2), now: now);
      expect(a, isNot(equals(b)));
    });

    test('handles null birthdate without throwing', () {
      final a = faithLuckyNumbers(birthDate: null, now: DateTime(2026, 7, 6));
      expect(a.length, 3);
    });
  });

  group('home quest strip', () {
    test('next milestone is the first unclaimed one, even if reachable', () {
      expect(faithNextMilestone({})!.id, 'lucky_numbers');
      expect(faithNextMilestone({'lucky_numbers'})!.id, 'merit_coupon');
      // ข้ามรับอันกลาง — อันแรกที่ยังไม่รับยังเป็น "ถัดไป"
      expect(faithNextMilestone({'merit_coupon'})!.id, 'lucky_numbers');
      expect(
        faithNextMilestone({
          'wallpaper_teaser',
          'lucky_numbers',
          'merit_coupon',
          'level2_box',
        }),
        isNull,
      );
    });

    test('segment progress runs from previous station to the next', () {
      final second = FaithMilestone.defaults[1]; // 70 ✦ (ช่วง 30→70)
      expect(faithSegmentProgress(points: 30, next: second), 0.0);
      expect(faithSegmentProgress(points: 50, next: second), 0.5);
      expect(faithSegmentProgress(points: 70, next: second), 1.0);
      // เกินเป้า/ต่ำกว่าช่วง — clamp ปลอดภัย
      expect(faithSegmentProgress(points: 999, next: second), 1.0);
      expect(faithSegmentProgress(points: 0, next: second), 0.0);
      // สถานีแรกวิ่งจาก 0
      final first = FaithMilestone.defaults.first; // 30 ✦
      expect(faithSegmentProgress(points: 15, next: first), 0.5);
    });
  });
}
