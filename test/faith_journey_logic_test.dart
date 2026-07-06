import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/features/journey/models/faith_models.dart';

void main() {
  group('computeFaithCheckin', () {
    final monday = DateTime(2026, 7, 6, 8, 30);

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
}
