import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service สำหรับจัดการการขอ rating จากผู้ใช้
/// ใช้ in_app_review เพื่อแสดง native review dialog
class RatingService {
  static final RatingService _instance = RatingService._internal();
  static RatingService get instance => _instance;

  RatingService._internal();

  final InAppReview _inAppReview = InAppReview.instance;

  // Keys สำหรับ SharedPreferences
  static const String _keyActionCount = 'rating_action_count';
  static const String _keyLastPromptDate = 'rating_last_prompt_date';
  static const String _keyHasRated = 'rating_has_rated';
  static const String _keyPromptCount = 'rating_prompt_count';

  // Configuration
  static const int _minActionsBeforePrompt = 3; // จำนวน action ขั้นต่ำก่อนขอ rating
  static const int _daysBetweenPrompts = 30; // วันที่รอก่อนขอ rating อีกครั้ง
  static const int _maxPrompts = 3; // จำนวนครั้งสูงสุดที่จะขอ rating

  /// บันทึก action ที่ผู้ใช้ทำสำเร็จ (ดูดวง, อ่านไพ่ ฯลฯ)
  /// และเช็คว่าควรขอ rating หรือไม่
  Future<bool> recordSuccessfulAction() async {
    final prefs = await SharedPreferences.getInstance();

    // ถ้าเคย rate แล้ว ไม่ต้องถามอีก
    if (prefs.getBool(_keyHasRated) ?? false) {
      return false;
    }

    // เพิ่ม action count
    int actionCount = (prefs.getInt(_keyActionCount) ?? 0) + 1;
    await prefs.setInt(_keyActionCount, actionCount);

    // เช็คว่าควรขอ rating หรือไม่
    return await shouldRequestReview();
  }

  /// เช็คว่าควรขอ rating หรือไม่
  Future<bool> shouldRequestReview() async {
    final prefs = await SharedPreferences.getInstance();

    // ถ้าเคย rate แล้ว
    if (prefs.getBool(_keyHasRated) ?? false) {
      return false;
    }

    // ถ้าขอครบ max แล้ว
    int promptCount = prefs.getInt(_keyPromptCount) ?? 0;
    if (promptCount >= _maxPrompts) {
      return false;
    }

    // เช็ค action count
    int actionCount = prefs.getInt(_keyActionCount) ?? 0;
    if (actionCount < _minActionsBeforePrompt) {
      return false;
    }

    // เช็คว่าผ่านไปกี่วันแล้วตั้งแต่ขอครั้งล่าสุด
    String? lastPromptDateStr = prefs.getString(_keyLastPromptDate);
    if (lastPromptDateStr != null) {
      DateTime lastPromptDate = DateTime.parse(lastPromptDateStr);
      int daysSinceLastPrompt = DateTime.now().difference(lastPromptDate).inDays;
      if (daysSinceLastPrompt < _daysBetweenPrompts) {
        return false;
      }
    }

    return true;
  }

  /// ขอ rating จากผู้ใช้
  /// Returns true ถ้าแสดง review dialog สำเร็จ
  Future<bool> requestReview() async {
    try {
      // เช็คว่า in-app review available หรือไม่
      if (await _inAppReview.isAvailable()) {
        // บันทึกว่าขอ rating แล้ว
        final prefs = await SharedPreferences.getInstance();
        int promptCount = (prefs.getInt(_keyPromptCount) ?? 0) + 1;
        await prefs.setInt(_keyPromptCount, promptCount);
        await prefs.setString(_keyLastPromptDate, DateTime.now().toIso8601String());

        // แสดง native review dialog
        await _inAppReview.requestReview();

        debugPrint('RatingService: Review dialog shown (prompt #$promptCount)');
        return true;
      } else {
        debugPrint('RatingService: In-app review not available');
        return false;
      }
    } catch (e) {
      debugPrint('RatingService: Error requesting review: $e');
      return false;
    }
  }

  /// เปิด store page โดยตรง (สำหรับกรณีที่ต้องการให้ผู้ใช้ไป rate ที่ store)
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: '...', // ใส่ App Store ID สำหรับ iOS
      );
    } catch (e) {
      debugPrint('RatingService: Error opening store listing: $e');
    }
  }

  /// บันทึกว่าผู้ใช้เคย rate แล้ว (เรียกเมื่อผู้ใช้กด rate)
  Future<void> markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasRated, true);
    debugPrint('RatingService: Marked as rated');
  }

  /// บันทึกว่าผู้ใช้ไม่ต้องการให้ถามอีก
  Future<void> neverAskAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPromptCount, _maxPrompts);
    debugPrint('RatingService: Never ask again');
  }

  /// Reset ค่าทั้งหมด (สำหรับ testing)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActionCount);
    await prefs.remove(_keyLastPromptDate);
    await prefs.remove(_keyHasRated);
    await prefs.remove(_keyPromptCount);
    debugPrint('RatingService: Reset all values');
  }

  /// ดึงสถิติปัจจุบัน (สำหรับ debug)
  Future<Map<String, dynamic>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'actionCount': prefs.getInt(_keyActionCount) ?? 0,
      'promptCount': prefs.getInt(_keyPromptCount) ?? 0,
      'hasRated': prefs.getBool(_keyHasRated) ?? false,
      'lastPromptDate': prefs.getString(_keyLastPromptDate),
    };
  }
}

/// Extension method สำหรับเรียกใช้ rating service ง่ายๆ
extension RatingServiceExtension on RatingService {
  /// เรียกใช้หลังจาก action สำเร็จ และแสดง rating ถ้าถึงเงื่อนไข
  Future<void> onSuccessfulAction() async {
    bool shouldAsk = await recordSuccessfulAction();
    if (shouldAsk) {
      await requestReview();
    }
  }
}
