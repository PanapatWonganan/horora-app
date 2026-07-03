import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/auth_service.dart';
import '../config/constants.dart';
import '../core/api/api_client.dart';
import '../core/repositories/horoscope_repository.dart';
import '../core/theme/sacred_ui.dart';
import '../features/chat/repositories/chat_repository.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('เกิดข้อผิดพลาดในการโหลดแอป: ${snapshot.error}'),
                ),
              ),
            );
          }

          final sharedPreferences = snapshot.data!;

          return MultiProvider(
            providers: [
              Provider<ApiClient>(
                create: (_) =>
                    ApiClient(baseUrl: ApiConstants.baseUrl),
              ),
              Provider<AuthService>(
                create: (_) => AuthService.instance,
              ),
              Provider<ChatRepository>(
                create: (_) => ChatRepository(),
              ),
              Provider<HoroscopeRepository>(
                create: (_) => HoroscopeRepository(
                  apiClient: Provider.of<ApiClient>(_, listen: false),
                  prefs: sharedPreferences,
                ),
              ),
            ],
            child: child,
          );
        }

        // แสดง loading screen ระหว่างรอ SharedPreferences
        return const MaterialApp(
          home: Scaffold(
            body: SacredLoader.large(),
          ),
        );
      },
    );
  }
}
