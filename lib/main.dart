import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'data/datasources/local/recipe_local_datasource.dart';
import 'data/repositories/recipe_repository.dart';
import 'presentation/providers/recipe_provider.dart';
import 'presentation/providers/navigation_provider.dart';
import 'presentation/providers/game_provider.dart';
import 'presentation/providers/statistics_provider.dart';
import 'presentation/services/app_open_ad_manager.dart';
import 'presentation/services/interstitial_ad_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Google Mobile Ads SDK
  await MobileAds.instance.initialize();
  
  // Initialize Ad Managers
  InterstitialAdManager.instance.initialize();
  
  // Initialize dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  final localDataSource = RecipeLocalDataSource(sharedPreferences);
  final repository = RecipeRepository(localDataSource);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NavigationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(repository),
        ),
        ChangeNotifierProxyProvider<RecipeProvider, StatisticsProvider>(
          create: (context) => StatisticsProvider(
            sharedPreferences: sharedPreferences,
            recipeProvider: Provider.of<RecipeProvider>(context, listen: false),
          ),
          update: (context, recipeProvider, previous) => previous ?? StatisticsProvider(
            sharedPreferences: sharedPreferences,
            recipeProvider: recipeProvider,
          ),
        ),
        ChangeNotifierProxyProvider2<RecipeProvider, StatisticsProvider, GameProvider>(
          create: (context) => GameProvider(
            recipeProvider: Provider.of<RecipeProvider>(context, listen: false),
            statisticsProvider: Provider.of<StatisticsProvider>(context, listen: false),
          ),
          update: (context, recipeProvider, statisticsProvider, previous) => previous ?? GameProvider(
            recipeProvider: recipeProvider,
            statisticsProvider: statisticsProvider,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}