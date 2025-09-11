import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
      
      // Global error handling
      builder: (context, widget) {
        // Handle system UI overlay style
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0), // Prevent system text scaling
          ),
          child: widget ?? const SizedBox.shrink(),
        );
      },
    );
  }
}