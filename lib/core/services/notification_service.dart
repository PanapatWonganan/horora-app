import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Service for managing OneSignal push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  /// OneSignal App ID - loaded from .env
  static String get oneSignalAppId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';

  /// Initialize OneSignal
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (oneSignalAppId.isEmpty) {
      debugPrint('OneSignal App ID not configured, skipping initialization');
      return;
    }

    // Enable verbose logging for debugging (disable in production)
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Initialize OneSignal with your App ID
    OneSignal.initialize(oneSignalAppId);

    // Request permission to send push notifications
    await OneSignal.Notifications.requestPermission(true);

    // Set up notification handlers
    _setupNotificationHandlers();

    _isInitialized = true;
    debugPrint('OneSignal initialized successfully');
  }

  /// Setup notification event handlers
  void _setupNotificationHandlers() {
    // Handle notification received while app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('Notification received in foreground: ${event.notification.title}');

      // Display the notification (you can also prevent it)
      event.notification.display();
    });

    // Handle notification clicked/opened
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('Notification clicked: ${event.notification.title}');

      // Get additional data from notification
      final additionalData = event.notification.additionalData;
      if (additionalData != null) {
        _handleNotificationAction(additionalData);
      }
    });

    // Handle permission changes
    OneSignal.Notifications.addPermissionObserver((state) {
      debugPrint('Notification permission changed: $state');
    });
  }

  /// Handle notification action based on data
  void _handleNotificationAction(Map<String, dynamic> data) {
    // Example: Navigate to specific screen based on notification data
    final String? screen = data['screen'] as String?;
    final String? id = data['id'] as String?;

    debugPrint('Handling notification action - screen: $screen, id: $id');

    // You can use a GlobalKey<NavigatorState> or other navigation method here
    // Example:
    // if (screen == 'horoscope') {
    //   navigatorKey.currentState?.pushNamed('/horoscope', arguments: {'id': id});
    // }
  }

  /// Set user tags for targeting notifications
  Future<void> setUserTags(Map<String, String> tags) async {
    await OneSignal.User.addTags(tags);
    debugPrint('User tags set: $tags');
  }

  /// Set user's zodiac sign for targeted notifications
  Future<void> setZodiacSign(String zodiacSign) async {
    await setUserTags({'zodiac_sign': zodiacSign});
  }

  /// Set user's language preference
  Future<void> setLanguage(String language) async {
    await OneSignal.User.setLanguage(language);
  }

  /// Set external user ID (e.g., Laravel user ID)
  Future<void> setExternalUserId(String userId) async {
    await OneSignal.login(userId);
    debugPrint('External user ID set: $userId');
  }

  /// Remove external user ID (on logout)
  Future<void> removeExternalUserId() async {
    await OneSignal.logout();
    debugPrint('External user ID removed');
  }

  /// Get OneSignal player/subscription ID
  Future<String?> getPlayerId() async {
    final id = OneSignal.User.pushSubscription.id;
    debugPrint('OneSignal Player ID: $id');
    return id;
  }

  /// Check if notifications are enabled
  bool get areNotificationsEnabled {
    return OneSignal.Notifications.permission;
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final result = await OneSignal.Notifications.requestPermission(true);
    return result;
  }

  /// Opt user in to notifications
  Future<void> optIn() async {
    OneSignal.User.pushSubscription.optIn();
  }

  /// Opt user out of notifications
  Future<void> optOut() async {
    OneSignal.User.pushSubscription.optOut();
  }

  /// Send a test notification (for debugging - requires REST API)
  /// In production, send notifications from your backend or OneSignal Dashboard
  void sendTestNotification() {
    debugPrint('To send test notifications, use OneSignal Dashboard or REST API');
    debugPrint('Dashboard: https://app.onesignal.com/');
  }
}

/// Extension to easily access notification service
extension NotificationServiceExtension on BuildContext {
  NotificationService get notificationService => NotificationService();
}
