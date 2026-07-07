import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/constants.dart';
import '../models/merit_models.dart';

/// เก็บ reference ออเดอร์บุญของ guest ลงเครื่อง (SharedPreferences)
/// — funnel มูฟรี/weekly เป็น guest ทั้งหมด ไม่มี user id ผูก จึงต้อง
/// จำ id ออเดอร์ที่เพิ่งสร้างไว้ในเครื่อง เพื่อดึงสถานะ/รูปไหว้ตัวเองได้
/// ผ่าน guest status endpoint (authorize ด้วย device_id)
class GuestOrderStore {
  GuestOrderStore._();
  static final GuestOrderStore instance = GuestOrderStore._();

  /// เพิ่มออเดอร์ที่เพิ่งสร้าง (กันซ้ำด้วย id; เก็บเฉพาะที่มี id ไม่ null)
  Future<void> add(MeritOrder order) async {
    try {
      final id = order.id;
      if (id == null || id.isEmpty) return; // ไม่มี id ผูกไม่ได้ — ข้าม

      final prefs = await SharedPreferences.getInstance();
      final list = _read(prefs);

      // กันซ้ำ: ถ้ามี id นี้อยู่แล้วไม่ต้องเพิ่ม
      if (list.any((e) => e['id'] == id)) return;

      list.add({
        'id': id,
        'order_number': order.orderNumber,
        'created_at': (order.createdAt ?? DateTime.now()).toIso8601String(),
      });
      await prefs.setString(
        StorageConstants.guestMeritOrders,
        jsonEncode(list),
      );
    } catch (e) {
      debugPrint('GuestOrderStore.add error: $e');
    }
  }

  /// คืน id ทั้งหมด (ใหม่สุดก่อน)
  Future<List<String>> orderIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _read(prefs);
      // เรียงใหม่สุดก่อนด้วย created_at (fallback: คงลำดับเดิม)
      list.sort((a, b) {
        final da = DateTime.tryParse(a['created_at']?.toString() ?? '');
        final db = DateTime.tryParse(b['created_at']?.toString() ?? '');
        if (da == null || db == null) return 0;
        return db.compareTo(da);
      });
      return list
          .map((e) => e['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('GuestOrderStore.orderIds error: $e');
      return [];
    }
  }

  /// อ่าน list ดิบจาก prefs (คืน list ว่างถ้า decode พลาด)
  List<Map<String, dynamic>> _read(SharedPreferences prefs) {
    final raw = prefs.getString(StorageConstants.guestMeritOrders);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
