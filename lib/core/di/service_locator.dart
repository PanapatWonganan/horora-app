import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../api/api_client.dart';
import '../repositories/repositories.dart';

final GetIt serviceLocator = GetIt.instance;

class ServiceLocator {
  // ตั้งค่า Service Locator
  static Future<void> setup() async {
    await _setupExternalDependencies();
    _setupApiClient();
    _setupRepositories();
  }

  // ตั้งค่า External Dependencies
  static Future<void> _setupExternalDependencies() async {
    // SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

    // PackageInfo
    final packageInfo = await PackageInfo.fromPlatform();
    serviceLocator.registerSingleton<PackageInfo>(packageInfo);
  }

  // ตั้งค่า API Client
  static void _setupApiClient() {
    serviceLocator.registerSingleton<ApiClient>(
      ApiClient(),
    );
  }

  // ตั้งค่า Repositories
  static void _setupRepositories() {
    // User Repository
    serviceLocator.registerSingleton<UserRepository>(
      UserRepository(
        apiClient: serviceLocator<ApiClient>(),
        prefs: serviceLocator<SharedPreferences>(),
      ),
    );

    // Horoscope Repository
    serviceLocator.registerSingleton<HoroscopeRepository>(
      HoroscopeRepository(
        apiClient: serviceLocator<ApiClient>(),
        prefs: serviceLocator<SharedPreferences>(),
      ),
    );

    // Tarot Repository
    serviceLocator.registerSingleton<TarotRepository>(
      TarotRepository(
        apiClient: serviceLocator<ApiClient>(),
        prefs: serviceLocator<SharedPreferences>(),
      ),
    );

    // Chat Repository
    serviceLocator.registerSingleton<ChatRepository>(
      ChatRepository(
        apiClient: serviceLocator<ApiClient>(),
        prefs: serviceLocator<SharedPreferences>(),
      ),
    );

    // Subscription Repository
    serviceLocator.registerSingleton<SubscriptionRepository>(
      SubscriptionRepository(
        apiClient: serviceLocator<ApiClient>(),
        prefs: serviceLocator<SharedPreferences>(),
      ),
    );

    // App Repository
    serviceLocator.registerSingleton<AppRepository>(
      AppRepository(
        apiClient: serviceLocator<ApiClient>(),
        prefs: serviceLocator<SharedPreferences>(),
      ),
    );
  }

  // ล้างข้อมูลทั้งหมดใน Service Locator
  static Future<void> reset() async {
    await serviceLocator.reset();
    await setup();
  }
} 