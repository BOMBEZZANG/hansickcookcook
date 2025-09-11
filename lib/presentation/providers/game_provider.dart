import 'package:flutter/material.dart';
import 'dart:math';
import '../../data/models/recipe.dart';
import '../../data/models/recipe_step.dart';
import '../../data/models/learning_statistics.dart';
import 'recipe_provider.dart';
import 'statistics_provider.dart';

enum GameState {
  ready,    // Game ready to start
  playing,  // Game in progress
  checking, // Checking answer
  success,  // Correct answer
  failure,  // Incorrect answer
  finished, // Game completed
}

class GameProvider extends ChangeNotifier {
  final RecipeProvider recipeProvider;
  final StatisticsProvider statisticsProvider;
  
  // Game state
  Recipe? _currentRecipe;
  List<RecipeStep> _originalSteps = [];
  List<RecipeStep> _shuffledSteps = [];
  List<RecipeStep> _userOrderedSteps = [];
  GameState _gameState = GameState.ready;
  int _attempts = 0;
  int _score = 0;
  int _maxScore = 100;
  DateTime? _gameStartTime;
  
  // Game settings
  bool _showHints = true;
  bool _enableHapticFeedback = true;
  
  GameProvider({
    required this.recipeProvider,
    required this.statisticsProvider,
  });
  
  // Getters
  Recipe? get currentRecipe => _currentRecipe;
  List<RecipeStep> get shuffledSteps => _shuffledSteps;
  List<RecipeStep> get userOrderedSteps => _userOrderedSteps;
  List<RecipeStep> get originalSteps => _originalSteps;
  GameState get gameState => _gameState;
  int get attempts => _attempts;
  int get score => _score;
  int get maxScore => _maxScore;
  bool get showHints => _showHints;
  bool get enableHapticFeedback => _enableHapticFeedback;
  
  // Game duration
  Duration get gameDuration {
    if (_gameStartTime == null) return Duration.zero;
    return DateTime.now().difference(_gameStartTime!);
  }
  
  // Initialize game with a recipe
  void startGame(Recipe recipe) {
    _currentRecipe = recipe;
    _originalSteps = List.from(recipe.steps);
    _shuffledSteps = _shuffleSteps(recipe.steps);
    _userOrderedSteps = List.from(_shuffledSteps);
    _gameState = GameState.playing;
    _attempts = 0;
    _score = 0;
    _maxScore = _calculateMaxScore(recipe);
    _gameStartTime = DateTime.now();
    
    notifyListeners();
  }
  
  // Start game with random recipe
  void startRandomGame() {
    final availableRecipes = recipeProvider.allRecipes;
    if (availableRecipes.isNotEmpty) {
      final random = Random();
      final randomRecipe = availableRecipes[random.nextInt(availableRecipes.length)];
      startGame(randomRecipe);
    }
  }
  
  // Start game focusing on recipes that need practice
  void startPracticeGame() {
    final practiceRecipes = recipeProvider.allRecipes
        .where((recipe) => recipe.masteryLevel < 3)
        .toList();
    
    if (practiceRecipes.isNotEmpty) {
      final random = Random();
      final randomRecipe = practiceRecipes[random.nextInt(practiceRecipes.length)];
      startGame(randomRecipe);
    } else {
      // Fallback to random if all recipes are mastered
      startRandomGame();
    }
  }
  
  // Shuffle steps randomly
  List<RecipeStep> _shuffleSteps(List<RecipeStep> steps) {
    final shuffled = List<RecipeStep>.from(steps);
    shuffled.shuffle();
    
    // Ensure it's actually different from the original order
    bool isSame = true;
    for (int i = 0; i < steps.length; i++) {
      if (shuffled[i].order != steps[i].order) {
        isSame = false;
        break;
      }
    }
    
    // If by chance it's the same order, shuffle again
    if (isSame && steps.length > 1) {
      return _shuffleSteps(steps);
    }
    
    return shuffled;
  }
  
  // Calculate maximum possible score
  int _calculateMaxScore(Recipe recipe) {
    int baseScore = 100;
    int difficultyBonus = recipe.difficulty * 10;
    int stepComplexityBonus = recipe.steps.length * 5;
    return baseScore + difficultyBonus + stepComplexityBonus;
  }
  
  // Reorder steps (for drag and drop)
  void reorderSteps(int oldIndex, int newIndex) {
    if (_gameState != GameState.playing) return;
    
    // Handle Flutter's ReorderableList behavior
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    final step = _userOrderedSteps.removeAt(oldIndex);
    _userOrderedSteps.insert(newIndex, step);
    
    // Provide haptic feedback if enabled
    if (_enableHapticFeedback) {
      // Note: Import package:flutter/services.dart and use HapticFeedback.lightImpact()
    }
    
    notifyListeners();
  }
  
