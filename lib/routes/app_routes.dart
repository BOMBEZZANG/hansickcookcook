/// Application route constants
class AppRoutes {
  // Root routes
  static const String home = '/';
  static const String flashcard = '/flashcard';
  static const String search = '/search';
  static const String bookmarks = '/bookmarks';
  
  // Nested routes
  static const String recipeDetail = '/recipe-detail';
  static const String fullRecipeView = '/full-recipe-view';
  
  // Helper methods
  static String flashcardWithId(int recipeId) => '$flashcard/$recipeId';
  static String recipeDetailWithId(int recipeId) => '$recipeDetail/$recipeId';
}