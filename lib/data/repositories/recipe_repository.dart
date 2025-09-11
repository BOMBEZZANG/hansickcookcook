import '../datasources/local/recipe_local_datasource.dart';
import '../models/recipe.dart';

/// Repository for recipe data management
/// 
/// This class implements the repository pattern to provide a clean interface
/// for accessing recipe data. It abstracts the data source implementation
/// and provides business logic for recipe operations.
class RecipeRepository {
  final RecipeLocalDataSource localDataSource;
  
  RecipeRepository(this.localDataSource);
  
  /// Get all recipes
  Future<List<Recipe>> getAllRecipes() async {
    try {
      return await localDataSource.loadRecipes();
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }
  
  /// Get a specific recipe by ID
  Future<Recipe?> getRecipeById(int id) async {
    try {
      return await localDataSource.getRecipeById(id);
    } catch (e) {
      throw Exception('Failed to get recipe with ID $id: $e');
    }
  }
  
  /// Get all bookmarked recipes
  Future<List<Recipe>> getBookmarkedRecipes() async {
    try {
      return await localDataSource.getBookmarkedRecipes();
    } catch (e) {
      throw Exception('Failed to load bookmarked recipes: $e');
    }
  }
  
  /// Get recipes filtered by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      return await localDataSource.getRecipesByCategory(category);
    } catch (e) {
      throw Exception('Failed to load recipes for category $category: $e');
    }
  }
  
  /// Search recipes by query (name, ingredients, category)
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllRecipes();
      }
      return await localDataSource.searchRecipes(query);
    } catch (e) {
      throw Exception('Failed to search recipes: $e');
    }
  }
  
  /// Toggle bookmark status for a recipe
  Future<void> toggleBookmark(int recipeId) async {
    try {
      await localDataSource.toggleBookmark(recipeId);
    } catch (e) {
      throw Exception('Failed to toggle bookmark for recipe $recipeId: $e');
    }
  }
  
  /// Check if a recipe is bookmarked
  bool isBookmarked(int recipeId) {
    try {
      return localDataSource.isBookmarked(recipeId);
    } catch (e) {
      return false;
    }
  }
  
  /// Update mastery level for a recipe (0-5 scale)
  Future<void> updateMasteryLevel(int recipeId, int level) async {
    try {
      await localDataSource.updateMasteryLevel(recipeId, level);
    } catch (e) {
      throw Exception('Failed to update mastery level for recipe $recipeId: $e');
    }
  }
  
  /// Get mastery level for a recipe
  int getMasteryLevel(int recipeId) {
    try {
      return localDataSource.getMasteryLevel(recipeId);
    } catch (e) {
      return 0;
    }
  }
  
  /// Get all unique categories
  Future<List<String>> getCategories() async {
    try {
      return await localDataSource.getCategories();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
  
  /// Get recipes filtered by multiple categories
  Future<List<Recipe>> getRecipesByCategories(List<String> categories) async {
    try {
      final allRecipes = await getAllRecipes();
      return allRecipes.where((recipe) => 
          categories.contains(recipe.category)).toList();
    } catch (e) {
      throw Exception('Failed to load recipes for categories: $e');
    }
  }
  
  /// Get recipes with specific mastery level
  Future<List<Recipe>> getRecipesByMasteryLevel(int level) async {
    try {
      final allRecipes = await getAllRecipes();
      return allRecipes.where((recipe) => 
          recipe.masteryLevel == level).toList();
    } catch (e) {
      throw Exception('Failed to load recipes by mastery level: $e');
    }
  }
  
  /// Get recipes with mastery level below threshold (need practice)
  Future<List<Recipe>> getRecipesNeedingPractice({int threshold = 3}) async {
    try {
      final allRecipes = await getAllRecipes();
      return allRecipes.where((recipe) => 
          recipe.masteryLevel < threshold).toList();
    } catch (e) {
      throw Exception('Failed to load recipes needing practice: $e');
    }
  }
  
  /// Get recipe statistics
  Future<Map<String, dynamic>> getRecipeStats() async {
    try {
      final allRecipes = await getAllRecipes();
      final bookmarkedCount = allRecipes.where((r) => r.bookmarked).length;
      final categoryStats = <String, int>{};
      final masteryStats = <int, int>{};
      
      for (final recipe in allRecipes) {
        categoryStats[recipe.category] = (categoryStats[recipe.category] ?? 0) + 1;
        masteryStats[recipe.masteryLevel] = (masteryStats[recipe.masteryLevel] ?? 0) + 1;
      }
      
      return {
        'totalRecipes': allRecipes.length,
        'bookmarkedCount': bookmarkedCount,
        'categoryStats': categoryStats,
        'masteryStats': masteryStats,
      };
    } catch (e) {
      throw Exception('Failed to get recipe statistics: $e');
    }
  }
  
  /// Clear cache and reload data
  Future<void> refreshData() async {
    try {
      localDataSource.clearCache();
      await localDataSource.loadRecipes();
    } catch (e) {
      throw Exception('Failed to refresh data: $e');
    }
  }
}