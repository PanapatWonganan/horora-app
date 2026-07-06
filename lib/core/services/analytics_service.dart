import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// บริการส่ง event เข้า Firebase Analytics — จุดเดียวของทั้งแอป
///
/// หลักการ: analytics พังต้องไม่พาแอปพัง — ทุก call ห่อ try/catch
/// (เช่นตอนรันเทสต์/emulator ที่ Firebase ยังไม่ initialize จะเงียบๆ ข้ามไป)
/// และ debugPrint ทุกครั้งเพื่อไล่ดู funnel บน emulator ได้ทันที
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  /// ส่ง event ชื่อ [name] พร้อม [params] (ถ้ามี) — ไม่ throw เด็ดขาด
  Future<void> log(String name, [Map<String, Object>? params]) async {
    debugPrint('[analytics] $name $params');
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: params,
      );
    } catch (e) {
      // Firebase ไม่พร้อม (เช่นในเทสต์) หรือส่งไม่สำเร็จ — ข้ามไปเฉยๆ
      debugPrint('[analytics] log "$name" failed: $e');
    }
  }

  /// บันทึกการเปิดดูหน้าจอ [screenName] — ไม่ throw เด็ดขาด
  Future<void> screen(String screenName) async {
    debugPrint('[analytics] screen_view $screenName');
    try {
      await FirebaseAnalytics.instance.logScreenView(
        screenName: screenName,
      );
    } catch (e) {
      // Firebase ไม่พร้อม (เช่นในเทสต์) หรือส่งไม่สำเร็จ — ข้ามไปเฉยๆ
      debugPrint('[analytics] screen "$screenName" failed: $e');
    }
  }
}
