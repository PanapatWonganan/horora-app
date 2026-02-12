import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service for managing AdMob ads
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _isInitialized = true;
    debugPrint('AdMob initialized successfully');

    // Preload interstitial ad
    InterstitialAdManager().loadAd();
  }

  /// Test Ad Unit IDs (replace with real IDs in production)
  static const String testNativeAdUnitId = 'ca-app-pub-5439708053812589/7260217927';
  static const String testBannerAdUnitId = 'ca-app-pub-5439708053812589/2662319754';
  static const String testInterstitialAdUnitId = 'ca-app-pub-5439708053812589/9445837065';
  static const String testAppOpenAdUnitId = 'ca-app-pub-5439708053812589/3975401427';

  /// Get Native Ad Unit ID
  String get nativeAdUnitId => testNativeAdUnitId;

  /// Get Banner Ad Unit ID
  String get bannerAdUnitId => testBannerAdUnitId;

  /// Get Interstitial Ad Unit ID
  String get interstitialAdUnitId => testInterstitialAdUnitId;

  /// Get App Open Ad Unit ID
  String get appOpenAdUnitId => testAppOpenAdUnitId;
}

/// Manager for Interstitial Ads with probability-based showing
class InterstitialAdManager {
  static final InterstitialAdManager _instance = InterstitialAdManager._internal();
  factory InterstitialAdManager() => _instance;
  InterstitialAdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  final Random _random = Random();

  /// Probability of showing ad (0.0 - 1.0), default 70%
  double adShowProbability = 0.7;

  /// Minimum time between ads in seconds
  int minSecondsBetweenAds = 30;
  DateTime? _lastAdShownTime;

  /// Load an interstitial ad
  void loadAd() {
    if (AppOpenAdManager.adsDisabled) return;
    if (_isLoading || _interstitialAd != null) return;

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: AdService.testInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial Ad loaded successfully');
          _interstitialAd = ad;
          _isLoading = false;

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Interstitial Ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              // Preload next ad
              loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial Ad failed to show: ${error.message}');
              ad.dispose();
              _interstitialAd = null;
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial Ad failed to load: ${error.message}');
          _isLoading = false;
          // Retry loading after delay
          Future.delayed(const Duration(seconds: 30), loadAd);
        },
      ),
    );
  }

  /// Check if enough time has passed since last ad
  bool _canShowAd() {
    if (_lastAdShownTime == null) return true;
    final elapsed = DateTime.now().difference(_lastAdShownTime!).inSeconds;
    return elapsed >= minSecondsBetweenAds;
  }

  /// Show interstitial ad with probability check
  /// Returns true if ad was shown, false otherwise
  /// [onComplete] is called after ad is dismissed or if ad was not shown
  Future<bool> showAdWithProbability({VoidCallback? onComplete}) async {
    // Skip if ads are disabled globally
    if (AppOpenAdManager.adsDisabled) {
      debugPrint('Interstitial Ad skipped (ads disabled for testing)');
      onComplete?.call();
      return false;
    }

    // Check probability
    if (_random.nextDouble() > adShowProbability) {
      debugPrint('Interstitial Ad skipped (probability check)');
      onComplete?.call();
      return false;
    }

    // Check time since last ad
    if (!_canShowAd()) {
      debugPrint('Interstitial Ad skipped (too soon since last ad)');
      onComplete?.call();
      return false;
    }

    // Show ad if available
    if (_interstitialAd != null) {
      _lastAdShownTime = DateTime.now();

      // Set callback for when ad is dismissed
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Interstitial Ad dismissed');
          ad.dispose();
          _interstitialAd = null;
          onComplete?.call();
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Interstitial Ad failed to show: ${error.message}');
          ad.dispose();
          _interstitialAd = null;
          onComplete?.call();
          loadAd();
        },
      );

      await _interstitialAd!.show();
      return true;
    } else {
      debugPrint('Interstitial Ad not ready');
      onComplete?.call();
      loadAd(); // Try to load for next time
      return false;
    }
  }

  /// Force show ad (ignores probability, respects time limit)
  Future<bool> forceShowAd({VoidCallback? onComplete}) async {
    if (!_canShowAd()) {
      onComplete?.call();
      return false;
    }

    if (_interstitialAd != null) {
      _lastAdShownTime = DateTime.now();

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          onComplete?.call();
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          onComplete?.call();
          loadAd();
        },
      );

      await _interstitialAd!.show();
      return true;
    } else {
      onComplete?.call();
      loadAd();
      return false;
    }
  }

  /// Dispose the ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

/// Extension to easily show interstitial ads before navigation
extension InterstitialAdNavigation on BuildContext {
  /// Navigate with interstitial ad (70% probability)
  void navigateWithAd(String routeName, {Object? arguments}) {
    InterstitialAdManager().showAdWithProbability(
      onComplete: () {
        Navigator.pushNamed(this, routeName, arguments: arguments);
      },
    );
  }

