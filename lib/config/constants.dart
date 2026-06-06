// API Endpoints
class ApiConstants {
  // สำหรับ Android Emulator ใช้ 10.0.2.2 แทน localhost
  // สำหรับ iOS Simulator ใช้ localhost หรือ 127.0.0.1
  // สำหรับ Production ใช้ domain จริง
  // Development: 'http://10.0.2.2:8000/api' (Android Emulator)
  // Development: 'http://127.0.0.1:8000/api' (iOS Simulator)
  // Production:  'https://horora-admin-production.up.railway.app/api'
  static const String baseUrl = 'https://horora-admin-production.up.railway.app/api';

  // Auth endpoints
  static const String authEndpoint = '$baseUrl/auth';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = '$authEndpoint/register';
  static const String logoutEndpoint = '$authEndpoint/logout';
  static const String userEndpoint = '$authEndpoint/user';
  static const String profileEndpoint = '$authEndpoint/profile';

  // Feature endpoints
  static const String horoscopesEndpoint = '$baseUrl/horoscope';
  static const String tarotEndpoint = '$baseUrl/tarot';
  static const String chatEndpoint = '$baseUrl/chat';
  static const String meritEndpoint = '$baseUrl/merit';

  // AI proxied through the backend (OpenAI key stays server-side, never in client).
  // Paths are relative to baseUrl, used via ApiClient.
  static const String horoscopeGuestPath = '/horoscope/guest';   // public (guest)
  static const String horoscopeDailyPath = '/horoscope/daily';   // auth
  static const String chatSessionsPath = '/chat/sessions';       // auth
  static const String tarotReadingsPath = '/tarot/readings';     // auth
}

// ค่าคงที่สำหรับการจัดเก็บข้อมูลในเครื่อง
class StorageConstants {
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String userProfile = 'user_profile';
  static const String userPreferences = 'user_preferences';
  static const String chatHistory = 'chat_history';
  static const String tarotReadings = 'tarot_readings';
  static const String focusSessions = 'focus_sessions';
  // Guest-first onboarding (เก็บข้อมูล onboarding ของ guest แบบ local)
  static const String guestOnboarding = 'guest_onboarding';
  static const String onboardingCompleted = 'onboarding_completed';
}

