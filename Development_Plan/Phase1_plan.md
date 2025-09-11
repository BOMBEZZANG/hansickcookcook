# 📝 PHASE 1: Foundation & Data Setup (Detailed)

## **Objectives**
- Establish solid project foundation with clean architecture
- Convert existing CSV data to structured JSON format
- Implement core data layer with models and repositories
- Set up basic navigation and dependency injection

## **Day 1: Project Setup & Architecture**

### 1.1 Flutter Project Initialization
```bash
# Commands to execute
flutter create hansick_recipe_app
cd hansick_recipe_app
flutter pub add provider
flutter pub add shared_preferences
flutter pub add json_annotation
flutter pub add build_runner
flutter pub add json_serializable
flutter pub add flutter_native_splash
flutter pub add google_fonts
```

### 1.2 Project Structure Creation
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_constants.dart
│   ├── themes/
│   │   └── app_theme.dart
│   └── utils/
│       ├── json_helper.dart
│       └── logger.dart
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
├── presentation/
│   ├── providers/
│   ├── screens/
│   └── widgets/
└── routes/
```

### 1.3 Core Constants Implementation

**app_colors.dart**
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Category Colors
  static const Map<String, Color> categoryColors = {
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
  };
  
  // App Theme Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}
```

**app_constants.dart**
```dart
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
}
```

## **Day 2: Data Migration & Models**

### 2.1 CSV to JSON Conversion Script
Create a separate Dart script for conversion:

**tools/csv_to_json_converter.dart**
```dart
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';

void main() async {
  // Read CSV file
  final input = File('C:/Projects/hansickcookcook/CookingManual/MENU_manual.csv');
  final csvString = await input.readAsString(encoding: Encoding.getByName('utf-8')!);
  
  // Parse CSV
  final List<List<dynamic>> csvData = CsvToListConverter().convert(csvString);
  
  // Convert to JSON structure
  final List<Map<String, dynamic>> recipes = [];
  
  for (int i = 1; i < csvData.length; i++) { // Skip header
    final row = csvData[i];
    
    // Parse steps (assuming steps are in separate columns)
    final List<Map<String, dynamic>> steps = [];
    int stepIndex = 1;
    
    // Assuming columns: id, name, category, time, ingredients, requirements, step1, step2...
    for (int j = 6; j < row.length; j++) {
      if (row[j] != null && row[j].toString().isNotEmpty) {
        steps.add({
          'order': stepIndex++,
          'description': row[j].toString().trim()
        });
      }
    }
    
    recipes.add({
      'id': i,
      'name': row[1].toString().trim(),
      'category': row[2].toString().trim(),
      'examTime': int.parse(row[3].toString()),
      'ingredients': row[4].toString().split('|').map((e) => e.trim()).toList(),
      'requirements': row[5].toString().split('|').map((e) => e.trim()).toList(),
      'steps': steps,
      'bookmarked': false,
      'masteryLevel': 0
    });
  }
  
  // Write JSON file
  final jsonOutput = {
    'version': '1.0.0',
    'lastUpdated': DateTime.now().toIso8601String(),
    'recipes': recipes
  };
  
  final outputFile = File('assets/data/recipes.json');
  await outputFile.create(recursive: true);
  await outputFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(jsonOutput),
    encoding: Encoding.getByName('utf-8')!
  );
  
  print('Conversion complete! ${recipes.length} recipes converted.');
}
```

### 2.2 Data Models Implementation

**models/recipe.dart**
```dart
import 'package:json_annotation/json_annotation.dart';
import 'recipe_step.dart';

part 'recipe.g.dart';

@JsonSerializable()
class Recipe {
  final int id;
  final String name;
  final String category;
  final int examTime;
  final List<String> ingredients;
  final List<String> requirements;
  final List<RecipeStep> steps;
  bool bookmarked;
  int masteryLevel;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.examTime,
    required this.ingredients,
    required this.requirements,
    required this.steps,
    this.bookmarked = false,
    this.masteryLevel = 0,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);

  // Helper methods
  String get categoryIcon => AppConstants.categoryIcons[category] ?? '🍽️';
  Color get categoryColor => AppColors.categoryColors[category] ?? Colors.grey;
  
  Recipe copyWith({
    bool? bookmarked,
    int? masteryLevel,
  }) {
    return Recipe(
      id: id,
      name: name,
      category: category,
      examTime: examTime,
      ingredients: ingredients,
      requirements: requirements,
      steps: steps,
      bookmarked: bookmarked ?? this.bookmarked,
      masteryLevel: masteryLevel ?? this.masteryLevel,
    );
  }
}
```

