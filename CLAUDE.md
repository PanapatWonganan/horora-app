# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
flutter pub get                    # Install dependencies
flutter run                        # Run on connected device/emulator
flutter run -d emulator-5554       # Run on specific Android emulator
flutter build apk --release        # Build Android APK
flutter build appbundle --release  # Build Android App Bundle (Google Play)
flutter build ios --release        # Build iOS (macOS only)
flutter analyze                    # Static analysis
flutter test                       # Run all tests
flutter test test/widget_test.dart # Run single test file
./build.sh                         # Web build with env vars
```

Emulator management:
```bash
flutter emulators                          # List emulators
flutter emulators --launch Medium_Phone_API_35  # Launch Android emulator
```

## Android Build Configuration

- **Target SDK**: 35 (Android 15)
- **Min SDK**: 21
- **AGP**: 8.5.2 (required for 16 KB page size support)
- **Kotlin**: 1.9.22
- **Gradle**: 8.10.2
- **16 KB Page Size**: Enabled via `packaging.jniLibs.useLegacyPackaging = false` in `android/app/build.gradle` (required by Google Play for Android 15+)

## Architecture

### State Management
- **Provider** (primary) — simple state, dependency injection via `MultiProvider` in `app_providers.dart`
- **Flutter Bloc** — complex event-driven state (some features)
- **Riverpod** — installed but sparingly used

### API Layer
- **Backend**: Laravel on Railway (`https://horora-admin-production.up.railway.app/api`)
- **Admin Panel**: Filament v3 at `/admin` path
- **HTTP Client**: `http` package via `ApiClient` class (not Dio, despite it being in pubspec)
- **Auth**: Bearer token stored in SharedPreferences, managed by `LaravelAuthService` (singleton)
- **Constants**: All endpoints defined in `lib/config/constants.dart` (`ApiConstants.baseUrl`)

### Project Structure
```
lib/
├── main.dart                  # Entry point: Firebase, LaravelAuth, Notifications init
├── app.dart                   # MaterialApp config, theme, routing
├── config/constants.dart      # ApiConstants, StorageConstants, ZodiacConstants
├── core/
│   ├── api/                   # ApiClient (http), OpenAIClient
│   ├── services/              # Singleton services (auth, notifications, ads, AI)
│   ├── repositories/          # Data layer (horoscope, tarot, chat, merit)
│   ├── routes/                # Named routes (AppRoutes + AppRouter.generateRoute)
│   ├── providers/             # MultiProvider setup
│   ├── models/                # Data models
│   ├── theme/                 # AppTheme, AppColors, MeritColors
│   └── utils/                 # AppIcons (SVG), ZodiacUtils, exceptions
├── features/                  # Feature modules (see below)
└── l10n/                      # Localization (Thai + English)
```

### Feature Module Pattern
Each feature under `lib/features/` follows this structure:
```
features/<name>/
├── screens/       # UI screens (StatefulWidget)
├── widgets/       # Feature-specific widgets
├── services/      # Feature-specific services
├── models/        # Feature-specific models
└── repositories/  # Feature-specific data access
```

**13 feature modules**: auth, welcome, onboarding, home, dashboard, horoscope, tarot, chat, profile, history, settings, merit, affiliate

### Key Services (Singletons)
- `LaravelAuthService.instance` — auth, token management, user profile
- `MeritService.instance` — merit/donation orders, Telegram notifications
- `AffiliateService.instance` — referral system
- `NotificationService()` — OneSignal push notifications
- `AdService` — Google Mobile Ads (currently disabled: `adsDisabled = true`)

## Environment

Environment variables loaded from `assets/.env` via `flutter_dotenv`:
- `OPENAI_API_KEY` — OpenAI API for AI chat/horoscope generation
- `TELEGRAM_BOT_TOKEN` / `TELEGRAM_CHAT_ID` — Order notifications
- `ONESIGNAL_APP_ID` — Push notifications

Template at `assets/.env.example`.

## Routing

Named routes defined in `lib/core/routes/app_routes.dart`, handled by `AppRouter.generateRoute()` in `app_router.dart`. Navigation uses `Navigator.pushNamed()` with arguments passing.

## Theming

- Dark mode only (configured in `app.dart`)
- Font: Kanit (Thai-optimized)
- Primary: Purple (#9C27B0)
- Merit system uses its own color scheme: `lib/core/theme/merit_colors.dart` (Gold #FFD700 / Orange #FF8C00)
- SVG icons managed via `AppIcons` class in `lib/core/utils/app_icons.dart`

## Backend (Laravel)

Located at `../backend/horora-api/` (relative to this Flutter project):
- Laravel 12 + Filament v3 (admin panel)
- API auth via Sanctum (Bearer tokens)
- Admin login: `/admin` path, requires `is_admin = true` on user record

## Monetization UX rules

- **Value before ask** — free daily content (e.g. the daily horoscope reading) renders above any commerce ask on a screen.
- **One primary ask per screen** — Home's single ask is the merit hero; weekly merit planning lives in the merit tab, not duplicated on Home.
- **Dismissible offers stay dismissed** — once a user dismisses an offer card, it stays hidden for at least 14 days (persisted, not just session state).
