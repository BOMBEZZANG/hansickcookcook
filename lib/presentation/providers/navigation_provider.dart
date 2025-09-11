import 'package:flutter/material.dart';

enum NavigationTab {
  home,
  search,
  bookmarks,
}

class NavigationProvider extends ChangeNotifier {
  NavigationTab _currentTab = NavigationTab.home;
  final Map<NavigationTab, ScrollController> _scrollControllers = {
    NavigationTab.home: ScrollController(),
    NavigationTab.search: ScrollController(),
    NavigationTab.bookmarks: ScrollController(),
  };
  
  // Page state preservation
  final Map<NavigationTab, Map<String, dynamic>> _pageStates = {
    NavigationTab.home: {},
    NavigationTab.search: {},
    NavigationTab.bookmarks: {},
  };

  // Getters
  NavigationTab get currentTab => _currentTab;
  int get currentIndex => _currentTab.index;
  
  ScrollController getScrollController(NavigationTab tab) {
    return _scrollControllers[tab]!;
  }
  
  ScrollController get currentScrollController {
    return _scrollControllers[_currentTab]!;
  }

  // Navigation methods
  void setTab(NavigationTab tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      notifyListeners();
    }
  }
  
  void setTabByIndex(int index) {
    if (index >= 0 && index < NavigationTab.values.length) {
      setTab(NavigationTab.values[index]);
    }
  }

  // Page state management
  void savePageState(NavigationTab tab, String key, dynamic value) {
    _pageStates[tab]![key] = value;
  }
  
  T? getPageState<T>(NavigationTab tab, String key) {
    return _pageStates[tab]![key] as T?;
  }
  
  void clearPageState(NavigationTab tab) {
    _pageStates[tab]!.clear();
  }

  // Scroll position management
  void saveScrollPosition(NavigationTab tab) {
    final controller = _scrollControllers[tab]!;
    if (controller.hasClients) {
      savePageState(tab, 'scrollOffset', controller.offset);
    }
  }
  
  void restoreScrollPosition(NavigationTab tab) {
    final controller = _scrollControllers[tab]!;
    final savedOffset = getPageState<double>(tab, 'scrollOffset');
    
    if (savedOffset != null && controller.hasClients) {
      controller.animateTo(
        savedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Helper methods for specific tab states
  void saveHomeSearchQuery(String query) {
    savePageState(NavigationTab.home, 'searchQuery', query);
  }
  
  String getHomeSearchQuery() {
    return getPageState<String>(NavigationTab.home, 'searchQuery') ?? '';
  }
  
  void saveSelectedCategory(String category) {
    savePageState(NavigationTab.home, 'selectedCategory', category);
  }
  
  String getSelectedCategory() {
    return getPageState<String>(NavigationTab.home, 'selectedCategory') ?? '전체';
  }
  
  void saveSearchScreenQuery(String query) {
    savePageState(NavigationTab.search, 'searchQuery', query);
  }
  
  String getSearchScreenQuery() {
    return getPageState<String>(NavigationTab.search, 'searchQuery') ?? '';
  }

  @override
  void dispose() {
    // Dispose scroll controllers
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}