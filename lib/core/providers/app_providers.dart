import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../../config/constants.dart';
import '../repositories/tarot_repository.dart';
import '../repositories/horoscope_repository.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({
    Key? key,
    required this.child,
  }) : super(key: key);

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
                  child: Text(
                      'เกิดข้อผิดพลาดในการโหลดแอปพลิเคชัน: ${snapshot.error}'),
                ),
              ),
            );
          }

          final sharedPreferences = snapshot.data!;

          return MultiProvider(
            providers: [
              // API Client
              Provider<ApiClient>(
                create: (_) =>
                    ApiClient(baseUrl: ApiConstants.baseUrl),
              ),

              // Tarot Repository
              Provider<TarotRepository>(
                create: (context) => TarotRepository(
                  apiClient: context.read<ApiClient>(),
                  prefs: sharedPreferences,
                ),
              ),

              // Horoscope Repository
              Provider<HoroscopeRepository>(
                create: (context) => HoroscopeRepository(
                  apiClient: context.read<ApiClient>(),
                  prefs: sharedPreferences,
                ),
              ),

              // Add other providers here as needed
            ],
            child: child,
          );
        }

        // แสดง loading screen ระหว่างรอ SharedPreferences
        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
