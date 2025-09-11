import 'package:flutter/material.dart';

class AppColors {
  // Category Colors
  static const Map<String, Color> categoryColors = {
    // Individual categories
    '밥류': Color(0xFFFFA726),
    '죽류': Color(0xFFFFD54F),
    '탕류': Color(0xFFEF5350),
    '찌개류': Color(0xFFE53935),
    '구이류': Color(0xFF8D6E63),
    '전류': Color(0xFFFFB74D),
    '조림류': Color(0xFF795548),
    '생채류': Color(0xFF66BB6A),
    '무침류': Color(0xFF4CAF50),
    '회류': Color(0xFF42A5F5),
    '적류': Color(0xFFEF9A9A),
    '숙채류': Color(0xFF81C784),
    '김치류': Color(0xFFFF7043),
    
    // Combined categories with unique colors
    '국/탕/찌개류': Color(0xFFE53935),  // Red
    '전/적류': Color(0xFFFF9800),       // Orange
    '무침/생채류': Color(0xFF4CAF50),   // Green
    '기타': Color(0xFF9C27B0),          // Purple
  };
  
  // App Theme Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // Phase 2: Additional UI Colors
  static const Color cardShadow = Color(0x1A000000);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color selectedChip = Color(0xFF2196F3);
  static const Color progressBar = Color(0xFF4CAF50);
  static const Color bookmarkActive = Color(0xFFFFC107);
  static const Color bottomNavBackground = Colors.white;
  static const Color rippleEffect = Color(0x33000000);
  
  // Helper method to get category color with fallback
  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? Colors.grey;
  }
  
  // Helper method to get category color with opacity
  static Color getCategoryColorWithOpacity(String category, double opacity) {
    return getCategoryColor(category).withOpacity(opacity);
  }
}