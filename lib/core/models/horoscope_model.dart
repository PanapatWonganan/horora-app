import '../services/thai_zodiac_service.dart';

class DailyHoroscope {
  final int id;
  final String thaiAnimal; // ชวด, ฉลู, ขาล...
  final DateTime date;
  final String content;
  final String contentTh;
  final int loveRating;
  final int careerRating;
  final int healthRating;
  final String luckyNumber;
  final String luckyColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyHoroscope({
    required this.id,
    required this.thaiAnimal,
    required this.date,
    required this.content,
    required this.contentTh,
    required this.loveRating,
    required this.careerRating,
    required this.healthRating,
    required this.luckyNumber,
    required this.luckyColor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyHoroscope.fromJson(Map<String, dynamic> json) {
    return DailyHoroscope(
      id: json['id'],
      thaiAnimal: json['thai_animal'],
      date: DateTime.parse(json['date']),
      content: json['content'],
      contentTh: json['content_th'],
      loveRating: json['love_rating'],
      careerRating: json['career_rating'],
      healthRating: json['health_rating'],
      luckyNumber: json['lucky_number'],
      luckyColor: json['lucky_color'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thai_animal': thaiAnimal,
      'date': date.toIso8601String().split('T')[0],
      'content': content,
      'content_th': contentTh,
      'love_rating': loveRating,
      'career_rating': careerRating,
      'health_rating': healthRating,
      'lucky_number': luckyNumber,
      'lucky_color': luckyColor,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ThaiHoroscopeReading {
  final String animalName; // ชวด, ฉลู, ขาล...
  final String element;    // ทอง, น้ำ, ไม้, ไฟ, ดิน
  final DateTime date;
  final String overallFortune;
  final String loveAdvice;
  final String careerAdvice;
  final String healthAdvice;
  final String luckyItems;
  final int overallScore;
  final int loveScore;
  final int careerScore;
  final int healthScore;
  final String luckyNumber;
  final String luckyColor;
  final String luckyDirection;

  ThaiHoroscopeReading({
    required this.animalName,
    required this.element,
    required this.date,
    required this.overallFortune,
    required this.loveAdvice,
    required this.careerAdvice,
    required this.healthAdvice,
    required this.luckyItems,
    required this.overallScore,
    required this.loveScore,
    required this.careerScore,
    required this.healthScore,
    required this.luckyNumber,
    required this.luckyColor,
    required this.luckyDirection,
  });

  factory ThaiHoroscopeReading.fromJson(Map<String, dynamic> json) {
    return ThaiHoroscopeReading(
      animalName: json['animal_name'],
      element: json['element'],
      date: DateTime.parse(json['date']),
      overallFortune: json['overall_fortune'],
      loveAdvice: json['love_advice'],
      careerAdvice: json['career_advice'],
      healthAdvice: json['health_advice'],
      luckyItems: json['lucky_items'],
      overallScore: json['overall_score'],
      loveScore: json['love_score'],
      careerScore: json['career_score'],
      healthScore: json['health_score'],
      luckyNumber: json['lucky_number'],
      luckyColor: json['lucky_color'],
      luckyDirection: json['lucky_direction'] ?? 'ทิศตะวันออก',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animal_name': animalName,
      'element': element,
      'date': date.toIso8601String().split('T')[0],
      'overall_fortune': overallFortune,
      'love_advice': loveAdvice,
      'career_advice': careerAdvice,
      'health_advice': healthAdvice,
      'lucky_items': luckyItems,
      'overall_score': overallScore,
      'love_score': loveScore,
      'career_score': careerScore,
      'health_score': healthScore,
      'lucky_number': luckyNumber,
      'lucky_color': luckyColor,
      'lucky_direction': luckyDirection,
    };
  }

  /// Create from Thai Zodiac service
  factory ThaiHoroscopeReading.fromThaiZodiac(ThaiZodiac zodiac, DateTime date) {
    final dailyFortune = ThaiZodiacService.getDailyFortune(zodiac, date);
    
    return ThaiHoroscopeReading(
      animalName: zodiac.animalName,
      element: zodiac.element,
      date: date,
      overallFortune: 'วันนี้เป็นวันที่ดีสำหรับท่าน ${zodiac.thaiName}',
      loveAdvice: 'ดาวศุกร์ส่องแสงให้กับเรื่องความรัก',
      careerAdvice: 'การงานมีความคืบหน้า ใช้ความขยันของ${zodiac.animalName}',
      healthAdvice: 'ดูแลสุขภาพให้ดี พักผ่อนให้เพียงพอ',
      luckyItems: 'พระเครื่องที่เหมาะสม คือพระที่ช่วยเสริมธาตุ${zodiac.element}',
      overallScore: dailyFortune['overall_luck'],
      loveScore: dailyFortune['love'],
      careerScore: dailyFortune['career'],
      healthScore: dailyFortune['health'],
      luckyNumber: dailyFortune['lucky_number'].toString(),
      luckyColor: dailyFortune['lucky_color'],
      luckyDirection: _getLuckyDirection(zodiac.element),
    );
  }

  static String _getLuckyDirection(String element) {
    switch (element) {
      case 'ทอง': return 'ทิศตะวันตก';
      case 'น้ำ': return 'ทิศเหนือ';
      case 'ไม้': return 'ทิศตะวันออก';
      case 'ไฟ': return 'ทิศใต้';
      case 'ดิน': return 'ทิศตะวันตกเฉียงใต้';
      default: return 'ทิศตะวันออก';
    }
  }
}

class ThaiZodiacCompatibility {
  final String animal1;       // ชวด, ฉลู, ขาล...
  final String animal2;       // ชวด, ฉลู, ขาล...
  final String person1Name;
  final String person2Name;
  final int overallScore;     // คะแนนรวม 0-100
  final int loveScore;        // คะแนนความรัก 0-100
  final int friendshipScore;  // คะแนนมิตรภาพ 0-100
  final int workScore;        // คะแนนการทำงาน 0-100
  final String analysis;      // การวิเคราะห์ความเข้ากัน
  final String advice;        // คำแนะนำ
  final List<String> strengths;   // จุดแข็งของคู่นี้
  final List<String> challenges;  // สิ่งที่ต้องระวัง

  ThaiZodiacCompatibility({
    required this.animal1,
    required this.animal2,
    required this.person1Name,
    required this.person2Name,
    required this.overallScore,
    required this.loveScore,
    required this.friendshipScore,
    required this.workScore,
    required this.analysis,
    required this.advice,
    required this.strengths,
    required this.challenges,
  });

  factory ThaiZodiacCompatibility.fromJson(Map<String, dynamic> json) {
    return ThaiZodiacCompatibility(
      animal1: json['animal1'],
      animal2: json['animal2'],
      person1Name: json['person1_name'],
      person2Name: json['person2_name'],
      overallScore: json['overall_score'],
      loveScore: json['love_score'],
      friendshipScore: json['friendship_score'],
      workScore: json['work_score'],
      analysis: json['analysis'],
      advice: json['advice'],
      strengths: List<String>.from(json['strengths'] ?? []),
      challenges: List<String>.from(json['challenges'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animal1': animal1,
      'animal2': animal2,
      'person1_name': person1Name,
      'person2_name': person2Name,
      'overall_score': overallScore,
      'love_score': loveScore,
      'friendship_score': friendshipScore,
      'work_score': workScore,
      'analysis': analysis,
      'advice': advice,
      'strengths': strengths,
      'challenges': challenges,
    };
  }

  /// Create compatibility check from two Thai zodiacs
  factory ThaiZodiacCompatibility.fromZodiacs(
    ThaiZodiac zodiac1,
    ThaiZodiac zodiac2,
    String person1Name,
    String person2Name,
  ) {
    // คำนวณคะแนนความเข้ากัน
    final compatibilityText = ThaiZodiacService.getCompatibility(zodiac1, zodiac2);
    int overallScore;
    
    if (compatibilityText.contains('เข้ากันดีมาก')) {
      overallScore = 85 + (DateTime.now().millisecond % 15); // 85-99
    } else if (compatibilityText.contains('เข้ากันได้ดี')) {
      overallScore = 70 + (DateTime.now().millisecond % 15); // 70-84
    } else {
      overallScore = 55 + (DateTime.now().millisecond % 15); // 55-69
    }

    return ThaiZodiacCompatibility(
      animal1: zodiac1.animalName,
      animal2: zodiac2.animalName,
      person1Name: person1Name,
      person2Name: person2Name,
      overallScore: overallScore,
      loveScore: overallScore + (-5 + (DateTime.now().microsecond % 10)),
      friendshipScore: overallScore + (-3 + (DateTime.now().microsecond % 6)),
      workScore: overallScore + (-7 + (DateTime.now().microsecond % 14)),
      analysis: compatibilityText,
      advice: _getAdvice(zodiac1, zodiac2),
      strengths: _getStrengths(zodiac1, zodiac2),
      challenges: _getChallenges(zodiac1, zodiac2),
    );
  }

  static String _getAdvice(ThaiZodiac zodiac1, ThaiZodiac zodiac2) {
    if (zodiac1.element == zodiac2.element) {
      return 'ทั้งคู่เป็นธาตุเดียวกัน ควรเข้าใจกันได้ดี แต่อย่าดื้อรั้นเกินไป';
    } else {
      return 'ธาตุต่างกันทำให้มีมุมมองต่างกัน ใช้ความอดทนและเปิดใจรับฟัง';
    }
  }

  static List<String> _getStrengths(ThaiZodiac zodiac1, ThaiZodiac zodiac2) {
    return [
      'มีจุดแข็งเสริมกัน',
      'สามารถเรียนรู้จากกันได้',
      'มีเป้าหมายร่วมกันได้ดี'
    ];
  }

  static List<String> _getChallenges(ThaiZodiac zodiac1, ThaiZodiac zodiac2) {
    return [
      'ต้องใช้เวลาทำความเข้าใจกัน',
      'อาจมีมุมมองต่างกันในบางเรื่อง',
      'ควรหลีกเลี่ยงการโต้แย้งเล็กๆ น้อยๆ'
    ];
  }
} 