import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_animations.dart';
import '../providers/navigation_provider.dart';
import '../widgets/ads/banner_ad_widget.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'bookmarks/bookmarks_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late PageController _pageController;
  
  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    BookmarksScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final navigationProvider = context.read<NavigationProvider>();
    navigationProvider.setTabByIndex(index);
    
    // Restore scroll position for the new page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigationProvider.restoreScrollPosition(NavigationTab.values[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        // Listen for programmatic tab changes and jump to the correct page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            final currentPage = _pageController.page?.round() ?? 0;
            final targetPage = navigationProvider.currentIndex;
            
            if (currentPage != targetPage) {
              // Use jumpToPage instead of animateToPage to avoid flashing between pages
              _pageController.jumpToPage(targetPage);
            }
          }
        });
        
        return WillPopScope(
          onWillPop: () async {
            // If not on home tab, go back to home instead of exiting app
            if (navigationProvider.currentTab != NavigationTab.home) {
              navigationProvider.setTab(NavigationTab.home);
              return false; // Don't exit the app
            }
            return true; // Allow app to exit
          },
          child: Scaffold(
            body: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _screens,
            ),
            bottomNavigationBar: const BannerAdWidget(),
          ),
        );
      },
    );
  }

}