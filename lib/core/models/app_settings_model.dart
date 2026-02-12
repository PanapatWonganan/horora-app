class AppSettings {
  final String language;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String timeZone;

  const AppSettings({
    this.language = 'th',
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.timeZone = 'Asia/Bangkok',
  });

  AppSettings copyWith({
    String? language,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    String? timeZone,
  }) {
    return AppSettings(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      timeZone: timeZone ?? this.timeZone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'timeZone': timeZone,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'] ?? 'th',
      isDarkMode: json['isDarkMode'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      timeZone: json['timeZone'] ?? 'Asia/Bangkok',
    );
  }
}