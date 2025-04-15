import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/horoscope/horoscope_screen.dart';
import '../features/tarot/tarot_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/tarot/tarot_reading_screen.dart';
import '../features/tarot/tarot_card_details_screen.dart';
import '../features/horoscope/compatibility_check_screen.dart';

// ชื่อเส้นทางของแอปพลิเคชัน
class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String tarot = '/tarot';
  static const String tarotReading = '/tarot/reading';
  static const String horoscope = '/horoscope';
  static const String dailyHoroscope = '/horoscope/daily';
  static const String compatibilityCheck = '/horoscope/compatibility';
  static const String focusSession = '/focus';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
  static const String editProfile = '/profile/edit';
  static const String historyHoroscope = '/history/horoscope';
  static const String historyTarot = '/history/tarot';
  static const String historyChat = '/history/chat';
  static const String notifications = '/notifications';
  static const String language = '/language';
  static const String help = '/help';
  static const String about = '/about';
  static const String tarotCardDetails = '/tarot/card-details';
}

// ตัวจัดการเส้นทางของแอปพลิเคชัน
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(), // เปลี่ยนเป็น HomeScreen แทน Welcome Screen
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Login Screen'),
            ),
          ),
        );
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Register Screen'),
            ),
          ),
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case AppRoutes.chat:
        return MaterialPageRoute(
          builder: (_) => const ChatScreen(),
        );
      case AppRoutes.tarot:
        return MaterialPageRoute(
          builder: (_) => const TarotScreen(),
        );
      case AppRoutes.tarotReading:
        return MaterialPageRoute(
          builder: (context) => TarotReadingScreen(
            spreadType: settings.arguments != null
                ? (settings.arguments as Map<String, dynamic>)['spreadType']
                    as String?
                : null,
          ),
        );
      case AppRoutes.horoscope:
        return MaterialPageRoute(
          builder: (_) => const HoroscopeScreen(),
        );
      case AppRoutes.dailyHoroscope:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Daily Horoscope Screen'),
            ),
          ),
        );
      case AppRoutes.compatibilityCheck:
        return MaterialPageRoute(
          builder: (_) => const CompatibilityCheckScreen(),
        );
      case AppRoutes.focusSession:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Focus Session Screen'),
            ),
          ),
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Settings Screen'),
            ),
          ),
        );
      case AppRoutes.subscription:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Subscription Screen'),
            ),
          ),
        );
      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Edit Profile Screen'),
            ),
          ),
        );
      case AppRoutes.historyHoroscope:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Horoscope History Screen'),
            ),
          ),
        );
      case AppRoutes.historyTarot:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Tarot History Screen'),
            ),
          ),
        );
      case AppRoutes.historyChat:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Chat History Screen'),
            ),
          ),
        );
      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Notifications Screen'),
            ),
          ),
        );
      case AppRoutes.language:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Language Screen'),
            ),
          ),
        );
      case AppRoutes.help:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Help Screen'),
            ),
          ),
        );
      case AppRoutes.about:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('About Screen'),
            ),
          ),
        );
      case AppRoutes.tarotCardDetails:
        return MaterialPageRoute(
          builder: (context) => TarotCardDetailsScreen(
            readingId: (settings.arguments as Map<String, dynamic>)['readingId']
                as int,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // เพิ่มเมธอดสำหรับการนำทางไปยังหน้าจอต่างๆ
  static void navigateTo(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateToReplacement(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndClearStack(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false,
        arguments: arguments);
  }
}
