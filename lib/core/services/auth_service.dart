import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../utils/zodiac_utils.dart';

class AuthService {
  static AuthService? _instance;
  final SupabaseService _supabaseService = SupabaseService.instance;

  // Singleton pattern
  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  AuthService._();

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return Supabase.instance.client.auth.currentUser != null;
  }

  // Get current user
  User? get currentUser => Supabase.instance.client.auth.currentUser;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    DateTime? birthDate,
  }) async {
    try {
      // Calculate zodiac sign if birth date is provided
      String? zodiacSign;
      if (birthDate != null) {
        zodiacSign = ZodiacUtils.getZodiacSign(birthDate);
      }

      // Create user data
      final userData = {
        'full_name': name,
        'birth_date': birthDate?.toIso8601String(),
        'zodiac_sign': zodiacSign,
      };

      // Sign up with Supabase
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        userData: userData,
      );

      // Create profile in profiles table
      if (response.user != null) {
        try {
          // สร้างโปรไฟล์ในฐานข้อมูล
          await Supabase.instance.client.from('profiles').insert({
            'user_id': response.user!.id,
            'full_name': name,
            'email': email,
            'birth_date': birthDate?.toIso8601String(),
            'zodiac_sign': zodiacSign,
            'created_at': DateTime.now().toIso8601String(),
            'is_premium': false, // เริ่มต้นเป็นผู้ใช้ฟรี
          });

          debugPrint('User profile created successfully');
        } catch (e) {
          debugPrint('Error creating user profile: $e');
          // ถ้าสร้างโปรไฟล์ไม่สำเร็จ ก็ไม่เป็นไร ผู้ใช้ยังสามารถใช้งานได้
        }
      }

      return response;
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.astrology://reset-password/',
      );
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      debugPrint('Error updating password: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        Provider.google,
        redirectTo: 'io.supabase.astrology://login-callback/',
      );
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        Provider.apple,
        redirectTo: 'io.supabase.astrology://login-callback/',
      );
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      rethrow;
    }
  }

  // Sign in with Facebook
  Future<void> signInWithFacebook() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        Provider.facebook,
        redirectTo: 'io.supabase.astrology://login-callback/',
      );
    } catch (e) {
      debugPrint('Error signing in with Facebook: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      return await _supabaseService.getUserProfile();
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      await _supabaseService.updateUserProfile(data);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> onAuthStateChange() {
    return Supabase.instance.client.auth.onAuthStateChange;
  }
}
