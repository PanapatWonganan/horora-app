import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/features/home/home_screen.dart';

/// Tests for [resolveHomeDisplayName] — the pure precedence function
/// extracted out of `_HomeScreenState._loadUserName` (Home greeting):
///
///   (a) authenticated account name
///   (b) else account email's local-part (before '@')
///   (c) else guest onboarding name
///   (d) else '' (Home falls back to "สวัสดีค่ะ")
void main() {
  group('resolveHomeDisplayName precedence', () {
    test('(a) uses the account name when present, ignoring email/guest', () {
      final name = resolveHomeDisplayName(
        accountName: 'มินทร์',
        accountEmail: 'min@example.com',
        guestName: 'เอ',
      );
      expect(name, 'มินทร์');
    });

    test('(b) falls back to the email local-part when name is empty', () {
      final name = resolveHomeDisplayName(
        accountName: '',
        accountEmail: 'jane.doe@example.com',
        guestName: 'เอ',
      );
      expect(name, 'jane.doe');
    });

    test('(b) falls back to email local-part when name is null', () {
      final name = resolveHomeDisplayName(
        accountName: null,
        accountEmail: 'someone@example.com',
      );
      expect(name, 'someone');
    });

    test('(c) falls back to guest onboarding name when no account name/email',
        () {
      final name = resolveHomeDisplayName(guestName: 'ฝน');
      expect(name, 'ฝน');
    });

    test(
        '(c) falls back to guest name when account name/email are both '
        'empty strings (not null)', () {
      final name = resolveHomeDisplayName(
        accountName: '',
        accountEmail: '',
        guestName: 'ฝน',
      );
      expect(name, 'ฝน');
    });

    test('(d) returns empty string when nothing is available at all', () {
      final name = resolveHomeDisplayName();
      expect(name, '');
    });

    test('(d) returns empty string when every input is an empty string', () {
      final name = resolveHomeDisplayName(
        accountName: '',
        accountEmail: '',
        guestName: '',
      );
      expect(name, '');
    });

    test('email with no local-part text before "@" still splits safely', () {
      final name = resolveHomeDisplayName(accountEmail: '@example.com');
      expect(name, '');
    });
  });
}
