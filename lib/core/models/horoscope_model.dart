class DailyHoroscope {
  final int id;
  final String zodiacSign;
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
    required this.zodiacSign,
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
      zodiacSign: json['zodiac_sign'],
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
      'zodiac_sign': zodiacSign,
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

class ZodiacSign {
  final String name;
  final String nameEn;
  final String dateRange;
  final String element;
  final String symbol;
  final String imagePath;

  ZodiacSign({
    required this.name,
    required this.nameEn,
    required this.dateRange,
    required this.element,
    required this.symbol,
    required this.imagePath,
  });

  factory ZodiacSign.fromJson(Map<String, dynamic> json) {
    return ZodiacSign(
      name: json['name'],
      nameEn: json['name_en'],
      dateRange: json['date_range'],
      element: json['element'],
      symbol: json['symbol'],
      imagePath: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'name_en': nameEn,
      'date_range': dateRange,
      'element': element,
      'symbol': symbol,
      'image': imagePath,
    };
  }

  // ฟังก์ชันสำหรับคำนวณราศีจากวันเกิด
  static String calculateZodiacSign(DateTime birthDate) {
    final int day = birthDate.day;
    final int month = birthDate.month;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return 'ราศีเมษ';
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return 'ราศีพฤษภ';
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return 'ราศีเมถุน';
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return 'ราศีกรกฎ';
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return 'ราศีสิงห์';
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return 'ราศีกันย์';
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return 'ราศีตุลย์';
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return 'ราศีพิจิก';
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'ราศีธนู';
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 'ราศีมังกร';
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'ราศีกุมภ์';
    } else {
      return 'ราศีมีน';
    }
  }
}

class ZodiacCompatibility {
  final String sign1;
  final String sign2;
  final int compatibilityScore;
  final String description;
  final String descriptionTh;

  ZodiacCompatibility({
    required this.sign1,
    required this.sign2,
    required this.compatibilityScore,
    required this.description,
    required this.descriptionTh,
  });

  factory ZodiacCompatibility.fromJson(Map<String, dynamic> json) {
    return ZodiacCompatibility(
      sign1: json['sign1'],
      sign2: json['sign2'],
      compatibilityScore: json['compatibility_score'],
      description: json['description'],
      descriptionTh: json['description_th'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sign1': sign1,
      'sign2': sign2,
      'compatibility_score': compatibilityScore,
      'description': description,
      'description_th': descriptionTh,
    };
  }
} 