  /// Navigate replacement with interstitial ad (70% probability)
  void navigateReplacementWithAd(String routeName, {Object? arguments}) {
    InterstitialAdManager().showAdWithProbability(
      onComplete: () {
        Navigator.pushReplacementNamed(this, routeName, arguments: arguments);
      },
    );
  }

  /// Execute action with interstitial ad (70% probability)
  void executeWithAd(VoidCallback action) {
    InterstitialAdManager().showAdWithProbability(
      onComplete: action,
    );
  }
}

/// Widget to display Native Ads
class NativeAdWidget extends StatefulWidget {
  final String factoryId;
  final double height;

  const NativeAdWidget({
    Key? key,
    this.factoryId = 'listTile',
    this.height = 280,
  }) : super(key: key);

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    // Skip if ads are disabled
    if (AppOpenAdManager.adsDisabled) {
      setState(() {
        _isError = true;
      });
      return;
    }

    _nativeAd = NativeAd(
      adUnitId: AdService().nativeAdUnitId,
      factoryId: widget.factoryId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('Native Ad loaded successfully');
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _isError = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native Ad failed to load: ${error.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _isError = true;
            });
          }
        },
        onAdOpened: (ad) => debugPrint('Native Ad opened'),
        onAdClosed: (ad) => debugPrint('Native Ad closed'),
        onAdClicked: (ad) => debugPrint('Native Ad clicked'),
        onAdImpression: (ad) => debugPrint('Native Ad impression'),
      ),
      request: const AdRequest(),
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      // Return empty container if ad failed to load
      return const SizedBox.shrink();
    }

    if (!_isLoaded) {
      // Show loading placeholder
      return Container(
        height: widget.height,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF9D4EDD),
          ),
        ),
      );
    }

    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}

/// Manager for App Open Ads - shown when user opens or returns to app
class AppOpenAdManager {
  static final AppOpenAdManager _instance = AppOpenAdManager._internal();
  factory AppOpenAdManager() => _instance;
  AppOpenAdManager._internal();

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isLoading = false;

  /// Flag to temporarily disable ads (e.g., during payment flow or testing)
  static bool adsDisabled = true; // TODO: Set to false for production

  /// Maximum duration allowed between loading and showing the ad
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Minimum time between app open ads in seconds
  int minSecondsBetweenAds = 60;
  DateTime? _lastAdShownTime;
  DateTime? _appOpenLoadTime;

  /// Load an App Open Ad
  void loadAd() {
    if (adsDisabled) return;
    if (_isLoading || _appOpenAd != null) return;

    _isLoading = true;
    AppOpenAd.load(
      adUnitId: AdService.testAppOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('App Open Ad loaded successfully');
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('App Open Ad failed to load: ${error.message}');
          _isLoading = false;
          // Retry after delay
          Future.delayed(const Duration(seconds: 60), loadAd);
        },
      ),
    );
  }

  /// Check if ad is available and not expired
  bool get isAdAvailable {
    if (_appOpenAd == null || _appOpenLoadTime == null) return false;

    // Check if ad has expired
    final elapsed = DateTime.now().difference(_appOpenLoadTime!);
    if (elapsed > maxCacheDuration) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      loadAd();
      return false;
    }

    return true;
  }

  /// Check if enough time has passed since last app open ad
  bool _canShowAd() {
    if (_lastAdShownTime == null) return true;
    final elapsed = DateTime.now().difference(_lastAdShownTime!).inSeconds;
    return elapsed >= minSecondsBetweenAds;
  }

  /// Show App Open Ad when app comes to foreground
  void showAdIfAvailable() {
    // Skip if ads are disabled (e.g., during payment flow)
    if (adsDisabled) {
      debugPrint('App Open Ad skipped (ads disabled for current flow)');
      return;
    }

    if (!isAdAvailable) {
      debugPrint('App Open Ad not available, loading...');
      loadAd();
      return;
    }

    if (_isShowingAd) {
      debugPrint('App Open Ad already showing');
      return;
    }

    if (!_canShowAd()) {
      debugPrint('App Open Ad skipped (too soon since last ad)');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('App Open Ad showed');
        _isShowingAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('App Open Ad dismissed');
        _isShowingAd = false;
        _lastAdShownTime = DateTime.now();
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('App Open Ad failed to show: ${error.message}');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );

    _appOpenAd!.show();
  }

  /// Dispose the ad
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}

/// Lifecycle reactor to show App Open Ads when app resumes
class AppLifecycleReactor with WidgetsBindingObserver {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed - showing App Open Ad if available');
      appOpenAdManager.showAdIfAvailable();
    }
  }
}

/// Widget to display Banner Ads
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;

  const BannerAdWidget({
    Key? key,
    this.adSize = AdSize.banner,
  }) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // Skip if ads are disabled
    if (AppOpenAdManager.adsDisabled) return;

    _bannerAd = BannerAd(
      adUnitId: AdService().bannerAdUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner Ad loaded successfully');
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner Ad failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.adSize.width.toDouble(),
      height: widget.adSize.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
