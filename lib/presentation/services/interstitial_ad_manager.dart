import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  static final InterstitialAdManager instance = InterstitialAdManager._internal();
  factory InterstitialAdManager() => instance;
  InterstitialAdManager._internal();

  // Test Ad Unit ID for Interstitial ads
  static const String _adUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  bool _isShowing = false;
  DateTime? _lastAdLoadTime;
  
  // Minimum time between ads
  static const Duration _minTimeBetweenAds = Duration(minutes: 1);
  
  /// Whether an ad is available to be shown.
  bool get isAdAvailable => _interstitialAd != null && !_isShowing;
  
  /// Load an Interstitial Ad.
  void loadAd() {
    // Prevent loading multiple ads at once
    if (_isLoading || _interstitialAd != null) {
      print('⏭️ Interstitial ad already loading or loaded');
      return;
    }
    
    _isLoading = true;
    print('🚀 Starting to load Interstitial Ad with ID: $_adUnitId');
    
    try {
      InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            print('✅ Interstitial Ad loaded successfully!');
            _interstitialAd = ad;
            _isLoading = false;
          },
          onAdFailedToLoad: (error) {
            print('❌ Interstitial Ad failed to load: ${error.toString()}');
            print('   Domain: ${error.domain}');
            print('   Code: ${error.code}');
            print('   Message: ${error.message}');
            _interstitialAd = null;
            _isLoading = false;
          },
        ),
      );
    } catch (e) {
      print('❌ Exception during Interstitial Ad load: $e');
      _interstitialAd = null;
      _isLoading = false;
    }
  }
  
  /// Shows the ad if available and enough time has passed.
  void showAdIfAvailable({
    required VoidCallback onAdDismissed,
    required VoidCallback onAdFailedToShow,
  }) {
    print('🎯 Attempting to show Interstitial Ad...');
    print('   - _interstitialAd: ${_interstitialAd != null ? "loaded" : "null"}');
    print('   - _isShowing: $_isShowing');
    
    // Check if enough time has passed since last ad (temporarily disabled for testing)
    if (_lastAdLoadTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdLoadTime!);
      print('⏰ Time since last ad: ${timeSinceLastAd.inSeconds}s (min required: ${_minTimeBetweenAds.inSeconds}s)');
      // Temporarily disable time restriction for testing
      // if (timeSinceLastAd < _minTimeBetweenAds) {
      //   print('⏰ Not enough time passed since last ad');
      //   onAdDismissed(); // Continue without showing ad
      //   return;
      // }
    }
    
    if (!isAdAvailable) {
      print('❌ Interstitial Ad not available');
      onAdFailedToShow();
      return;
    }
    
    print('🚀 Showing Interstitial Ad now!');
    _isShowing = true;
    
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('Interstitial Ad showed fullscreen content');
        _lastAdLoadTime = DateTime.now(); // Set time when ad is actually shown
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Interstitial Ad failed to show fullscreen content: $error');
        _isShowing = false;
        ad.dispose();
        _interstitialAd = null;
        onAdFailedToShow();
        // Load next ad for future use
        loadAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        print('Interstitial Ad dismissed fullscreen content');
        _isShowing = false;
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed();
        // Load next ad for future use
        loadAd();
      },
    );
    
    _interstitialAd!.show();
  }
  
  /// Preload ad for better user experience
  void preloadAd() {
    print('🎯 preloadAd called - _interstitialAd: ${_interstitialAd != null ? "loaded" : "null"}, _isLoading: $_isLoading');
    if (_interstitialAd == null && !_isLoading) {
      loadAd();
    } else {
      print('🎯 Skipping preload - ad already loaded or loading in progress');
    }
  }
  
  /// Show ad with navigation callback
  void showAdAndNavigate({
    required VoidCallback onNavigate,
  }) {
    print('🎯 showAdAndNavigate called');
    showAdIfAvailable(
      onAdDismissed: () {
        print('🎯 Ad dismissed, executing onNavigate callback');
        onNavigate();
      },
      onAdFailedToShow: () {
        print('🎯 Ad failed to show, executing onNavigate callback');
        onNavigate();
      },
    );
  }
  
  /// Dispose of any loaded ads
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isShowing = false;
    _isLoading = false;
  }
  
  /// Initialize the manager and preload first ad
  void initialize() {
    print('🎯 Initializing Interstitial Ad Manager');
    preloadAd();
  }
}