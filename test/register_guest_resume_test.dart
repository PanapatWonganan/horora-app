import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:astrology_app/core/services/guest_session_service.dart';
import 'package:astrology_app/features/auth/register/register_screen.dart';
import 'package:astrology_app/features/onboarding/models/onboarding_models.dart';

/// Widget tests สำหรับ guest-first prefill ใน RegisterScreen
///
/// หมายเหตุข้อจำกัด:
/// - RegisterScreen ใช้ AuthService.instance (singleton ยิง Laravel) ตอนกดปุ่ม
///   "สมัครสมาชิก" เท่านั้น เราจึง "ไม่" trigger network ใน test นี้ — แค่ pump
///   หน้าจอแล้วตรวจว่า prefill จาก onboarding/guest data ทำงานถูกต้อง
///   (didChangeDependencies → _applyPrefill) ซึ่งเป็น logic ที่อยู่ในสโคปของ Agent 2
/// - ส่วน pop(true) vs navigateAndClearStack เป็น branch หลัง signUp สำเร็จ
///   ซึ่งต้องอาศัย backend จริง จึงไม่ได้ทดสอบใน widget test นี้ (ทดสอบมือ/integration)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // helper: pump RegisterScreen พร้อมส่ง onboarding data ผ่าน route arguments
  Future<void> pumpRegister(
    WidgetTester tester, {
    OnboardingData? args,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        // ใช้ onGenerateRoute เพื่อแนบ settings.arguments ให้ ModalRoute อ่านได้
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: RouteSettings(name: '/register', arguments: args),
          builder: (_) => const RegisterScreen(),
        ),
        initialRoute: '/register',
      ),
    );
    await tester.pump();
  }

  testWidgets('prefills name & birthDate from OnboardingData route arguments',
      (tester) async {
    final data = OnboardingData(
      name: 'มินทร์',
      birthDate: DateTime(1995, 4, 12),
      interests: {PrimaryInterest.finance},
    );

    await pumpRegister(tester, args: data);

    // ชื่อถูก prefill
    expect(find.text('มินทร์'), findsOneWidget);
    // วันเกิดถูก format เป็น dd/MM/yyyy
    expect(find.text('12/04/1995'), findsOneWidget);
  });

  testWidgets('falls back to guest data when no route arguments passed',
      (tester) async {
    // จำลองว่ามี guest onboarding ค้างอยู่ใน local (เคสถูกเด้งมาจาก AuthGuard)
    await GuestSessionService.instance.saveOnboarding(
      OnboardingData(
        name: 'ดวงใจ',
        birthDate: DateTime(2000, 12, 1),
      ),
    );

    await pumpRegister(tester, args: null);
    // loadOnboarding เป็น async → รอ future + setState
    await tester.pumpAndSettle();

    expect(find.text('ดวงใจ'), findsOneWidget);
    expect(find.text('01/12/2000'), findsOneWidget);
  });

  testWidgets('builds with empty form when no onboarding data anywhere',
      (tester) async {
    await pumpRegister(tester, args: null);
    await tester.pumpAndSettle();

    // หน้าจอ build ได้ปกติ (มีหัวข้อ "สมัครสมาชิก")
    expect(find.text('สมัครสมาชิก'), findsWidgets);
  });
}