  // Check if the current order is correct
  bool checkAnswer() {
    if (_gameState != GameState.playing || _currentRecipe == null) return false;
    
    _gameState = GameState.checking;
    _attempts++;
    
    notifyListeners();
    
    // Compare user order with original order
    bool isCorrect = true;
    for (int i = 0; i < _userOrderedSteps.length; i++) {
      if (_userOrderedSteps[i].order != _originalSteps[i].order) {
        isCorrect = false;
        break;
      }
    }
    
    if (isCorrect) {
      _handleCorrectAnswer();
    } else {
      _handleIncorrectAnswer();
    }
    
    return isCorrect;
  }
  
  void _handleCorrectAnswer() {
    _gameState = GameState.success;
    _score = _calculateScore();
    
    // Update recipe mastery
    if (_currentRecipe != null) {
      recipeProvider.updateMasteryLevel(_currentRecipe!.id, 1);
    }
    
    // Record game result
    _recordGameResult(true);
    
    notifyListeners();
  }
  
  void _handleIncorrectAnswer() {
    _gameState = GameState.failure;
    
    // Allow up to 3 attempts
    if (_attempts >= 3) {
      _gameState = GameState.finished;
      _recordGameResult(false);
    }
    
    notifyListeners();
  }
  
  int _calculateScore() {
    if (_currentRecipe == null) return 0;
    
    int baseScore = _maxScore;
    
    // Penalty for multiple attempts
    switch (_attempts) {
      case 1:
        // No penalty for first attempt
        break;
      case 2:
        baseScore = (baseScore * 0.7).round(); // 30% penalty
        break;
      case 3:
        baseScore = (baseScore * 0.4).round(); // 60% penalty
        break;
      default:
        baseScore = 0;
    }
    
    // Time bonus/penalty
    final duration = gameDuration;
    final expectedTime = (_currentRecipe!.examTime * 0.5).round(); // 50% of exam time
    if (duration.inMinutes < expectedTime) {
      // Time bonus: 1 point per second under expected time
      final bonusSeconds = (expectedTime * 60) - duration.inSeconds;
      baseScore += bonusSeconds.clamp(0, 50); // Max 50 bonus points
    } else {
      // Time penalty: -1 point per 10 seconds over expected time
      final penaltySeconds = duration.inSeconds - (expectedTime * 60);
      final penalty = (penaltySeconds / 10).ceil();
      baseScore -= penalty;
    }
    
    return baseScore.clamp(0, _maxScore * 2); // Max score can be up to 2x base
  }
  
  void _recordGameResult(bool successful) {
    if (_currentRecipe == null) return;
    
    final result = GameResult(
      recipeId: _currentRecipe!.id,
      recipeName: _currentRecipe!.name,
      successful: successful,
      attempts: _attempts,
      score: successful ? _score : 0,
      durationSeconds: gameDuration.inSeconds,
    );
    
    statisticsProvider.addGameResult(result);
  }
  
  // Get incorrectly placed steps
  List<int> getIncorrectStepIndices() {
    final incorrect = <int>[];
    
    for (int i = 0; i < _userOrderedSteps.length; i++) {
      if (_userOrderedSteps[i].order != _originalSteps[i].order) {
        incorrect.add(i);
      }
    }
    
    return incorrect;
  }
  
  // Reset game to initial shuffled state
  void resetGame() {
    if (_currentRecipe == null) return;
    
    _userOrderedSteps = List.from(_shuffledSteps);
    _gameState = GameState.playing;
    _attempts = 0;
    _score = 0;
    _gameStartTime = DateTime.now();
    
    notifyListeners();
  }
  
  // Start new game with different recipe
  void nextRecipe() {
    final currentId = _currentRecipe?.id;
    final availableRecipes = recipeProvider.allRecipes
        .where((recipe) => recipe.id != currentId)
        .toList();
    
    if (availableRecipes.isNotEmpty) {
      final random = Random();
      final nextRecipe = availableRecipes[random.nextInt(availableRecipes.length)];
      startGame(nextRecipe);
    }
  }
  
  // Get hint for current step
  String? getHintForStep(int stepIndex) {
    if (!_showHints || stepIndex >= _originalSteps.length) return null;
    
    final step = _originalSteps[stepIndex];
    return step.keyPoint ?? step.tip;
  }
  
  // Show correct order (for learning purposes)
  void revealCorrectOrder() {
    _userOrderedSteps = List.from(_originalSteps);
    notifyListeners();
  }
  
  // Settings
  void toggleHints() {
    _showHints = !_showHints;
    notifyListeners();
  }
  
  void toggleHapticFeedback() {
    _enableHapticFeedback = !_enableHapticFeedback;
    notifyListeners();
  }
  
  // Quit current game
  void quitGame() {
    _currentRecipe = null;
    _originalSteps = [];
    _shuffledSteps = [];
    _userOrderedSteps = [];
    _gameState = GameState.ready;
    _attempts = 0;
    _score = 0;
    _gameStartTime = null;
    
    notifyListeners();
  }
  
  // Get progress percentage of current game
  double getProgressPercentage() {
    if (_currentRecipe == null) return 0.0;
    
    int correctPositions = 0;
    for (int i = 0; i < _userOrderedSteps.length; i++) {
      if (_userOrderedSteps[i].order == _originalSteps[i].order) {
        correctPositions++;
      }
    }
    
    return correctPositions / _originalSteps.length;
  }
}