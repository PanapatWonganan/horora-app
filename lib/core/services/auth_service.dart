import 'package:flutter/material.dart';
import 'laravel_auth_service.dart';

/// Auth Service - wrapper for Laravel Auth
/// This maintains the same interface for existing code
class AuthService {
  static AuthService? _instance;
  final LaravelAuthService _laravelAuth = LaravelAuthService.instance;

  // Singleton pattern
  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  AuthService._();

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _laravelAuth.isLoggedIn();
  }

  // Get current user
  LaravelUser? get currentUser => _laravelAuth.currentUser;

  // Sign up with email and password
  Future<LaravelAuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    DateTime? birthDate,
  }) async {
    try {
      return await _laravelAuth.signUp(
        email: email,
        password: password,
        name: name,
        birthDate: birthDate,
      );
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<LaravelAuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _laravelAuth.signIn(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _laravelAuth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Reset password - not implemented in Laravel yet
  Future<void> resetPassword(String email) async {
    // TODO: Implement password reset via Laravel
    throw UnimplementedError('Password reset not implemented yet');
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = await _laravelAuth.getUserProfile();
      return user?.toJson();
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      await _laravelAuth.updateUserProfile(data);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // Initialize auth (call on app start)
  Future<void> initialize() async {
    await _laravelAuth.initialize();
  }

  // Social login methods - not implemented
  Future<void> signInWithGoogle() async {
    throw UnimplementedError('Google sign-in not implemented yet');
  }

  Future<void> signInWithApple() async {
    throw UnimplementedError('Apple sign-in not implemented yet');
  }

  Future<void> signInWithFacebook() async {
    throw UnimplementedError('Facebook sign-in not implemented yet');
  }
}
