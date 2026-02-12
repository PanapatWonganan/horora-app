import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_wrapper.dart';
import 'core/providers/app_providers.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/ad_service.dart';
import 'features/home/home_screen.dart' show routeObserver;

class AstrologyApp extends StatefulWidget {
  const AstrologyApp({super.key});

  @override
  State<AstrologyApp> createState() => _AstrologyAppState();
}

class _AstrologyAppState extends State<AstrologyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();

    // Initialize App Open Ads
    final appOpenAdManager = AppOpenAdManager();
    appOpenAdManager.loadAd();
    _appLifecycleReactor = AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges();

    // Initialize deep link service after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentContext != null) {
        DeepLinkService.instance.initialize(navigatorKey.currentContext!);
      }
    });
  }

  @override
  void dispose() {
    _appLifecycleReactor.dispose();
    DeepLinkService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [routeObserver],
        title: 'AI Astrology',
        theme: AppTheme.darkTheme(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('th', 'TH'),
          Locale('en', 'US'),
        ],
        locale: const Locale('th', 'TH'),
        home: const AuthWrapper(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
} 