import 'package:flutter/material.dart';

import 'app_routes.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/onboarding/screens/onboarding_router.dart';
import '../../features/onboarding/screens/variant_a/onboarding_quiz_screen.dart';
import '../../features/auth/login/login_screen.dart';
import '../../features/auth/register/register_screen.dart';
import '../../features/auth/forgot_password/forgot_password_screen.dart';
import '../../features/auth/email_confirmation_screen.dart';
import '../../features/auth/auth_wrapper.dart';
import '../../features/home/home_screen.dart';
import '../../features/horoscope/horoscope_screen.dart';
import '../../features/horoscope/horoscope_detail_screen.dart';
import '../../features/tarot/tarot_screen.dart';
import '../../features/tarot/tarot_reading_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
// Import history screens
import '../../features/history/horoscope_history_screen.dart';
import '../../features/history/tarot_history_screen.dart';
import '../../features/history/chat_history_screen.dart';
// Import dashboard screen
import '../../features/dashboard/dashboard_screen.dart';
// Import settings screens
import '../../features/settings/settings_screen.dart';
import '../../features/settings/notifications_screen.dart';
import '../../features/settings/language_screen.dart';
import '../../features/settings/help_support_screen.dart';
import '../../features/settings/about_app_screen.dart';
// Import merit screens
import '../../features/merit/screens/merit_screen.dart';
import '../../features/merit/screens/merit_history_screen.dart';
// Import affiliate screens
import '../../features/affiliate/screens/affiliate_dashboard_screen.dart';
import '../../features/affiliate/screens/affiliate_register_screen.dart';
import '../../features/affiliate/screens/affiliate_share_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Splash and Onboarding
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case AppRoutes.onboarding:
        // ใช้ OnboardingRouter สำหรับ A/B Testing
        return MaterialPageRoute(builder: (_) => const OnboardingRouter());
      case AppRoutes.onboardingQuiz:
        // Full Quiz Flow (6 หน้า)
        return MaterialPageRoute(builder: (_) => const OnboardingQuizScreen());
      case AppRoutes.authWrapper:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());

      // Authentication
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.emailConfirmation:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EmailConfirmationScreen(
            token: args?['token'],
            type: args?['type'],
          ),
        );

      // Main Navigation
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case AppRoutes.horoscope:
        return MaterialPageRoute(builder: (_) => const HoroscopeScreen());
      case AppRoutes.horoscopeDetail:
        final args = settings.arguments as Map<String, dynamic>?;

        // เพิ่มการตรวจสอบและแสดงข้อมูลเพิ่มเติม
        debugPrint('HoroscopeDetail Route - Arguments: $args');

        if (args == null) {
          debugPrint('ERROR: Arguments is null for HoroscopeDetailScreen');
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('ไม่พบข้อมูลดวงประจำวัน (Arguments is null)'),
              ),
            ),
          );
        }

        if (args['horoscope'] == null) {
          debugPrint('ERROR: horoscope is null in arguments');
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('ไม่พบข้อมูลดวงประจำวัน (horoscope is null)'),
              ),
            ),
          );
        }

        debugPrint('HoroscopeDetail Route - Horoscope: ${args['horoscope']}');
        debugPrint(
            'HoroscopeDetail Route - ZodiacSignThai: ${args['zodiacSignThai']}');
        debugPrint('HoroscopeDetail Route - ZodiacSignEn: ${args['zodiacSignEn']}');

        return MaterialPageRoute(
          builder: (_) => HoroscopeDetailScreen(
            horoscope: args['horoscope'],
            // zodiacSignThai/En are required non-nullable Strings. Guard
            // against missing keys to avoid a runtime TypeError (null -> String).
            zodiacSignThai: (args['zodiacSignThai'] as String?) ?? '',
            zodiacSignEn: (args['zodiacSignEn'] as String?) ?? '',
          ),
        );
      case AppRoutes.tarot:
        return MaterialPageRoute(builder: (_) => const TarotScreen());
      case AppRoutes.tarotReading:
        final args = settings.arguments as Map<String, dynamic>?;
        final spreadType = args?['spreadType'] as String?;
        return MaterialPageRoute(
            builder: (_) => TarotReadingScreen(spreadType: spreadType));
      case AppRoutes.chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      // History Screens
      case AppRoutes.historyHoroscope:
        return MaterialPageRoute(
            builder: (_) => const HoroscopeHistoryScreen());
      case AppRoutes.historyTarot:
        return MaterialPageRoute(builder: (_) => const TarotHistoryScreen());
      case AppRoutes.historyChat:
        return MaterialPageRoute(builder: (_) => const ChatHistoryScreen());

      // Settings Screens
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case AppRoutes.language:
        return MaterialPageRoute(builder: (_) => const LanguageScreen());
      case AppRoutes.help:
        return MaterialPageRoute(builder: (_) => const HelpSupportScreen());
      case AppRoutes.about:
        return MaterialPageRoute(builder: (_) => const AboutAppScreen());

      // Merit Screens (ทำบุญออนไลน์)
      case AppRoutes.merit:
        return MaterialPageRoute(builder: (_) => const MeritScreen());
      case AppRoutes.meritHistory:
        return MaterialPageRoute(builder: (_) => const MeritHistoryScreen());

      // Affiliate Screens (ระบบตัวแทน)
      case AppRoutes.affiliateDashboard:
        return MaterialPageRoute(builder: (_) => const AffiliateDashboardScreen());
      case AppRoutes.affiliateRegister:
        return MaterialPageRoute(builder: (_) => const AffiliateRegisterScreen());
      case AppRoutes.affiliateShare:
        return MaterialPageRoute(builder: (_) => const AffiliateShareScreen());

      // Default - If route not found
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

  // Method to handle navigation with transitions
  static Future<dynamic> navigateTo(BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Method to handle navigation with replacement
  static Future<dynamic> navigateToReplacement(
      BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushReplacementNamed(context, routeName,
        arguments: arguments);
  }

  // Method to handle navigation with clearing stack
  static Future<dynamic> navigateAndClearStack(
      BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  // Method to handle navigation with custom transitions
  static Future<dynamic> navigateWithFade(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var fadeAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
      ),
    );
  }

  // Method to handle navigation with slide transition
  static Future<dynamic> navigateWithSlide(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var slideAnimation = animation.drive(tween);

          return SlideTransition(
            position: slideAnimation,
            child: child,
          );
        },
      ),
    );
  }
}
