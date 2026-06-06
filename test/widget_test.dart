// Smoke test for the guest-first app shell.
//
// The default `flutter create` counter test was removed because this app has no
// counter. Instead we verify the app boots into the AuthWrapper gate, which
// decides between the guest/onboarding flow and Home without crashing.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:astrology_app/app.dart';
import 'package:astrology_app/features/auth/auth_wrapper.dart';

void main() {
  testWidgets('App boots into AuthWrapper without crashing',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AstrologyApp());
    // First frame: AuthWrapper is mounted and shows its loading state while it
    // resolves auth/onboarding status.
    await tester.pump();

    expect(find.byType(AuthWrapper), findsOneWidget);
  });
}
