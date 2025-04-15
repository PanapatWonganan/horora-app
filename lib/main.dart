import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/repositories/horoscope_repository.dart';
import 'core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const AstrologyApp());
}

// Setup the horoscope repository
Future<HoroscopeRepository> setupHoroscopeRepository() async {
  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient(baseUrl: 'https://api.astrology-app.com/api');
  return HoroscopeRepository(apiClient: apiClient, prefs: prefs);
}

// Example of how to add the horoscope demo button to a screen
//
// ElevatedButton(
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const HoroscopeDemoScreen(),
//       ),
//     );
//   },
//   child: const Text('ทดสอบดูดวงประจำวัน'),
// )
