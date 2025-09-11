class AppConstants {
  static const String appName = '한식조리기능사 레시피';
  static const int totalRecipes = 33;
  static const String jsonPath = 'assets/data/recipes.json';
  
  static const Map<String, String> categoryIcons = {
    '밥류': '🍚',
    '죽류': '🥣',
    '탕류': '🍲',
    '찌개류': '🥘',
    '구이류': '🔥',
    '전류': '🥞',
    '조림류': '🍖',
    '생채류': '🥗',
    '무침류': '🥬',
    '회류': '🍣',
    '적류': '🍢',
    '숙채류': '🥦',
    '김치류': '🌶️',
  };
  
  // Helper method to get category icon with fallback
  static String getCategoryIcon(String category) {
    return categoryIcons[category] ?? '🍽️';
  }
}