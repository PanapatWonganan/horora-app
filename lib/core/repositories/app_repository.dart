import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../utils/exceptions.dart';

class AppRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  
  // Key constants for SharedPreferences
  static const String _appDataKey = 'app_data';
  static const String _appSettingsKey = 'app_settings';
  static const String _lastUpdateCheckKey = 'last_update_check';
  
  AppRepository({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  }) : _apiClient = apiClient, _prefs = prefs;
  
  // ดึงข้อมูลทั่วไปของแอปพลิเคชัน
  Future<AppData> getAppData() async {
    try {
      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final String? cachedData = _prefs.getString(_appDataKey);
      
      if (cachedData != null) {
        return AppData.fromJson(jsonDecode(cachedData));
      }
      
      // ถ้าไม่มีข้อมูลในแคช ให้ดึงจาก API
      final response = await _apiClient.get('/app/data');
      final appData = AppData.fromJson(response);
      
      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_appDataKey, jsonEncode(appData.toJson()));
      
      return appData;
    } catch (e) {
      throw DataException('Failed to get app data: ${e.toString()}');
    }
  }
  
  // ดึงการตั้งค่าของแอปพลิเคชัน
  Future<AppSettings> getAppSettings() async {
    try {
      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final String? cachedData = _prefs.getString(_appSettingsKey);
      
      if (cachedData != null) {
        return AppSettings.fromJson(jsonDecode(cachedData));
      }
      
      // ถ้าไม่มีข้อมูลในแคช ให้ดึงจาก API
      final response = await _apiClient.get('/app/settings');
      final appSettings = AppSettings.fromJson(response);
      
      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_appSettingsKey, jsonEncode(appSettings.toJson()));
      
      return appSettings;
    } catch (e) {
      // ถ้ามีข้อผิดพลาด ให้ใช้ค่าเริ่มต้น
      return AppSettings.defaultSettings();
    }
  }
  
  // ดึงข้อมูล FAQ
  Future<List<FaqItem>> getFaqItems() async {
    try {
      final AppData appData = await getAppData();
      return appData.faqItems;
    } catch (e) {
      throw DataException('Failed to get FAQ items: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลการอัปเดตแอปพลิเคชัน
  Future<List<AppUpdate>> getAppUpdates() async {
    try {
      final AppData appData = await getAppData();
      return appData.appUpdates;
    } catch (e) {
      throw DataException('Failed to get app updates: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลคำรีวิวจากผู้ใช้
  Future<List<Testimonial>> getTestimonials() async {
    try {
      final AppData appData = await getAppData();
      return appData.testimonials;
    } catch (e) {
      throw DataException('Failed to get testimonials: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลช่องทางการติดต่อ
  Future<List<SupportContact>> getSupportContacts() async {
    try {
      final AppData appData = await getAppData();
      return appData.supportContacts;
    } catch (e) {
      throw DataException('Failed to get support contacts: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลนโยบายความเป็นส่วนตัว
  Future<List<PrivacyPolicySection>> getPrivacyPolicy() async {
    try {
      final AppData appData = await getAppData();
      return appData.privacyPolicy;
    } catch (e) {
      throw DataException('Failed to get privacy policy: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลข้อตกลงการใช้งาน
  Future<List<TermsOfServiceSection>> getTermsOfService() async {
    try {
      final AppData appData = await getAppData();
      return appData.termsOfService;
    } catch (e) {
      throw DataException('Failed to get terms of service: ${e.toString()}');
    }
  }
  
  // ตรวจสอบการอัปเดตแอปพลิเคชัน
  Future<AppUpdate?> checkForUpdates() async {
    try {
      // ตรวจสอบว่าตรวจสอบการอัปเดตล่าสุดเมื่อไร
      final String? lastCheckString = _prefs.getString(_lastUpdateCheckKey);
      
      if (lastCheckString != null) {
        final DateTime lastCheck = DateTime.parse(lastCheckString);
        final Duration difference = DateTime.now().difference(lastCheck);
        
        // ถ้าตรวจสอบล่าสุดไม่เกิน 1 วัน ให้ใช้ข้อมูลจากแคช
        if (difference.inHours < 24) {
          final List<AppUpdate> updates = await getAppUpdates();
          
          if (updates.isNotEmpty) {
            // ดึงเวอร์ชันปัจจุบันของแอปพลิเคชัน
            final PackageInfo packageInfo = await PackageInfo.fromPlatform();
            final String currentVersion = packageInfo.version;
            
            // ตรวจสอบว่ามีเวอร์ชันใหม่กว่าหรือไม่
            final AppUpdate latestUpdate = updates.firstWhere(
              (update) => _isNewerVersion(update.version, currentVersion),
              orElse: () => null,
            );
            
            return latestUpdate;
          }
        }
      }
      
      // ดึงข้อมูลจาก API
      final response = await _apiClient.get('/app/check-update');
      
      // บันทึกเวลาตรวจสอบล่าสุด
      await _prefs.setString(_lastUpdateCheckKey, DateTime.now().toIso8601String());
      
      if (response == null || response['has_update'] == false) {
        return null;
      }
      
      return AppUpdate.fromJson(response['update']);
    } catch (e) {
      // ถ้ามีข้อผิดพลาด ให้คืนค่า null
      return null;
    }
  }
  
  // ตรวจสอบว่าเวอร์ชันใหม่กว่าหรือไม่
  bool _isNewerVersion(String newVersion, String currentVersion) {
    try {
      final List<int> newParts = newVersion.split('.').map(int.parse).toList();
      final List<int> currentParts = currentVersion.split('.').map(int.parse).toList();
      
      for (int i = 0; i < newParts.length; i++) {
        if (i >= currentParts.length) {
          return true;
        }
        
        if (newParts[i] > currentParts[i]) {
          return true;
        }
        
        if (newParts[i] < currentParts[i]) {
          return false;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // ส่งข้อเสนอแนะ
  Future<void> sendFeedback(String feedback, double rating) async {
    try {
      final data = {
        'feedback': feedback,
        'rating': rating,
      };
      
      await _apiClient.post('/app/feedback', data: data);
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to send feedback: ${e.toString()}');
    }
  }
  
  // รายงานปัญหา
  Future<void> reportIssue(String issue, String description, String? screenshotPath) async {
    try {
      final data = {
        'issue': issue,
        'description': description,
      };
      
      if (screenshotPath != null) {
        final formData = {
          ...data,
          'screenshot': await _apiClient.createMultipartFile(screenshotPath),
        };
        
        await _apiClient.postMultipart('/app/report-issue', formData: formData);
      } else {
        await _apiClient.post('/app/report-issue', data: data);
      }
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to report issue: ${e.toString()}');
    }
  }
  
  // ล้างแคชทั้งหมดของ AppRepository
  Future<void> clearAllCache() async {
    try {
      await _prefs.remove(_appDataKey);
      await _prefs.remove(_appSettingsKey);
      await _prefs.remove(_lastUpdateCheckKey);
    } catch (e) {
      throw CacheException('Failed to clear app cache: ${e.toString()}');
    }
  }
} 