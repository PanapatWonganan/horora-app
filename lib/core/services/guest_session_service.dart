import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constants.dart';
import '../../features/onboarding/models/onboarding_models.dart';

/// GuestSessionService
/// เก็บ/อ่านข้อมูล onboarding ของ guest แบบ local (SharedPreferences)
/// โดยไม่ต้อง login — ใช้ใน guest-first auth flow
///
/// - ข้อมูลเก็บ local เท่านั้น ไม่ส่ง PII ขึ้น server จนกว่าจะสมัคร
/// - การอ่านข้อมูลที่เสียหายจะ return null แทนการ throw (กัน crash)
class GuestSessionService {
  GuestSessionService._();

  /// Singleton instance (ตามแพทเทิร์นเดียวกับ service อื่นในโปรเจกต์)
  static final GuestSessionService instance = GuestSessionService._();

  /// บันทึก onboarding data ของ guest ลง local
  Future<void> saveOnboarding(OnboardingData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_toJson(data));
      await prefs.setString(StorageConstants.guestOnboarding, jsonString);
    } catch (e) {
      debugPrint('GuestSessionService.saveOnboarding error: $e');
    }
  }

  /// อ่าน onboarding data ของ guest (null ถ้าไม่มี หรือ parse ไม่ได้)
  Future<OnboardingData?> loadOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(StorageConstants.guestOnboarding);
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return _fromJson(map);
    } catch (e) {
      debugPrint('GuestSessionService.loadOnboarding error: $e');
      return null;
    }
  }

  /// เช็คว่า onboarding เสร็จแล้วหรือยัง (default false)
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(StorageConstants.onboardingCompleted) ?? false;
    } catch (e) {
      debugPrint('GuestSessionService.isOnboardingCompleted error: $e');
      return false;
    }
  }

  /// ตั้ง flag ว่า onboarding เสร็จแล้ว
  Future<void> markOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageConstants.onboardingCompleted, true);
    } catch (e) {
      debugPrint('GuestSessionService.markOnboardingCompleted error: $e');
    }
  }

  /// ลบข้อมูล onboarding ของ guest (เรียกหลัง sync ขึ้น server สำเร็จ)
  /// คง flag onboardingCompleted ไว้ เพื่อให้ guest ยังอยู่หน้า Home
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageConstants.guestOnboarding);
    } catch (e) {
      debugPrint('GuestSessionService.clear error: $e');
    }
  }

  // --- Serialization helpers ---
  // เขียน serializer/deserializer ในนี้เอง เพราะ OnboardingData มีแต่ toJson()
  // และ TimeOfDay (alias ของ BirthTime) ไม่มี fromJson

  Map<String, dynamic> _toJson(OnboardingData data) {
    final birthTime = data.birthTime;
    return {
      'name': data.name,
      'birth_date': data.birthDate?.toIso8601String(),
      'birth_time': birthTime != null
          ? '${birthTime.hour.toString().padLeft(2, '0')}:'
              '${birthTime.minute.toString().padLeft(2, '0')}'
          : null,
      'primary_interest': data.primaryInterest?.name,
      'spiritual_style': data.spiritualStyle?.name,
      'merit_frequency': data.meritFrequency?.name,
      'wants_notifications': data.wantsNotifications,
    };
  }

  OnboardingData _fromJson(Map<String, dynamic> map) {
    return OnboardingData(
      name: map['name'] as String?,
      birthDate: _parseDate(map['birth_date']),
      birthTime: _parseTime(map['birth_time']),
      primaryInterest: _parseEnum(
        PrimaryInterest.values,
        map['primary_interest'],
      ),
      spiritualStyle: _parseEnum(
        SpiritualStyle.values,
        map['spiritual_style'],
      ),
      meritFrequency: _parseEnum(
        MeritFrequency.values,
        map['merit_frequency'],
      ),
      wantsNotifications: map['wants_notifications'] as bool?,
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  TimeOfDay? _parseTime(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return BirthTime(hour: hour, minute: minute);
  }

  /// แปลงชื่อ enum (.name) กลับเป็นค่า enum; null ถ้าไม่ตรง
  T? _parseEnum<T extends Enum>(List<T> values, dynamic value) {
    if (value is! String || value.isEmpty) return null;
    for (final v in values) {
      if (v.name == value) return v;
    }
    return null;
  }
}
