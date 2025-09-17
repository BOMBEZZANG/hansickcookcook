import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/config/screenshot_config.dart';

class AdaptiveBannerAd extends StatefulWidget {
  final bool isFloating;
  final EdgeInsets? margin;
  
  const AdaptiveBannerAd({
    Key? key,
    this.isFloating = false,
    this.margin,
  }) : super(key: key);

  @override
  State<AdaptiveBannerAd> createState() => _AdaptiveBannerAdState();
}

class _AdaptiveBannerAdState extends State<AdaptiveBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _adLoadInitiated = false;
  
  // Production Banner Ad Unit ID
  static const String _adUnitId = 'ca-app-pub-2598779635969436/1725687506';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_adLoadInitiated) {
      _adLoadInitiated = true;
      _loadAd();
    }
  }

  void _loadAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('❌ Unable to get adaptive banner ad size');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print('✅ Adaptive banner ad loaded successfully');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('❌ Adaptive banner ad failed to load: $err');
          ad.dispose();
        },
        onAdOpened: (_) => print('🔗 Adaptive banner ad opened'),
        onAdClosed: (_) => print('🔄 Adaptive banner ad closed'),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide ads in screenshot mode
    if (ScreenshotConfig.isScreenshotMode) {
      return const SizedBox.shrink();
    }
    
    final container = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.isFloating ? BorderRadius.circular(8) : null,
        border: Border.all(
          color: AppColors.divider.withOpacity(0.5),
          width: 0.5,
        ),
        boxShadow: widget.isFloating ? [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.15),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: widget.isFloating ? BorderRadius.circular(8) : BorderRadius.zero,
        child: SizedBox(
          width: double.infinity,
          height: _isLoaded ? _bannerAd!.size.height.toDouble() : 60,
          child: _isLoaded && _bannerAd != null
              ? AdWidget(ad: _bannerAd!)
              : _buildPlaceholder(),
        ),
      ),
    );

    if (widget.isFloating) {
      return container;
    }

    return SafeArea(
      top: false,
      child: container,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '스폰서 광고 로딩 중',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}