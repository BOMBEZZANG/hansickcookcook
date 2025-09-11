import 'package:flutter/material.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/flashcard/flashcard_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/bookmarks/bookmarks_screen.dart';
import '../presentation/screens/game/step_order_game_screen.dart';
import '../presentation/screens/statistics/statistics_screen.dart';
import '../presentation/screens/recipe/full_recipe_view_screen.dart';
import '../presentation/screens/main_navigation_screen.dart';
import '../data/models/recipe.dart';
import 'app_routes.dart';

/// Centralized route management for the application
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
          settings: settings,
        );
        
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
        
      case AppRoutes.flashcard:
        final recipe = settings.arguments as Recipe?;
        if (recipe == null) {
          return _errorRoute('Recipe required for flashcard screen');
        }
        return MaterialPageRoute(
          builder: (_) => FlashcardScreen(recipe: recipe),
          settings: settings,
        );
        
      case AppRoutes.search:
        return MaterialPageRoute(
          builder: (_) => const SearchScreen(),
          settings: settings,
        );
        
      case AppRoutes.bookmarks:
        return MaterialPageRoute(
          builder: (_) => const BookmarksScreen(),
          settings: settings,
        );

      case '/game/step-order':
        final recipe = settings.arguments as Recipe?;
        if (recipe == null) {
          return _errorRoute('Recipe required for game screen');
        }
        return MaterialPageRoute(
          builder: (_) => StepOrderGameScreen(recipe: recipe),
          settings: settings,
        );

      case '/statistics':
        return MaterialPageRoute(
          builder: (_) => const StatisticsScreen(),
          settings: settings,
        );

      case AppRoutes.fullRecipeView:
        final recipe = settings.arguments as Recipe?;
        if (recipe == null) {
          return _errorRoute('Recipe required for full recipe view screen');
        }
        return MaterialPageRoute(
          builder: (_) => FullRecipeViewScreen(recipe: recipe),
          settings: settings,
        );
        
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }
  
  /// Create error route for unknown routes
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                ),
                child: const Text('홈으로 돌아가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}