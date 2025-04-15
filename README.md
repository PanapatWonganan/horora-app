# 🔮 AI Astrology App - Frontend

## 📱 ภาพรวม

ส่วน Frontend ของแอปพลิเคชัน AI Astrology Chatbot & Tarot Reading App พัฒนาด้วย Flutter เพื่อรองรับทั้งระบบ Android และ iOS โดยมีการออกแบบ UI ในธีมมืดพร้อมแอนิเมชันเกี่ยวกับดวงดาวเพื่อสร้างประสบการณ์ผู้ใช้ที่น่าประทับใจ

## 🛠️ การติดตั้งและการใช้งาน

### ข้อกำหนดเบื้องต้น

- Flutter SDK (3.29.0 หรือสูงกว่า)
- Dart SDK (3.7.0 หรือสูงกว่า)
- Android Studio หรือ VS Code พร้อม Flutter/Dart plugins
- Android SDK (สำหรับการพัฒนา Android)
- Xcode (สำหรับการพัฒนา iOS, เฉพาะ macOS)

### การติดตั้ง

```bash
# ติดตั้ง dependencies
flutter pub get

# รันแอปพลิเคชันบน emulator หรืออุปกรณ์ที่เชื่อมต่อ
flutter run

# สร้าง APK สำหรับ Android
flutter build apk

# สร้าง IPA สำหรับ iOS (เฉพาะ macOS)
flutter build ios
```

## 📂 โครงสร้างโปรเจค

```
lib/
├── main.dart                # จุดเริ่มต้นของแอปพลิเคชัน
├── app.dart                 # การกำหนดค่าแอปพลิเคชัน
├── config/                  # การกำหนดค่าแอปพลิเคชัน
│   ├── routes.dart          # การกำหนดเส้นทาง
│   ├── themes.dart          # การกำหนดธีม
│   └── constants.dart       # ค่าคงที่ของแอปพลิเคชัน
├── core/                    # ฟังก์ชันหลัก
│   ├── api/                 # API service clients
│   ├── models/              # Data models
│   ├── services/            # Business logic services
│   └── utils/               # Utility functions
├── features/                # โมดูลฟีเจอร์
│   ├── auth/                # การยืนยันตัวตน
│   │   ├── screens/         # หน้าจอ UI
│   │   ├── widgets/         # คอมโพเนนต์ UI
│   │   └── providers/       # การจัดการสถานะ
│   ├── dashboard/           # แดชบอร์ดหลัก
│   ├── chat/                # ฟังก์ชัน AI chat
│   ├── tarot/               # ฟีเจอร์ไพ่ทาโร่
│   ├── horoscope/           # ฟีเจอร์ดูดวง
│   ├── focus/               # ฟีเจอร์โหมดสมาธิ
│   └── profile/             # การจัดการโปรไฟล์ผู้ใช้
├── shared/                  # คอมโพเนนต์ที่ใช้ร่วมกัน
│   ├── widgets/             # วิดเจ็ตที่ใช้ซ้ำได้
│   ├── animations/          # การกำหนดแอนิเมชัน
│   └── styles/              # สไตล์ที่ใช้ร่วมกัน
└── l10n/                    # การแปลภาษา
    ├── th.dart              # การแปลภาษาไทย
    └── en.dart              # การแปลภาษาอังกฤษ
```

## 📚 แพ็คเกจที่ใช้

แพ็คเกจหลักที่ใช้ในโปรเจคนี้:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # State Management
  provider: ^6.1.2
  flutter_bloc: ^8.1.4
  
  # UI Components
  flutter_svg: ^2.0.10
  lottie: ^3.1.0
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  
  # Networking
  dio: ^5.4.1
  http: ^1.2.1
  
  # Firebase
  firebase_core: ^2.27.1
  firebase_auth: ^4.17.9
  cloud_firestore: ^4.15.9
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  
  # Utils
  intl: ^0.18.1
  logger: ^2.0.2+1
  url_launcher: ^6.2.5
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
```

## 🎨 ธีมและสไตล์

แอปพลิเคชันใช้ธีมมืดพร้อมสีม่วงและน้ำเงินเข้มกับสัญลักษณ์ดวงดาวสีทอง โดยมีการกำหนดค่าสีหลักดังนี้:

```dart
// themes.dart
const Color kPrimaryColor = Color(0xFF6A1B9A);
const Color kSecondaryColor = Color(0xFF283593);
const Color kAccentColor = Color(0xFFFFD700);
const Color kBackgroundColor = Color(0xFF151030);
const Color kSurfaceColor = Color(0xFF1E1E2C);
const Color kTextColor = Color(0xFFF5F5F5);
```

## 🔄 การจัดการสถานะ

โปรเจคนี้ใช้ Provider และ Flutter Bloc สำหรับการจัดการสถานะ:

- **Provider**: สำหรับการจัดการสถานะอย่างง่าย
- **Flutter Bloc**: สำหรับการจัดการสถานะที่ซับซ้อนและการจัดการเหตุการณ์

## 🌐 การเชื่อมต่อกับ Backend

การเชื่อมต่อกับ Backend API ใช้ Dio HTTP client โดยมีการกำหนดค่าดังนี้:

```dart
// api_client.dart
class ApiClient {
  final Dio _dio = Dio();
  final String baseUrl = 'https://api.astrology-app.com';
  
  ApiClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add interceptors for authentication, logging, etc.
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }
  
  // API methods will be implemented here
}
```

## 🔒 การยืนยันตัวตน

การยืนยันตัวตนใช้ Firebase Authentication โดยรองรับ:

- การลงทะเบียนด้วยอีเมลและรหัสผ่าน
- การเข้าสู่ระบบด้วยอีเมลและรหัสผ่าน
- โหมดผู้เยี่ยมชม (จำกัดฟังก์ชัน)
- (อนาคต) การเข้าสู่ระบบด้วย Google, Facebook, Apple

## 🧪 การทดสอบ

โปรเจคนี้ใช้ Flutter Test Framework สำหรับการทดสอบ:

- **Unit Tests**: ทดสอบฟังก์ชันและตรรกะแยกจากส่วนอื่น
- **Widget Tests**: ทดสอบ UI components
- **Integration Tests**: ทดสอบการทำงานร่วมกันของหลายส่วน

## 📱 การสร้างแอปพลิเคชัน

```bash
# สร้าง APK สำหรับ Android
flutter build apk --release

# สร้าง App Bundle สำหรับ Google Play
flutter build appbundle --release

# สร้าง IPA สำหรับ iOS (เฉพาะ macOS)
flutter build ios --release
```

## 🚀 การ Deploy

- **Android**: Google Play Store
- **iOS**: Apple App Store

## 👥 การพัฒนา

- ใช้ Git สำหรับการควบคุมเวอร์ชัน
- ปฏิบัติตาม Flutter style guide
- ใช้ feature branches สำหรับการพัฒนาฟีเจอร์ใหม่
- ทำการ code review ก่อนการ merge

## 📝 แนวทางการพัฒนาต่อ

- เพิ่มการสนับสนุนภาษาอังกฤษ
- เพิ่มการเข้าสู่ระบบด้วย Social Login
- ปรับปรุงประสิทธิภาพของแอนิเมชัน
- เพิ่มฟีเจอร์ชุมชนและการแชร์
