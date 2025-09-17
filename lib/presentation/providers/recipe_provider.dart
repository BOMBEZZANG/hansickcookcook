import 'package:flutter/material.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/models/recipe.dart';
import '../../core/constants/app_strings.dart';

/// Provider for recipe state management
/// 
/// This provider manages the application state for recipes including:
/// - Loading and displaying recipes
/// - Category filtering
/// - Search functionality
/// - Bookmark management
/// - Mastery level tracking
class RecipeProvider extends ChangeNotifier {
  final RecipeRepository repository;
  
  // State variables
  List<Recipe> _allRecipes = [];
  List<Recipe> _displayedRecipes = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = AppStrings.allCategories;
  String _searchQuery = '';
  
  RecipeProvider(this.repository) {
    loadRecipes();
  }
  
  // Getters
  List<Recipe> get recipes => _displayedRecipes;
  List<Recipe> get allRecipes => _allRecipes;
  List<String> get categories {
    final cats = [AppStrings.allCategories, ..._categories];
    return cats;
  }
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get hasRecipes => _allRecipes.isNotEmpty;
  int get totalRecipeCount => _allRecipes.length;
  int get displayedRecipeCount => _displayedRecipes.length;
  
  // Computed getters
  List<Recipe> get bookmarkedRecipes => 
      _allRecipes.where((recipe) => recipe.bookmarked).toList();
  
  int get bookmarkedCount => bookmarkedRecipes.length;
  
  // Mastery level getters
  int get masteredCount => _allRecipes.where((recipe) => recipe.masteryLevel >= 5).length;
  
  Map<String, int> get categoryCount {
    final Map<String, int> counts = {};
    for (final recipe in _allRecipes) {
      counts[recipe.category] = (counts[recipe.category] ?? 0) + 1;
    }
    return counts;
  }
  
  /// Load all recipes from repository
  Future<void> loadRecipes() async {
    _setLoading(true);
    _error = null;
    
    try {
      _allRecipes = await repository.getAllRecipes();
      print('DEBUG: Loaded ${_allRecipes.length} recipes');
      for (var recipe in _allRecipes.take(3)) {
        print('DEBUG: Recipe: ${recipe.name} (${recipe.category})');
      }
      _categories = await repository.getCategories();
      print('DEBUG: Loaded ${_categories.length} categories: $_categories');
      _applyFilters();
      print('DEBUG: After filters: ${_displayedRecipes.length} displayed recipes');
      _error = null;
    } catch (e) {
      print('DEBUG: Error loading recipes: $e');
      _error = 'Failed to load recipes: $e';
      _allRecipes = [];
      _displayedRecipes = [];
    } finally {
      _setLoading(false);
    }
  }
  
  /// Refresh data from repository
  Future<void> refreshData() async {
    try {
      await repository.refreshData();
      await loadRecipes();
    } catch (e) {
      _error = 'Failed to refresh data: $e';
      notifyListeners();
    }
  }
  
  /// Filter recipes by category
  void filterByCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _applyFilters();
    }
  }
  
  /// Search recipes by query
  void searchRecipes(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFilters();
    }
  }
  
  /// Clear search and filters
  void clearSearch() {
    _searchQuery = '';
    _selectedCategory = AppStrings.allCategories;
    _applyFilters();
  }
  
  /// Toggle bookmark for a recipe
  Future<void> toggleBookmark(int recipeId) async {
    // Find the recipe first
    final recipeIndex = _allRecipes.indexWhere((r) => r.id == recipeId);
    if (recipeIndex == -1) return;
    
    // Update local state immediately (optimistic update)
    final previousState = _allRecipes[recipeIndex].bookmarked;
    _allRecipes[recipeIndex].bookmarked = !previousState;
    _applyFilters(); // This already calls notifyListeners()
    
    try {
      // Then update the repository
      await repository.toggleBookmark(recipeId);
    } catch (e) {
      // Revert on error
      _allRecipes[recipeIndex].bookmarked = previousState;
      _error = 'Failed to toggle bookmark: $e';
      _applyFilters();
    }
  }
  
  /// Update mastery level for a recipe
  Future<void> updateMasteryLevel(int recipeId, int level) async {
    try {
      await repository.updateMasteryLevel(recipeId, level);
      
      // Update local state
      final recipeIndex = _allRecipes.indexWhere((r) => r.id == recipeId);
      if (recipeIndex != -1) {
        _allRecipes[recipeIndex].masteryLevel = level;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update mastery level: $e';
      notifyListeners();
    }
  }
  
  /// Get a specific recipe by ID
  Recipe? getRecipeById(int id) {
    try {
      return _allRecipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Get recipes needing practice (low mastery level)
  List<Recipe> getRecipesNeedingPractice({int threshold = 3}) {
    return _allRecipes.where((recipe) => recipe.masteryLevel < threshold).toList();
  }
  
  /// Get recipes by mastery level
  List<Recipe> getRecipesByMasteryLevel(int level) {
    return _allRecipes.where((recipe) => recipe.masteryLevel == level).toList();
  }
  
  /// Get recipe statistics
  Map<String, dynamic> getRecipeStats() {
    final masteryStats = <int, int>{};
    for (final recipe in _allRecipes) {
      masteryStats[recipe.masteryLevel] = (masteryStats[recipe.masteryLevel] ?? 0) + 1;
    }
    
    return {
      'totalRecipes': _allRecipes.length,
      'bookmarkedCount': bookmarkedCount,
      'categoryStats': categoryCount,
      'masteryStats': masteryStats,
      'averageMastery': _allRecipes.isEmpty ? 0.0 : 
          _allRecipes.map((r) => r.masteryLevel).reduce((a, b) => a + b) / _allRecipes.length,
    };
  }
  
  /// Apply current filters and search to recipes
  void _applyFilters() {
    List<Recipe> filtered = List.from(_allRecipes);
    
    // Apply category filter
    if (_selectedCategory != AppStrings.allCategories) {
      filtered = filtered.where((recipe) => recipe.category == _selectedCategory).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((recipe) {
        return recipe.name.toLowerCase().contains(lowerQuery) ||
               recipe.category.toLowerCase().contains(lowerQuery) ||
               recipe.ingredients.any((ingredient) => 
                   ingredient.toLowerCase().contains(lowerQuery));
      }).toList();
    }
    
    _displayedRecipes = filtered;
    notifyListeners();
  }
  
  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  /// Clear error state
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}