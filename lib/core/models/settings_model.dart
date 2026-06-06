import '../../config/constants.dart';

class UserSettings {
  final int id;
  final int userId;
  final String language;
  final bool darkMode;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool dailyHoroscopeNotification;
  final String? dailyHoroscopeTime;
  final bool focusSessionReminders;
  final int? focusReminderFrequency; // จำนวนวันระหว่างการแจ้งเตือน
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettings({
    required this.id,
    required this.userId,
    required this.language,
    required this.darkMode,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.dailyHoroscopeNotification,
    this.dailyHoroscopeTime,
    required this.focusSessionReminders,
    this.focusReminderFrequency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'],
      userId: json['user_id'],
      language: json['language'],
      darkMode: json['dark_mode'],
      notificationsEnabled: json['notifications_enabled'],
      soundEnabled: json['sound_enabled'],
      vibrationEnabled: json['vibration_enabled'],
      dailyHoroscopeNotification: json['daily_horoscope_notification'],
      dailyHoroscopeTime: json['daily_horoscope_time'],
      focusSessionReminders: json['focus_session_reminders'],
      focusReminderFrequency: json['focus_reminder_frequency'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'language': language,
      'dark_mode': darkMode,
      'notifications_enabled': notificationsEnabled,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'daily_horoscope_notification': dailyHoroscopeNotification,
      'daily_horoscope_time': dailyHoroscopeTime,
      'focus_session_reminders': focusSessionReminders,
      'focus_reminder_frequency': focusReminderFrequency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // สร้างการตั้งค่าเริ่มต้นสำหรับผู้ใช้ใหม่
  factory UserSettings.defaultSettings(int userId) {
    final DateTime now = DateTime.now();
    return UserSettings(
      id: 0, // จะถูกกำหนดโดยเซิร์ฟเวอร์
      userId: userId,
      language: 'th', // ค่าเริ่มต้นเป็นภาษาไทย
      darkMode: true, // ค่าเริ่มต้นเป็นโหมดมืด
      notificationsEnabled: true,
      soundEnabled: true,
      vibrationEnabled: true,
      dailyHoroscopeNotification: true,
      dailyHoroscopeTime: '08:00', // เวลาเริ่มต้นสำหรับการแจ้งเตือนดวงประจำวัน
      focusSessionReminders: true,
      focusReminderFrequency: 3, // แจ้งเตือนทุก 3 วัน
      createdAt: now,
      updatedAt: now,
    );
  }

  // สร้างสำเนาของการตั้งค่าพร้อมการเปลี่ยนแปลงบางส่วน
  UserSettings copyWith({
    int? id,
    int? userId,
    String? language,
    bool? darkMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? dailyHoroscopeNotification,
    String? dailyHoroscopeTime,
    bool? focusSessionReminders,
    int? focusReminderFrequency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      dailyHoroscopeNotification: dailyHoroscopeNotification ?? this.dailyHoroscopeNotification,
      dailyHoroscopeTime: dailyHoroscopeTime ?? this.dailyHoroscopeTime,
      focusSessionReminders: focusSessionReminders ?? this.focusSessionReminders,
      focusReminderFrequency: focusReminderFrequency ?? this.focusReminderFrequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(), // อัปเดตเวลาเมื่อมีการเปลี่ยนแปลง
    );
  }
}

// คลาสสำหรับการตั้งค่าแอปพลิเคชัน (ไม่เกี่ยวข้องกับผู้ใช้เฉพาะราย)
class AppSettings {
  final String apiBaseUrl;
  final int connectionTimeout;
  final int maxRetryAttempts;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final String appVersion;
  final int requiredApiVersion;

  AppSettings({
    required this.apiBaseUrl,
    required this.connectionTimeout,
    required this.maxRetryAttempts,
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
    required this.appVersion,
    required this.requiredApiVersion,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      apiBaseUrl: json['api_base_url'],
      connectionTimeout: json['connection_timeout'],
      maxRetryAttempts: json['max_retry_attempts'],
      analyticsEnabled: json['analytics_enabled'],
      crashReportingEnabled: json['crash_reporting_enabled'],
      appVersion: json['app_version'],
      requiredApiVersion: json['required_api_version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api_base_url': apiBaseUrl,
      'connection_timeout': connectionTimeout,
      'max_retry_attempts': maxRetryAttempts,
      'analytics_enabled': analyticsEnabled,
      'crash_reporting_enabled': crashReportingEnabled,
      'app_version': appVersion,
      'required_api_version': requiredApiVersion,
    };
  }

  // ค่าเริ่มต้นสำหรับการตั้งค่าแอปพลิเคชัน
  factory AppSettings.defaultSettings() {
    return AppSettings(
      apiBaseUrl: ApiConstants.baseUrl,
      connectionTimeout: 30, // วินาที
      maxRetryAttempts: 3,
      analyticsEnabled: true,
      crashReportingEnabled: true,
      appVersion: '1.0.0',
      requiredApiVersion: 1,
    );
  }
} 