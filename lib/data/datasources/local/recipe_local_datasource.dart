import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/recipe.dart';
import '../../../core/constants/app_constants.dart';

class RecipeLocalDataSource {
  static const String RECIPES_ASSET_PATH = AppConstants.jsonPath;
  static const String BOOKMARKS_KEY = 'bookmarked_recipes';
  static const String MASTERY_KEY = 'mastery_levels';
  
  final SharedPreferences sharedPreferences;
  List<Recipe>? _cachedRecipes;
  
  RecipeLocalDataSource(this.sharedPreferences);
  
  /// Load recipes from assets with caching and user preferences
  Future<List<Recipe>> loadRecipes() async {
    if (_cachedRecipes != null) return _cachedRecipes!;
    
    try {
      final String jsonString = await rootBundle.loadString(RECIPES_ASSET_PATH);
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> recipesList = jsonMap['recipes'];
      
      // Load user preferences
      final Set<int> bookmarkedIds = getBookmarkedIds();
      final Map<int, int> masteryLevels = getMasteryLevels();
      
      _cachedRecipes = recipesList.map((json) {
        final recipe = Recipe.fromJson(json);
        
        // Apply user preferences
        if (bookmarkedIds.contains(recipe.id)) {
          recipe.bookmarked = true;
        }
        if (masteryLevels.containsKey(recipe.id)) {
          recipe.masteryLevel = masteryLevels[recipe.id]!;
        }
        
        return recipe;
      }).toList();
      
      return _cachedRecipes!;
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }
  
  /// Get a recipe by ID
  Future<Recipe?> getRecipeById(int id) async {
    final recipes = await loadRecipes();
    try {
      return recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Get bookmarked recipe IDs from SharedPreferences
  Set<int> getBookmarkedIds() {
    final List<String>? bookmarks = sharedPreferences.getStringList(BOOKMARKS_KEY);
    if (bookmarks == null) return {};
    return bookmarks.map((id) => int.parse(id)).toSet();
  }
  
  /// Toggle bookmark status for a recipe
  Future<void> toggleBookmark(int recipeId) async {
    final bookmarks = getBookmarkedIds();
    
    if (bookmarks.contains(recipeId)) {
      bookmarks.remove(recipeId);
    } else {
      bookmarks.add(recipeId);
    }
    
    await sharedPreferences.setStringList(
      BOOKMARKS_KEY,
      bookmarks.map((id) => id.toString()).toList(),
    );
    
    // Update cache
    if (_cachedRecipes != null) {
      final index = _cachedRecipes!.indexWhere((r) => r.id == recipeId);
      if (index != -1) {
        _cachedRecipes![index].bookmarked = bookmarks.contains(recipeId);
      }
    }
  }
  
  /// Check if a recipe is bookmarked
  bool isBookmarked(int recipeId) {
    return getBookmarkedIds().contains(recipeId);
  }
  
  /// Get mastery levels from SharedPreferences
  Map<int, int> getMasteryLevels() {
    final String? levelsJson = sharedPreferences.getString(MASTERY_KEY);
    if (levelsJson == null) return {};
    
    try {
      final Map<String, dynamic> decoded = json.decode(levelsJson);
      return decoded.map((key, value) => MapEntry(int.parse(key), value as int));
    } catch (e) {
      return {};
    }
  }
  
  /// Update mastery level for a recipe
  Future<void> updateMasteryLevel(int recipeId, int level) async {
    // Validate level (0-5 scale)
    if (level < 0 || level > 5) {
      throw ArgumentError('Mastery level must be between 0 and 5');
    }
    
    final levels = getMasteryLevels();
    levels[recipeId] = level;
    
    final String jsonString = json.encode(
      levels.map((key, value) => MapEntry(key.toString(), value))
    );
    await sharedPreferences.setString(MASTERY_KEY, jsonString);
    
    // Update cache
    if (_cachedRecipes != null) {
      final index = _cachedRecipes!.indexWhere((r) => r.id == recipeId);
      if (index != -1) {
        _cachedRecipes![index].masteryLevel = level;
      }
    }
  }
  
  /// Get mastery level for a recipe
  int getMasteryLevel(int recipeId) {
    final levels = getMasteryLevels();
    return levels[recipeId] ?? 0;
  }
  
  /// Clear cache (useful for testing or data refresh)
  void clearCache() {
    _cachedRecipes = null;
  }
  
  /// Get recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final recipes = await loadRecipes();
    return recipes.where((recipe) => recipe.category == category).toList();
  }
  
  /// Get bookmarked recipes
  Future<List<Recipe>> getBookmarkedRecipes() async {
    final recipes = await loadRecipes();
    return recipes.where((recipe) => recipe.bookmarked).toList();
  }
  
  /// Search recipes by query
  Future<List<Recipe>> searchRecipes(String query) async {
    final recipes = await loadRecipes();
    final lowerQuery = query.toLowerCase();
    
    return recipes.where((recipe) {
      return recipe.name.toLowerCase().contains(lowerQuery) ||
             recipe.category.toLowerCase().contains(lowerQuery) ||
             recipe.ingredients.any((ingredient) => 
                 ingredient.toLowerCase().contains(lowerQuery));
    }).toList();
  }
  
  /// Get all unique categories
  Future<List<String>> getCategories() async {
    final recipes = await loadRecipes();
    final categories = recipes.map((r) => r.category).toSet().toList();
    categories.sort();
    return categories;
  }
}