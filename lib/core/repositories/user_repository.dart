import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../utils/exceptions.dart';

class UserRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  
  // Key constants for SharedPreferences
  static const String _userKey = 'user_data';
  static const String _settingsKey = 'user_settings';
  static const String _tokenKey = 'auth_token';
  
  UserRepository({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  }) : _apiClient = apiClient, _prefs = prefs;
  
  // ดึงข้อมูลผู้ใช้ปัจจุบัน
  Future<User?> getCurrentUser() async {
    try {
      // ลองดึงข้อมูลจาก SharedPreferences ก่อน
      final String? userData = _prefs.getString(_userKey);
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      
      // ถ้าไม่มีข้อมูลใน SharedPreferences ให้ดึงจาก API
      final response = await _apiClient.get('/user/profile');
      final user = User.fromJson(response);
      
      // บันทึกข้อมูลลงใน SharedPreferences
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      return user;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        // ถ้าไม่ได้รับอนุญาต ให้ล้างข้อมูลผู้ใช้
        await _clearUserData();
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to get user data: ${e.toString()}');
    }
  }
  
  // อัปเดตข้อมูลผู้ใช้
  Future<User> updateUserProfile(User user) async {
    try {
      final response = await _apiClient.put(
        '/user/profile',
        data: user.toJson(),
      );
      
      final updatedUser = User.fromJson(response);
      
      // อัปเดตข้อมูลใน SharedPreferences
      await _prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));
      
      return updatedUser;
    } catch (e) {
      throw DataException('Failed to update user profile: ${e.toString()}');
    }
  }
  
  // อัปเดตรูปโปรไฟล์
  Future<User> updateProfileImage(String imagePath) async {
    try {
      // สร้าง FormData สำหรับอัปโหลดรูปภาพ
      final formData = {
        'profile_image': await _apiClient.createMultipartFile(imagePath),
      };
      
      final response = await _apiClient.postMultipart(
        '/user/profile/image',
        formData: formData,
      );
      
      final updatedUser = User.fromJson(response);
      
      // อัปเดตข้อมูลใน SharedPreferences
      await _prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));
      
      return updatedUser;
    } catch (e) {
      throw DataException('Failed to update profile image: ${e.toString()}');
    }
  }
  
  // ลงทะเบียนผู้ใช้ใหม่
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required DateTime birthDate,
    String? birthTime,
    String? birthLocation,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
        'name': name,
        'birth_date': birthDate.toIso8601String(),
        'birth_time': birthTime,
        'birth_location': birthLocation,
      };
      
      final response = await _apiClient.post('/auth/register', data: data);
      
      // บันทึก token
      if (response['token'] != null) {
        await _prefs.setString(_tokenKey, response['token']);
        _apiClient.setAuthToken(response['token']);
      }
      
      final user = User.fromJson(response['user']);
      
      // บันทึกข้อมูลผู้ใช้
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      // สร้างการตั้งค่าเริ่มต้นสำหรับผู้ใช้ใหม่
      final defaultSettings = UserSettings.defaultSettings(user.id);
      await _prefs.setString(_settingsKey, jsonEncode(defaultSettings.toJson()));
      
      return user;
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }
  
  // เข้าสู่ระบบ
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
      };
      
      final response = await _apiClient.post('/auth/login', data: data);
      
      // บันทึก token
      if (response['token'] != null) {
        await _prefs.setString(_tokenKey, response['token']);
        _apiClient.setAuthToken(response['token']);
      }
      
      final user = User.fromJson(response['user']);
      
      // บันทึกข้อมูลผู้ใช้
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      
      // ดึงการตั้งค่าของผู้ใช้
      await getUserSettings();
      
      return user;
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }
  
  // ออกจากระบบ
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // ถึงแม้จะมีข้อผิดพลาดจาก API ก็ยังต้องล้างข้อมูลผู้ใช้ในเครื่อง
    } finally {
      await _clearUserData();
    }
  }
  
  // ล้างข้อมูลผู้ใช้ทั้งหมดในเครื่อง
  Future<void> _clearUserData() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_settingsKey);
    _apiClient.clearAuthToken();
  }
  
  // ตรวจสอบว่าผู้ใช้เข้าสู่ระบบอยู่หรือไม่
  Future<bool> isLoggedIn() async {
    final token = _prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }
  
  // รีเซ็ตรหัสผ่าน
  Future<void> resetPassword(String email) async {
    try {
      await _apiClient.post('/auth/reset-password', data: {'email': email});
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }
  
  // เปลี่ยนรหัสผ่าน
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      throw AuthException('Password change failed: ${e.toString()}');
    }
  }
  
  // ดึงการตั้งค่าของผู้ใช้
  Future<UserSettings> getUserSettings() async {
    try {
      // ลองดึงข้อมูลจาก SharedPreferences ก่อน
      final String? settingsData = _prefs.getString(_settingsKey);
      if (settingsData != null) {
        return UserSettings.fromJson(jsonDecode(settingsData));
      }
      
      // ถ้าไม่มีข้อมูลใน SharedPreferences ให้ดึงจาก API
      final response = await _apiClient.get('/user/settings');
      final settings = UserSettings.fromJson(response);
      
      // บันทึกข้อมูลลงใน SharedPreferences
      await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
      
      return settings;
    } catch (e) {
      throw DataException('Failed to get user settings: ${e.toString()}');
    }
  }
  
  // อัปเดตการตั้งค่าของผู้ใช้
  Future<UserSettings> updateUserSettings(UserSettings settings) async {
    try {
      final response = await _apiClient.put(
        '/user/settings',
        data: settings.toJson(),
      );
      
      final updatedSettings = UserSettings.fromJson(response);
      
      // อัปเดตข้อมูลใน SharedPreferences
      await _prefs.setString(_settingsKey, jsonEncode(updatedSettings.toJson()));
      
      return updatedSettings;
    } catch (e) {
      throw DataException('Failed to update user settings: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลการแจ้งเตือนของผู้ใช้
  Future<List<UserNotification>> getUserNotifications() async {
    try {
      final response = await _apiClient.get('/user/notifications');
      
      return (response as List)
          .map((item) => UserNotification.fromJson(item))
          .toList();
    } catch (e) {
      throw DataException('Failed to get user notifications: ${e.toString()}');
    }
  }
  
  // ทำเครื่องหมายว่าอ่านการแจ้งเตือนแล้ว
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _apiClient.put('/user/notifications/$notificationId/read');
    } catch (e) {
      throw DataException('Failed to mark notification as read: ${e.toString()}');
    }
  }
  
  // ทำเครื่องหมายว่าอ่านการแจ้งเตือนทั้งหมดแล้ว
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _apiClient.put('/user/notifications/read-all');
    } catch (e) {
      throw DataException('Failed to mark all notifications as read: ${e.toString()}');
    }
  }
  
  // ลบการแจ้งเตือน
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _apiClient.delete('/user/notifications/$notificationId');
    } catch (e) {
      throw DataException('Failed to delete notification: ${e.toString()}');
    }
  }
  
  // ลบการแจ้งเตือนทั้งหมด
  Future<void> deleteAllNotifications() async {
    try {
      await _apiClient.delete('/user/notifications/all');
    } catch (e) {
      throw DataException('Failed to delete all notifications: ${e.toString()}');
    }
  }
} 