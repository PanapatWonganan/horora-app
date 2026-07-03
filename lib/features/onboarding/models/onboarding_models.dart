/// Models สำหรับ Onboarding Quiz และ A/B Testing
import '../../../core/utils/app_icons.dart';

/// ช่องทางที่ผู้ใช้รู้จักแอป (attribution — เก็บตั้งแต่ต้น flow)
enum ReferralSource {
  tiktok,
  instagram,
  facebook,
  youtube,
  friend, // เพื่อน / คนรู้จักแนะนำ
  appStore, // ค้นหาเจอใน App Store / Google
}

extension ReferralSourceExtension on ReferralSource {
  String get thaiName {
    switch (this) {
      case ReferralSource.tiktok:
        return 'TikTok';
      case ReferralSource.instagram:
        return 'Instagram';
      case ReferralSource.facebook:
        return 'Facebook';
      case ReferralSource.youtube:
        return 'YouTube';
      case ReferralSource.friend:
        return 'เพื่อน / คนรู้จักแนะนำ';
      case ReferralSource.appStore:
        return 'ค้นหาเจอใน App Store / Google';
    }
  }
}

/// ความสนใจหลักของผู้ใช้
enum PrimaryInterest {
  finance, // การเงิน โชคลาภ
  love, // ความรัก คู่ครอง
  career, // การงาน ความก้าวหน้า
  health, // สุขภาพ ครอบครัว
  fortune, // ดวงชะตา ภาพรวม
}

extension PrimaryInterestExtension on PrimaryInterest {
  String get thaiName {
    switch (this) {
      case PrimaryInterest.finance:
        return 'การเงิน โชคลาภ';
      case PrimaryInterest.love:
        return 'ความรัก คู่ครอง';
      case PrimaryInterest.career:
        return 'การงาน ความก้าวหน้า';
      case PrimaryInterest.health:
        return 'สุขภาพ ครอบครัว';
      case PrimaryInterest.fortune:
        return 'ดวงชะตา ภาพรวม';
    }
  }

  String get emoji {
    switch (this) {
      case PrimaryInterest.finance:
        return '💰';
      case PrimaryInterest.love:
        return '💕';
      case PrimaryInterest.career:
        return '💼';
      case PrimaryInterest.health:
        return '🏥';
      case PrimaryInterest.fortune:
        return '🍀';
    }
  }

  String get svgIconPath {
    switch (this) {
      case PrimaryInterest.finance:
        return AppIcons.finance;
      case PrimaryInterest.love:
        return AppIcons.love;
      case PrimaryInterest.career:
        return AppIcons.career;
      case PrimaryInterest.health:
        return AppIcons.health;
      case PrimaryInterest.fortune:
        return AppIcons.fortune;
    }
  }

  String get description {
    switch (this) {
      case PrimaryInterest.finance:
        return 'เสริมดวงโชคลาภ การเงินรุ่งเรือง';
      case PrimaryInterest.love:
        return 'เสริมดวงความรัก เรียกคู่แท้';
      case PrimaryInterest.career:
        return 'เสริมดวงการงาน เติบโตก้าวหน้า';
      case PrimaryInterest.health:
        return 'เสริมดวงสุขภาพ ครอบครัวสุขสันต์';
      case PrimaryInterest.fortune:
        return 'เสริมดวงชะตา ชีวิตราบรื่น';
    }
  }
}

/// สไตล์การเสริมดวง
enum SpiritualStyle {
  merit, // ไหว้พระ ทำบุญ
  divination, // ดูดวง ไพ่ทาโรต์
  amulet, // วัตถุมงคล เครื่องราง
  meditation, // สมาธิ พลังจิต
}

extension SpiritualStyleExtension on SpiritualStyle {
  String get thaiName {
    switch (this) {
      case SpiritualStyle.merit:
        return 'ไหว้พระ ทำบุญ';
      case SpiritualStyle.divination:
        return 'ดูดวง ไพ่ทาโรต์';
      case SpiritualStyle.amulet:
        return 'วัตถุมงคล เครื่องราง';
      case SpiritualStyle.meditation:
        return 'สมาธิ พลังจิต';
    }
  }

  String get emoji {
    switch (this) {
      case SpiritualStyle.merit:
        return '🙏';
      case SpiritualStyle.divination:
        return '🔮';
      case SpiritualStyle.amulet:
        return '📿';
      case SpiritualStyle.meditation:
        return '🧘';
    }
  }

