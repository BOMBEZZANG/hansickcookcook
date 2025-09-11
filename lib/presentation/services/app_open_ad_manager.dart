import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  static final AppOpenAdManager instance = AppOpenAdManager._internal();
  factory AppOpenAdManager() => instance;
  AppOpenAdManager._internal();

  // Test Ad Unit ID for App Open ads
  static const String _adUnitId = 'ca-app-pub-3940256099942544/9257395921';
  
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _hasShownInitialAd = false;
  DateTime? _appOpenLoadTime;
  
  // Maximum duration to consider an ad fresh
  static const Duration _maxCacheDuration = Duration(hours: 4);
  
  /// Whether an ad is available to be shown.
  bool get isAdAvailable => _appOpenAd != null && !_isShowingAd;
  
  /// Load an App Open Ad.
  void loadAd() {
    // Don't load ad if initial ad has already been shown
    if (_hasShownInitialAd) {
      print('⏭️ Initial ad already shown, not loading new ad');
      return;
    }
    
    // Clean up any existing ad first
    if (_appOpenAd != null) {
      _appOpenAd!.dispose();
      _appOpenAd = null;
    }
    
    print('🚀 Starting to load App Open Ad with ID: $_adUnitId');
    
    try {
      AppOpenAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            print('✅ App Open Ad loaded successfully!');
            _appOpenLoadTime = DateTime.now();
            _appOpenAd = ad;
          },
          onAdFailedToLoad: (error) {
            print('❌ App Open Ad failed to load: ${error.toString()}');
            print('   Domain: ${error.domain}');
            print('   Code: ${error.code}');
            print('   Message: ${error.message}');
            _appOpenAd = null;
          },
        ),
      );
    } catch (e) {
      print('❌ Exception during App Open Ad load: $e');
      _appOpenAd = null;
    }
  }
  
  /// Shows the ad, if one exists and is not already being shown.
  void showAdIfAvailable({
    required VoidCallback onAdDismissed,
    required VoidCallback onAdFailedToShow,
  }) {
    print('🎯 Attempting to show App Open Ad...');
    print('   - _hasShownInitialAd: $_hasShownInitialAd');
    print('   - _appOpenAd: ${_appOpenAd != null ? "loaded" : "null"}');
    print('   - _isShowingAd: $_isShowingAd');
    
    // Only show initial ad once - STRICT CHECK
    if (_hasShownInitialAd) {
      print('⏭️ Initial App Open Ad already shown, skipping');
      onAdDismissed();
      return;
    }
    
    // Additional safety check - mark as shown immediately to prevent race conditions
    _hasShownInitialAd = true;
    
    if (!isAdAvailable) {
      print('❌ App Open Ad not available');
      onAdFailedToShow();
      return;
    }
    
    if (_wasLoadTimeTooLongAgo()) {
      print('⏰ App Open Ad is too old');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      onAdFailedToShow();
      return;
    }
    
    print('🚀 Showing App Open Ad now!');
    
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('App Open Ad showed fullscreen content');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('App Open Ad failed to show fullscreen content: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdFailedToShow();
      },
      onAdDismissedFullScreenContent: (ad) {
        print('App Open Ad dismissed fullscreen content');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdDismissed();
        
        // Don't load a new ad after initial ad
      },
    );
    
    _appOpenAd!.show();
  }
  
  /// Whether the ad was loaded too long ago.
  bool _wasLoadTimeTooLongAgo() {
    if (_appOpenLoadTime == null) return true;
    
    final timeSinceLoad = DateTime.now().difference(_appOpenLoadTime!);
    return timeSinceLoad > _maxCacheDuration;
  }
  
  /// Initialize the Ad Manager and load the first ad
  void initialize() {
    print('Initializing App Open Ad Manager');
    loadAd();
  }
  
  /// Dispose of any loaded ads
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}