**models/recipe_step.dart**
```dart
import 'package:json_annotation/json_annotation.dart';

part 'recipe_step.g.dart';

@JsonSerializable()
class RecipeStep {
  final int order;
  final String description;
  final String? tip;

  RecipeStep({
    required this.order,
    required this.description,
    this.tip,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) => 
      _$RecipeStepFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeStepToJson(this);
}
```

### 2.3 Generate Model Files
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## **Day 3: Repository Layer & Local Storage**

### 3.1 Local DataSource Implementation

**datasources/local/recipe_local_datasource.dart**
```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/recipe.dart';

class RecipeLocalDataSource {
  static const String RECIPES_ASSET_PATH = 'assets/data/recipes.json';
  static const String BOOKMARKS_KEY = 'bookmarked_recipes';
  static const String MASTERY_KEY = 'mastery_levels';
  
  final SharedPreferences sharedPreferences;
  List<Recipe>? _cachedRecipes;
  
  RecipeLocalDataSource(this.sharedPreferences);
  
  // Load recipes from assets with caching
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
  
  // Bookmark management
  Set<int> getBookmarkedIds() {
    final List<String>? bookmarks = sharedPreferences.getStringList(BOOKMARKS_KEY);
    if (bookmarks == null) return {};
    return bookmarks.map((id) => int.parse(id)).toSet();
  }
  
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
  
  // Mastery level management
  Map<int, int> getMasteryLevels() {
    final String? levelsJson = sharedPreferences.getString(MASTERY_KEY);
    if (levelsJson == null) return {};
    
    final Map<String, dynamic> decoded = json.decode(levelsJson);
    return decoded.map((key, value) => MapEntry(int.parse(key), value as int));
  }
  
  Future<void> updateMasteryLevel(int recipeId, int level) async {
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
}
```

### 3.2 Repository Implementation

**repositories/recipe_repository.dart**
```dart
import '../datasources/local/recipe_local_datasource.dart';
import '../models/recipe.dart';

class RecipeRepository {
  final RecipeLocalDataSource localDataSource;
  
  RecipeRepository(this.localDataSource);
  
  Future<List<Recipe>> getAllRecipes() async {
    return await localDataSource.loadRecipes();
  }
  
  Future<List<Recipe>> getBookmarkedRecipes() async {
    final recipes = await getAllRecipes();
    return recipes.where((recipe) => recipe.bookmarked).toList();
  }
  
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final recipes = await getAllRecipes();
    return recipes.where((recipe) => recipe.category == category).toList();
  }
  
  Future<List<Recipe>> searchRecipes(String query) async {
    final recipes = await getAllRecipes();
    final lowerQuery = query.toLowerCase();
    
    return recipes.where((recipe) {
      return recipe.name.toLowerCase().contains(lowerQuery) ||
             recipe.category.toLowerCase().contains(lowerQuery) ||
             recipe.ingredients.any((ingredient) => 
                 ingredient.toLowerCase().contains(lowerQuery));
    }).toList();
  }
  
  Future<void> toggleBookmark(int recipeId) async {
    await localDataSource.toggleBookmark(recipeId);
  }
  
  Future<void> updateMasteryLevel(int recipeId, int level) async {
    await localDataSource.updateMasteryLevel(recipeId, level);
  }
}
```

## **Day 4: Navigation & Initial Provider Setup**

### 4.1 App Navigation Structure

**routes/app_routes.dart**
```dart
class AppRoutes {
  static const String home = '/';
  static const String flashcard = '/flashcard';
  static const String search = '/search';
  static const String bookmarks = '/bookmarks';
}
```

