import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../config/constants.dart';

/// รหัสประจำเครื่อง (uuid v4) สร้างครั้งเดียวแล้ว persist —
/// ใช้ผูกสิทธิ์มูฟรี/คูปอง/แต้มศรัทธากับเครื่องฝั่ง server และเป็น
/// external id ของ OneSignal ให้ backend ยิง push รายคนได้
/// (ลบแอป = ได้ id ใหม่ — ฝั่ง server จึงกันสิทธิ์ด้วยเบอร์โทรควบอีกชั้น)
class DeviceIdService {
  DeviceIdService._();
  static final DeviceIdService instance = DeviceIdService._();

  String? _cached;

  Future<String> getOrCreate() async {
    final cached = _cached;
    if (cached != null) return cached;
    try {
      final prefs = await SharedPreferences.getInstance();
      var id = prefs.getString(StorageConstants.deviceId);
      if (id == null || id.isEmpty) {
        id = const Uuid().v4();
        await prefs.setString(StorageConstants.deviceId, id);
      }
      _cached = id;
      return id;
    } catch (e) {
      // prefs พัง — คืน id ชั่วคราว (ไม่ persist) เพื่อไม่ให้ flow อื่นล้ม
      debugPrint('DeviceIdService.getOrCreate error: $e');
      return _cached ??= const Uuid().v4();
    }
  }
}