  String get svgIconPath {
    switch (this) {
      case SpiritualStyle.merit:
        return AppIcons.pray;
      case SpiritualStyle.divination:
        return AppIcons.divination;
      case SpiritualStyle.amulet:
        return AppIcons.amulet;
      case SpiritualStyle.meditation:
        return AppIcons.meditation;
    }
  }
}

/// ความถี่ในการทำบุญ
enum MeritFrequency {
  weekly, // ทุกสัปดาห์
  monthly, // ทุกเดือน
  occasionally, // เป็นครั้งคราว
  rarely, // นานๆ ครั้ง
}

extension MeritFrequencyExtension on MeritFrequency {
  String get thaiName {
    switch (this) {
      case MeritFrequency.weekly:
        return 'ทุกสัปดาห์';
      case MeritFrequency.monthly:
        return 'ทุกเดือน';
      case MeritFrequency.occasionally:
        return 'เป็นครั้งคราว';
      case MeritFrequency.rarely:
        return 'นานๆ ครั้ง';
    }
  }
}

/// ข้อมูลผู้ใช้จาก Onboarding
class OnboardingData {
  final String? name;
  final DateTime? birthDate;
  final TimeOfDay? birthTime;
  final ReferralSource? referralSource;

  /// เป้าหมายที่เลือก (เลือกได้มากกว่า 1 ในหน้า Goal)
  final Set<PrimaryInterest> interests;
  final SpiritualStyle? spiritualStyle;
  final MeritFrequency? meritFrequency;
  final bool? wantsNotifications;

  const OnboardingData({
    this.name,
    this.birthDate,
    this.birthTime,
    this.referralSource,
    this.interests = const {},
    this.spiritualStyle,
    this.meritFrequency,
    this.wantsNotifications,
  });

  /// ความสนใจหลัก = ตัวแรกที่เลือก (คงไว้เพื่อ backward-compat กับ
  /// QuizResult/recommendedTemple และ register prefill เดิม)
  PrimaryInterest? get primaryInterest =>
      interests.isNotEmpty ? interests.first : null;

  OnboardingData copyWith({
    String? name,
    DateTime? birthDate,
    TimeOfDay? birthTime,
    ReferralSource? referralSource,
    Set<PrimaryInterest>? interests,
    SpiritualStyle? spiritualStyle,
    MeritFrequency? meritFrequency,
    bool? wantsNotifications,
  }) {
    return OnboardingData(
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      referralSource: referralSource ?? this.referralSource,
      interests: interests ?? this.interests,
      spiritualStyle: spiritualStyle ?? this.spiritualStyle,
      meritFrequency: meritFrequency ?? this.meritFrequency,
      wantsNotifications: wantsNotifications ?? this.wantsNotifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birth_date': birthDate?.toIso8601String(),
      'birth_time': birthTime != null
          ? '${birthTime!.hour}:${birthTime!.minute}'
          : null,
      'referral_source': referralSource?.name,
      'interests': interests.map((e) => e.name).toList(),
      'primary_interest': primaryInterest?.name,
      'spiritual_style': spiritualStyle?.name,
      'merit_frequency': meritFrequency?.name,
      'wants_notifications': wantsNotifications,
    };
  }
}

/// Helper class สำหรับ BirthTime (ใช้ใน OnboardingData)
class BirthTime {
  final int hour;
  final int minute;

  const BirthTime({required this.hour, required this.minute});

  factory BirthTime.fromDateTime(DateTime dateTime) {
    return BirthTime(hour: dateTime.hour, minute: dateTime.minute);
  }

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

// Alias for compatibility
typedef TimeOfDay = BirthTime;

/// ผลวิเคราะห์เบื้องต้นจาก Quiz
class QuizResult {
  final String zodiacSign; // ราศี
  final String chineseZodiac; // ปีนักษัตร
  final String luckyColor; // สีมงคล
  final String luckyNumber; // เลขมงคล
  final String luckyDay; // วันมงคล
  final String recommendedTemple; // วัด/สถานที่แนะนำ
  final String fortunePreview; // คำทำนายเบื้องต้น
  final List<String> tips; // คำแนะนำ

  const QuizResult({
    required this.zodiacSign,
    required this.chineseZodiac,
    required this.luckyColor,
    required this.luckyNumber,
    required this.luckyDay,
    required this.recommendedTemple,
    required this.fortunePreview,
    required this.tips,
  });
}
