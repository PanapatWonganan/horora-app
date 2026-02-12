import '../services/thai_zodiac_service.dart';

class User {
  final int id;
  final String email;
  final String name;
  final DateTime? birthDate;
  final String? birthTime;
  final String? birthLocation;
  final String? thaiAnimal;      // ชวด, ฉลู, ขาล...
  final String? thaiYearName;    // ปีชวด, ปีฉลู...
  final String? thaiElement;     // ทอง, น้ำ, ไม้, ไฟ, ดิน
  final String? thaiElementFull; // ธาตุทอง, ธาตุน้ำ...
  final String? profileImage;
  final String language;
  final bool isPremium;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.birthDate,
    this.birthTime,
    this.birthLocation,
    this.thaiAnimal,
    this.thaiYearName,
    this.thaiElement,
    this.thaiElementFull,
    this.profileImage,
    required this.language,
    required this.isPremium,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      birthTime: json['birth_time'],
      birthLocation: json['birth_location'],
      thaiAnimal: json['thai_animal'],
      thaiYearName: json['thai_year_name'],
      thaiElement: json['thai_element'],
      thaiElementFull: json['thai_element_full'],
      profileImage: json['profile_image'],
      language: json['language'] ?? 'th',
      isPremium: json['is_premium'] ?? false,
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'birth_date': birthDate?.toIso8601String(),
      'birth_time': birthTime,
      'birth_location': birthLocation,
      'thai_animal': thaiAnimal,
      'thai_year_name': thaiYearName,
      'thai_element': thaiElement,
      'thai_element_full': thaiElementFull,
      'profile_image': profileImage,
      'language': language,
      'is_premium': isPremium,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? name,
    DateTime? birthDate,
    String? birthTime,
    String? birthLocation,
    String? thaiAnimal,
    String? thaiYearName,
    String? thaiElement,
    String? thaiElementFull,
    String? profileImage,
    String? language,
    bool? isPremium,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthLocation: birthLocation ?? this.birthLocation,
      thaiAnimal: thaiAnimal ?? this.thaiAnimal,
      thaiYearName: thaiYearName ?? this.thaiYearName,
      thaiElement: thaiElement ?? this.thaiElement,
      thaiElementFull: thaiElementFull ?? this.thaiElementFull,
      profileImage: profileImage ?? this.profileImage,
      language: language ?? this.language,
      isPremium: isPremium ?? this.isPremium,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get Thai zodiac information from birth date
  ThaiZodiac? get thaiZodiac {
    if (birthDate == null) return null;
    return ThaiZodiacService.getThaiZodiacFromDate(birthDate!);
  }

  /// Check if user has complete Thai zodiac info
  bool get hasThaiZodiacInfo {
    return thaiAnimal != null && thaiElement != null;
  }

  /// Get display name for Thai zodiac
  String get thaiZodiacDisplayName {
    if (thaiYearName != null && thaiElementFull != null) {
      return '$thaiYearName $thaiElementFull';
    } else if (thaiAnimal != null && thaiElement != null) {
      return 'ปี$thaiAnimal ธาตุ$thaiElement';
    } else if (birthDate != null) {
      final zodiac = thaiZodiac;
      return '${zodiac?.thaiName} ${zodiac?.elementThai}';
    }
    return 'ไม่ทราบปีนักษัตร';
  }
} 