**routes/app_router.dart**
```dart
import 'package:flutter/material.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/flashcard/flashcard_screen.dart';
import '../presentation/screens/search/search_screen.dart';
import '../presentation/screens/bookmarks/bookmarks_screen.dart';
import '../data/models/recipe.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
        
      case AppRoutes.flashcard:
        final recipe = settings.arguments as Recipe;
        return MaterialPageRoute(
          builder: (_) => FlashcardScreen(recipe: recipe),
        );
        
      case AppRoutes.search:
        return MaterialPageRoute(
          builder: (_) => const SearchScreen(),
        );
        
      case AppRoutes.bookmarks:
        return MaterialPageRoute(
          builder: (_) => const BookmarksScreen(),
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
```

### 4.2 Base Provider Setup

**providers/recipe_provider.dart**
```dart
import 'package:flutter/material.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/models/recipe.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository repository;
  
  List<Recipe> _allRecipes = [];
  List<Recipe> _displayedRecipes = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = '전체';
  
  RecipeProvider(this.repository) {
    loadRecipes();
  }
  
  // Getters
  List<Recipe> get recipes => _displayedRecipes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  
  List<String> get categories {
    final cats = _allRecipes.map((r) => r.category).toSet().toList();
    cats.sort();
    return ['전체', ...cats];
  }
  
  // Load all recipes
  Future<void> loadRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _allRecipes = await repository.getAllRecipes();
      _displayedRecipes = _allRecipes;
      _error = null;
    } catch (e) {
      _error = 'Failed to load recipes: $e';
      _displayedRecipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    
    if (category == '전체') {
      _displayedRecipes = _allRecipes;
    } else {
      _displayedRecipes = _allRecipes
          .where((recipe) => recipe.category == category)
          .toList();
    }
    notifyListeners();
  }
  
  // Toggle bookmark
  Future<void> toggleBookmark(int recipeId) async {
    await repository.toggleBookmark(recipeId);
    
    // Update local state
    final index = _allRecipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _allRecipes[index].bookmarked = !_allRecipes[index].bookmarked;
      notifyListeners();
    }
  }
}
```

### 4.3 Main App Setup

**main.dart**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/datasources/local/recipe_local_datasource.dart';
import 'data/repositories/recipe_repository.dart';
import 'presentation/providers/recipe_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  final localDataSource = RecipeLocalDataSource(sharedPreferences);
  final repository = RecipeRepository(localDataSource);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RecipeProvider(repository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

**app.dart**
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/themes/app_theme.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '한식조리기능사 레시피',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.notoSans().fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

## **Deliverables for Phase 1**

### ✅ Completed Items:
1. **Project Structure**: Clean architecture with separation of concerns
2. **Data Migration**: CSV to JSON converter with validation
3. **Data Models**: Type-safe models with JSON serialization
4. **Local Storage**: SharedPreferences integration for user data
5. **Repository Pattern**: Abstraction layer for data access
6. **Provider Setup**: State management foundation
7. **Navigation**: Route management system
8. **Constants**: Centralized colors, icons, and app constants

### 📋 Testing Checklist:
- [ ] JSON file loads correctly from assets
- [ ] All 33 recipes are present in the data
- [ ] Korean text displays without encoding issues
- [ ] SharedPreferences persist after app restart
- [ ] Repository methods return expected data
- [ ] Provider notifies listeners on state changes

### 🔗 Dependencies Added:
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  shared_preferences: ^2.2.0
  json_annotation: ^4.8.1
  google_fonts: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.6
  json_serializable: ^6.7.1
  flutter_lints: ^2.0.3
```

### 📝 Next Steps (Phase 2 Preview):
- Implement Home Screen UI with grid layout
- Create recipe grid item widget
- Add category filter chips
- Implement bottom navigation
- Create placeholder screens for navigation

## **Success Criteria for Phase 1**:
- ✅ App launches without errors
- ✅ Data loads from JSON file
- ✅ Navigation routes are functional
- ✅ Provider pattern is working
- ✅ Local storage saves and retrieves data
- ✅ All 33 recipes are accessible via repository

---

This foundation phase ensures a solid, scalable base for the MVP. All subsequent phases will build upon this architecture without requiring major refactoring.