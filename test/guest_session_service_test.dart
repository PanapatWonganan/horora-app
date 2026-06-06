import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:astrology_app/core/services/guest_session_service.dart';
import 'package:astrology_app/features/onboarding/models/onboarding_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = GuestSessionService.instance;

  setUp(() {
    // เริ่มแต่ละ test ด้วย SharedPreferences ที่ว่าง
    SharedPreferences.setMockInitialValues({});
  });

  group('GuestSessionService save/load roundtrip', () {
    test('preserves birthDate & primaryInterest', () async {
      final birthDate = DateTime(1995, 4, 12);

      final onboarding = OnboardingData(
        name: 'มินทร์',
        birthDate: birthDate,
        birthTime: const BirthTime(hour: 8, minute: 5),
        primaryInterest: PrimaryInterest.finance,
        spiritualStyle: SpiritualStyle.merit,
        meritFrequency: MeritFrequency.monthly,
        wantsNotifications: true,
      );

      await service.saveOnboarding(onboarding);
      final loaded = await service.loadOnboarding();

      expect(loaded, isNotNull);
      expect(loaded!.name, 'มินทร์');
      expect(loaded.birthDate, birthDate);
      expect(loaded.primaryInterest, PrimaryInterest.finance);
      expect(loaded.spiritualStyle, SpiritualStyle.merit);
      expect(loaded.meritFrequency, MeritFrequency.monthly);
      expect(loaded.wantsNotifications, true);
      expect(loaded.birthTime, isNotNull);
      expect(loaded.birthTime!.hour, 8);
      expect(loaded.birthTime!.minute, 5);
    });

    test('returns null when nothing saved', () async {
      final loaded = await service.loadOnboarding();
      expect(loaded, isNull);
    });

    test('tolerates null optional fields', () async {
      const onboarding = OnboardingData(name: 'เอ');

      await service.saveOnboarding(onboarding);
      final loaded = await service.loadOnboarding();

      expect(loaded, isNotNull);
      expect(loaded!.name, 'เอ');
      expect(loaded.birthDate, isNull);
      expect(loaded.birthTime, isNull);
      expect(loaded.primaryInterest, isNull);
      expect(loaded.spiritualStyle, isNull);
    });
  });

  group('GuestSessionService onboardingCompleted flag', () {
    test('defaults to false then true after mark', () async {
      expect(await service.isOnboardingCompleted(), isFalse);

      await service.markOnboardingCompleted();

      expect(await service.isOnboardingCompleted(), isTrue);
    });
  });

  group('GuestSessionService clear', () {
    test('removes onboarding data but keeps completed flag', () async {
      const onboarding = OnboardingData(
        name: 'ฝน',
        primaryInterest: PrimaryInterest.love,
      );
      await service.saveOnboarding(onboarding);
      await service.markOnboardingCompleted();

      await service.clear();

      // onboarding data ถูกลบ
      expect(await service.loadOnboarding(), isNull);
      // แต่ flag ยังอยู่ → guest ยังอยู่หน้า Home
      expect(await service.isOnboardingCompleted(), isTrue);
    });
  });
}
