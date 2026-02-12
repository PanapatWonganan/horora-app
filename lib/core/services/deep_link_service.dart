import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../routes/routes.dart';
import 'laravel_auth_service.dart';
import '../../features/affiliate/services/affiliate_service.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  static DeepLinkService get instance => _instance;

  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;

  void initialize(BuildContext context) {
    _handleInitialLink(context);
    _handleIncomingLinks(context);
  }

  Future<void> _handleInitialLink(BuildContext context) async {
    try {
      final initialLink = await _appLinks.getInitialAppLink();
      if (initialLink != null && context.mounted) {
        _handleDeepLink(context, initialLink);
      }
    } catch (e) {
      debugPrint('Error handling initial link: $e');
    }
  }

  void _handleIncomingLinks(BuildContext context) {
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? link) {
      if (link != null && context.mounted) {
        _handleDeepLink(context, link);
      }
    }, onError: (err) {
      debugPrint('Error handling incoming link: $err');
    });
  }

  void _handleDeepLink(BuildContext context, Uri link) {
    debugPrint('Handling deep link: $link');

    // Check for referral code in query parameters (works with any scheme)
    final refCode = link.queryParameters['ref'];
    if (refCode != null && refCode.isNotEmpty) {
      _handleReferralCode(refCode);
    }

    // Handle app-specific deep links
    if (link.scheme == 'horora') {
      _handleAppDeepLink(context, link);
    }
  }

  /// Save referral code and track it on the server
  Future<void> _handleReferralCode(String code) async {
    debugPrint('Handling referral code: $code');
    try {
      final affiliateService = AffiliateService();
      // Save locally with 30-day attribution window
      await affiliateService.saveReferralCode(code);
      // Track on server
      await affiliateService.trackReferral(code, source: 'deep_link');
    } catch (e) {
      debugPrint('Error handling referral code: $e');
    }
  }

  Future<void> _handleAppDeepLink(BuildContext context, Uri link) async {
    try {
      final isLoggedIn = await LaravelAuthService.instance.isLoggedIn();

      switch (link.host) {
        case 'home':
          if (isLoggedIn && context.mounted) {
            AppRouter.navigateAndClearStack(context, AppRoutes.home);
          }
          break;
        case 'login':
          if (!isLoggedIn && context.mounted) {
            AppRouter.navigateAndClearStack(context, AppRoutes.login);
          }
          break;
        case 'profile':
          if (isLoggedIn && context.mounted) {
            AppRouter.navigateTo(context, AppRoutes.profile);
          }
          break;
        case 'merit':
          if (context.mounted) {
            AppRouter.navigateTo(context, AppRoutes.merit);
          }
          break;
        case 'affiliate':
          if (isLoggedIn && context.mounted) {
            AppRouter.navigateTo(context, AppRoutes.affiliateDashboard);
          }
          break;
        case 'referral':
          // horora://referral?ref=CODE - handled above in _handleDeepLink
          if (context.mounted) {
            AppRouter.navigateTo(context, AppRoutes.merit);
          }
          break;
        default:
          debugPrint('Unknown deep link host: ${link.host}');
      }
    } catch (e) {
      debugPrint('Error handling app deep link: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
