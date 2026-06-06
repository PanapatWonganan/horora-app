import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../../config/constants.dart';

/// User model for Laravel API
class LaravelUser {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final DateTime? birthDate;
  final String? birthTime;
  final String? birthPlace;
  final String? avatarUrl;
  final bool isPremium;
  final DateTime? subscriptionEndDate;
  final String? thaiAnimal;
  final String? thaiYearName;
  final String? thaiElement;
  final String? thaiElementFull;

  LaravelUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.birthDate,
    this.birthTime,
    this.birthPlace,
    this.avatarUrl,
    this.isPremium = false,
    this.subscriptionEndDate,
    this.thaiAnimal,
    this.thaiYearName,
    this.thaiElement,
    this.thaiElementFull,
  });

  factory LaravelUser.fromJson(Map<String, dynamic> json) {
    return LaravelUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'])
          : null,
      birthTime: json['birth_time'],
      birthPlace: json['birth_place'],
      avatarUrl: json['avatar_url'],
      isPremium: json['is_premium'] ?? false,
      subscriptionEndDate: json['subscription_end_date'] != null
          ? DateTime.tryParse(json['subscription_end_date'])
          : null,
      thaiAnimal: json['thai_animal'],
      thaiYearName: json['thai_year_name'],
      thaiElement: json['thai_element'],
      thaiElementFull: json['thai_element_full'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'birth_time': birthTime,
      'birth_place': birthPlace,
      'avatar_url': avatarUrl,
      'is_premium': isPremium,
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
      'thai_animal': thaiAnimal,
      'thai_year_name': thaiYearName,
      'thai_element': thaiElement,
      'thai_element_full': thaiElementFull,
    };
  }
}

/// Auth response from Laravel API
class LaravelAuthResponse {
  final LaravelUser user;
  final String token;

  LaravelAuthResponse({
    required this.user,
    required this.token,
  });

  factory LaravelAuthResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final token = json['token'];
    if (user is! Map<String, dynamic> || token is! String) {
      // Surface a clear error instead of an opaque TypeError when the API
      // returns an unexpected body (e.g. an error payload) for an auth call.
      throw const FormatException('Invalid auth response: missing user or token');
    }
    return LaravelAuthResponse(
      user: LaravelUser.fromJson(user),
      token: token,
    );
  }
}

/// Laravel Auth Service
class LaravelAuthService {
  static LaravelAuthService? _instance;
  final ApiClient _apiClient;
  LaravelUser? _currentUser;
  String? _token;

  // Singleton pattern
  static LaravelAuthService get instance {
    _instance ??= LaravelAuthService._();
    return _instance!;
  }

  LaravelAuthService._() : _apiClient = ApiClient();

  // Get current user
  LaravelUser? get currentUser => _currentUser;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    if (_token != null && _currentUser != null) {
      return true;
    }

    // Try to restore from storage
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(StorageConstants.authToken);

    if (savedToken != null) {
      _token = savedToken;
      _apiClient.setAuthToken(savedToken);

      try {
        await _fetchCurrentUser();
        return true;
      } catch (e) {
        // Token expired or invalid
        await _clearAuth();
        return false;
      }
    }

    return false;
  }

  // Sign up with email and password
  Future<LaravelAuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    DateTime? birthDate,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'birth_date': birthDate?.toIso8601String().split('T')[0],
        },
      );

      final authResponse = LaravelAuthResponse.fromJson(response);
      await _saveAuth(authResponse);

      return authResponse;
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
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = LaravelAuthResponse.fromJson(response);
      await _saveAuth(authResponse);

      return authResponse;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (_token != null) {
        await _apiClient.post('/auth/logout');
      }
    } catch (e) {
      debugPrint('Error signing out from server: $e');
    } finally {
      await _clearAuth();
    }
  }

  // Get user profile
  Future<LaravelUser?> getUserProfile() async {
    try {
      await _fetchCurrentUser();
      return _currentUser;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<LaravelUser> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/auth/profile', data: data);
      _currentUser = LaravelUser.fromJson(response);

      // Save updated user to storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          StorageConstants.userProfile, _currentUser!.toJson().toString());

      return _currentUser!;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // Private: Save auth data
  Future<void> _saveAuth(LaravelAuthResponse authResponse) async {
    _currentUser = authResponse.user;
    _token = authResponse.token;
    _apiClient.setAuthToken(authResponse.token);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageConstants.authToken, authResponse.token);
    await prefs.setInt(StorageConstants.userId, authResponse.user.id);
  }

  // Private: Clear auth data
  Future<void> _clearAuth() async {
    _currentUser = null;
    _token = null;
    _apiClient.clearAuthToken();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageConstants.authToken);
    await prefs.remove(StorageConstants.userId);
    await prefs.remove(StorageConstants.userProfile);
  }

  // Private: Fetch current user from server
  Future<void> _fetchCurrentUser() async {
    final response = await _apiClient.get('/auth/user');
    // Some APIs wrap the user under a `user`/`data` key; unwrap if needed.
    final dynamic payload =
        (response is Map<String, dynamic> && response['user'] is Map)
            ? response['user']
            : (response is Map<String, dynamic> && response['data'] is Map)
                ? response['data']
                : response;
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Invalid /auth/user response');
    }
    _currentUser = LaravelUser.fromJson(payload);
  }

  // Get current auth token
  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageConstants.authToken);
  }

  // Get API client for other services
  ApiClient get apiClient {
    return _apiClient;
  }

  // Initialize auth (call on app start)
  Future<void> initialize() async {
    await isLoggedIn();
  }
}
