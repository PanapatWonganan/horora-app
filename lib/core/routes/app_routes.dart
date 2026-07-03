class AppRoutes {
  // Splash and Onboarding
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String authWrapper = '/auth-wrapper';

  // Authentication
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String emailConfirmation = '/email-confirmation';
  static const String resetPassword = '/reset-password';

  // Main Navigation
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String horoscope = '/horoscope';
  static const String tarot = '/tarot';
  static const String chat = '/chat';
  static const String profile = '/profile';

  // Horoscope Features
  static const String dailyHoroscope = '/horoscope/daily';
  static const String horoscopeDetail = '/horoscope/detail';
  static const String weeklyHoroscope = '/horoscope/weekly';
  static const String monthlyHoroscope = '/horoscope/monthly';
  static const String yearlyHoroscope = '/horoscope/yearly';
  static const String zodiacDetails = '/horoscope/zodiac-details';

  // Tarot Features
  static const String tarotReading = '/tarot/reading';
  static const String tarotSpread = '/tarot/spread';
  static const String tarotCardDetails = '/tarot/card-details';
  static const String savedReadings = '/tarot/saved-readings';

  // Chat Features
  static const String newChat = '/chat/new';
  static const String chatDetails = '/chat/details';

  // Profile and Settings
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String notifications = '/settings/notifications';
  static const String language = '/settings/language';
  static const String theme = '/settings/theme';
  static const String subscription = '/settings/subscription';
  static const String paymentMethods = '/settings/payment-methods';
  static const String help = '/settings/help';
  static const String about = '/settings/about';

  // History
  static const String historyHoroscope = '/history/horoscope';
  static const String historyTarot = '/history/tarot';
  static const String historyChat = '/history/chat';

  // Merit (ทำบุญออนไลน์)
  static const String merit = '/merit';
  static const String meritOrder = '/merit/order';
  static const String meritPayment = '/merit/payment';
  static const String meritHistory = '/merit/history';
  static const String meritOrderStatus = '/merit/status';

  // Affiliate (ระบบตัวแทน)
  static const String affiliateDashboard = '/affiliate';
  static const String affiliateRegister = '/affiliate/register';
  static const String affiliateShare = '/affiliate/share';
  static const String affiliateWithdraw = '/affiliate/withdraw';
}
