import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import 'auth_service.dart';

/// AuthGuard
/// Helper สำหรับ guest-first flow: gate เฉพาะ action ที่ต้อง login
/// (save reading / chat AI / merit order / affiliate / profile / history)
///
/// วิธีใช้ที่ caller:
/// ```dart
/// if (await AuthGuard.requireAuth(context)) {
///   // ...ทำ action ต่อ (resume)...
/// }
/// ```
class AuthGuard {
  AuthGuard._();

  /// คืน true ถ้า login แล้ว (ทำ action ต่อได้ทันที)
  /// ถ้ายังเป็น guest → เด้งหน้า Register แล้วรอผล
  ///   - สมัครสำเร็จ (RegisterScreen pop ค่า truthy) → return true
  ///   - user ยกเลิก → return false
  ///
  /// [intentLabel] ใช้บอก context ของ action ที่กำลังจะทำ (เผื่อ prefill / UX)
  static Future<bool> requireAuth(
    BuildContext context, {
    String? intentLabel,
  }) async {
    // ใช้ in-memory token ก่อนเพื่อไม่ block UI
    final loggedIn = await AuthService.instance.isLoggedIn();
    if (loggedIn) {
      return true;
    }

    if (!context.mounted) return false;

    // เด้งหน้าสมัคร แล้วรอผล
    // RegisterScreen จะ Navigator.pop(true) เมื่อสมัครสำเร็จ (งานของ Agent 2)
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.register,
      arguments: intentLabel,
    );

    // ถือว่าสำเร็จเมื่อผลที่ pop กลับมาเป็น truthy (true)
    if (result == true) {
      return true;
    }

    // เผื่อกรณีผู้ใช้ไปทาง "เข้าสู่ระบบ" จาก Register แล้ว login สำเร็จ
    // (login เคลียร์ stack → route ที่เรา push รอผลถูกถอดออก, future คืน null
    // ไม่ใช่ true) — re-check สถานะ login จริงก่อนตัดสินว่ายกเลิก
    final loggedInAfter = await AuthService.instance.isLoggedIn();
    return loggedInAfter;
  }
}
