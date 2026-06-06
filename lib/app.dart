import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_providers.dart';
import 'core/services/deep_link_service.dart';
import 'features/home/home_screen.dart' show routeObserver;

class AstrologyApp extends StatefulWidget {
  const AstrologyApp({super.key});

  @override
  State<AstrologyApp> createState() => _AstrologyAppState();
}

class _AstrologyAppState extends State<AstrologyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // Initialize deep link service after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentContext != null) {
        DeepLinkService.instance.initialize(navigatorKey.currentContext!);
      }
    });
  }

  @override
  void dispose() {
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
        // Soft Celestial — a light, pastel Thai-astrology theme.
        theme: AppTheme.lightTheme(),
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
        initialRoute: AppRoutes.authWrapper,
        onGenerateRoute: AppRouter.generateRoute,
        onGenerateInitialRoutes: (initialRouteName) {
          final routeName = initialRouteName == '/'
              ? AppRoutes.authWrapper
              : initialRouteName;
          return [
            AppRouter.generateRoute(RouteSettings(name: routeName)),
          ];
        },
      ),
    );
  }
} 