// ค่าคงที่สำหรับราศี
class ZodiacConstants {
  static const List<Map<String, dynamic>> signs = [
    {
      'name': 'ราศีเมษ',
      'name_en': 'Aries',
      'date_range': '21 มีนาคม - 19 เมษายน',
      'element': 'ไฟ',
      'symbol': '♈',
      'image': 'assets/images/zodiac/aries.png',
    },
    {
      'name': 'ราศีพฤษภ',
      'name_en': 'Taurus',
      'date_range': '20 เมษายน - 20 พฤษภาคม',
      'element': 'ดิน',
      'symbol': '♉',
      'image': 'assets/images/zodiac/taurus.png',
    },
    {
      'name': 'ราศีเมถุน',
      'name_en': 'Gemini',
      'date_range': '21 พฤษภาคม - 20 มิถุนายน',
      'element': 'ลม',
      'symbol': '♊',
      'image': 'assets/images/zodiac/gemini.png',
    },
    {
      'name': 'ราศีกรกฎ',
      'name_en': 'Cancer',
      'date_range': '21 มิถุนายน - 22 กรกฎาคม',
      'element': 'น้ำ',
      'symbol': '♋',
      'image': 'assets/images/zodiac/cancer.png',
    },
    {
      'name': 'ราศีสิงห์',
      'name_en': 'Leo',
      'date_range': '23 กรกฎาคม - 22 สิงหาคม',
      'element': 'ไฟ',
      'symbol': '♌',
      'image': 'assets/images/zodiac/leo.png',
    },
    {
      'name': 'ราศีกันย์',
      'name_en': 'Virgo',
      'date_range': '23 สิงหาคม - 22 กันยายน',
      'element': 'ดิน',
      'symbol': '♍',
      'image': 'assets/images/zodiac/virgo.png',
    },
    {
      'name': 'ราศีตุลย์',
      'name_en': 'Libra',
      'date_range': '23 กันยายน - 22 ตุลาคม',
      'element': 'ลม',
      'symbol': '♎',
      'image': 'assets/images/zodiac/libra.png',
    },
    {
      'name': 'ราศีพิจิก',
      'name_en': 'Scorpio',
      'date_range': '23 ตุลาคม - 21 พฤศจิกายน',
      'element': 'น้ำ',
      'symbol': '♏',
      'image': 'assets/images/zodiac/scorpio.png',
    },
    {
      'name': 'ราศีธนู',
      'name_en': 'Sagittarius',
      'date_range': '22 พฤศจิกายน - 21 ธันวาคม',
      'element': 'ไฟ',
      'symbol': '♐',
      'image': 'assets/images/zodiac/sagittarius.png',
    },
    {
      'name': 'ราศีมังกร',
      'name_en': 'Capricorn',
      'date_range': '22 ธันวาคม - 19 มกราคม',
      'element': 'ดิน',
      'symbol': '♑',
      'image': 'assets/images/zodiac/capricorn.png',
    },
    {
      'name': 'ราศีกุมภ์',
      'name_en': 'Aquarius',
      'date_range': '20 มกราคม - 18 กุมภาพันธ์',
      'element': 'ลม',
      'symbol': '♒',
      'image': 'assets/images/zodiac/aquarius.png',
    },
    {
      'name': 'ราศีมีน',
      'name_en': 'Pisces',
      'date_range': '19 กุมภาพันธ์ - 20 มีนาคม',
      'element': 'น้ำ',
      'symbol': '♓',
      'image': 'assets/images/zodiac/pisces.png',
    },
  ];
}

// ค่าคงที่สำหรับไพ่ทาโร่
class TarotConstants {
  static const List<String> spreadTypes = [
    'Single Card',
    'Three-Card',
    'Celtic Cross',
  ];
  
  static const Map<String, String> spreadDescriptions = {
    'Single Card': 'การอ่านไพ่แบบใบเดียว เหมาะสำหรับคำถามง่ายๆ หรือการขอคำแนะนำรายวัน',
    'Three-Card': 'การอ่านไพ่แบบสามใบ แสดงถึงอดีต ปัจจุบัน และอนาคต',
    'Celtic Cross': 'การอ่านไพ่แบบเซลติกครอส เป็นการอ่านไพ่แบบละเอียดที่ใช้ไพ่ 10 ใบ',
  };
}

// ค่าคงที่สำหรับโหมดสมาธิ
class FocusConstants {
  static const List<int> focusDurations = [5, 10, 15, 20, 30, 45, 60];
  
  static const List<Map<String, dynamic>> focusThemes = [
    {
      'name': 'จักรวาล',
      'description': 'เสียงและภาพของจักรวาลอันกว้างใหญ่',
      'image': 'assets/images/backgrounds/universe.jpg',
      'sound': 'assets/audio/universe.mp3',
    },
    {
      'name': 'ดวงดาว',
      'description': 'เสียงและภาพของดวงดาวในยามค่ำคืน',
      'image': 'assets/images/backgrounds/stars.jpg',
      'sound': 'assets/audio/stars.mp3',
    },
    {
      'name': 'พระจันทร์',
      'description': 'เสียงและภาพของพระจันทร์อันสงบ',
      'image': 'assets/images/backgrounds/moon.jpg',
      'sound': 'assets/audio/moon.mp3',
    },
    {
      'name': 'พระอาทิตย์',
      'description': 'เสียงและภาพของพระอาทิตย์อันสว่างไสว',
      'image': 'assets/images/backgrounds/sun.jpg',
      'sound': 'assets/audio/sun.mp3',
    },
  ];
} 