import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/repositories/horoscope_repository.dart';
import 'core/api/api_client.dart';
import 'core/services/ad_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/laravel_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (optional - for OpenAI key etc.)
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e) {
    debugPrint('Warning: .env file not found, using defaults');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Warning: Firebase not initialized: $e');
  }

  // Initialize Laravel Auth Service
  await LaravelAuthService.instance.initialize();

  // Initialize AdMob - ปิดชั่วคราวสำหรับการทดสอบ
  // TODO: เปิดใช้งานเมื่อ production
  // await AdService().initialize();

  // Initialize OneSignal Push Notifications
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Warning: Notifications not initialized: $e');
  }

  runApp(const AstrologyApp());
}

// Setup the horoscope repository
Future<HoroscopeRepository> setupHoroscopeRepository() async {
  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient(baseUrl: ApiConstants.baseUrl);
  return HoroscopeRepository(apiClient: apiClient, prefs: prefs);
}
