import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/learning_statistics.dart';
import 'recipe_provider.dart';

class StatisticsProvider extends ChangeNotifier {
  final SharedPreferences sharedPreferences;
  final RecipeProvider recipeProvider;
  
  LearningStatistics _statistics = LearningStatistics();
  List<Achievement> _achievements = List.from(Achievement.allAchievements);
  
  static const String _statisticsKey = 'learning_statistics';
  static const String _achievementsKey = 'achievements';
  
  StatisticsProvider({
    required this.sharedPreferences,
    required this.recipeProvider,
  }) {
    _loadStatistics();
    _loadAchievements();
  }
  
  // Getters
  LearningStatistics get statistics => _statistics;
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => 
      _achievements.where((a) => a.unlocked).toList();
  List<Achievement> get lockedAchievements => 
      _achievements.where((a) => !a.unlocked).toList();
  List<Achievement> get allAchievements => Achievement.allAchievements;
  
  // Load statistics from SharedPreferences
  Future<void> _loadStatistics() async {
    final statisticsJson = sharedPreferences.getString(_statisticsKey);
    if (statisticsJson != null) {
      try {
        final statisticsMap = json.decode(statisticsJson) as Map<String, dynamic>;
        _statistics = LearningStatistics.fromJson(statisticsMap);
        notifyListeners();
      } catch (e) {
        print('Error loading statistics: $e');
        _statistics = LearningStatistics();
      }
    }
  }
  
  // Save statistics to SharedPreferences
  Future<void> _saveStatistics() async {
    try {
      final statisticsJson = json.encode(_statistics.toJson());
      await sharedPreferences.setString(_statisticsKey, statisticsJson);
    } catch (e) {
      print('Error saving statistics: $e');
    }
  }
  
  // Load achievements from SharedPreferences
  Future<void> _loadAchievements() async {
    final achievementsJson = sharedPreferences.getString(_achievementsKey);
    if (achievementsJson != null) {
      try {
        final achievementsList = json.decode(achievementsJson) as List<dynamic>;
        _achievements = achievementsList
            .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      } catch (e) {
        print('Error loading achievements: $e');
      }
    }
  }
  
  // Save achievements to SharedPreferences
  Future<void> _saveAchievements() async {
    try {
      final achievementsJson = json.encode(
        _achievements.map((achievement) => achievement.toJson()).toList()
      );
      await sharedPreferences.setString(_achievementsKey, achievementsJson);
    } catch (e) {
      print('Error saving achievements: $e');
    }
  }
  
  // Add a study session
  Future<void> addStudySession(int recipeId, int durationMinutes) async {
    _statistics.addStudySession(recipeId, durationMinutes);
    _updateMasteryCount();
    await _saveStatistics();
    await _checkAchievements();
    notifyListeners();
  }
  
  // Add a game result
  Future<void> addGameResult(GameResult result) async {
    _statistics.addGameResult(result);
    if (result.successful) {
      await addStudySession(result.recipeId, (result.durationSeconds / 60).ceil());
    }
    await _saveStatistics();
    await _checkAchievements();
    notifyListeners();
  }
  
  // Update mastery count based on current recipe provider state
  void _updateMasteryCount() {
    final masteredCount = recipeProvider.allRecipes
        .where((recipe) => recipe.masteryLevel >= 4)
        .length;
    _statistics.updateMasteryCount(masteredCount);
  }
  
  // Get category progress
  Map<String, double> getCategoryProgress() {
    final categoryRecipes = <String, List<int>>{};
    final masteryLevels = <int, int>{};
    
    // Group recipes by category
    for (final recipe in recipeProvider.allRecipes) {
      categoryRecipes.putIfAbsent(recipe.category, () => []).add(recipe.id);
      masteryLevels[recipe.id] = recipe.masteryLevel;
    }
    
    return _statistics.getCategoryProgress(categoryRecipes, masteryLevels);
  }
  
  // Get overall progress percentage
  double getOverallProgress() {
    final totalRecipes = recipeProvider.totalRecipeCount;
    if (totalRecipes == 0) return 0.0;
    return _statistics.recipesMastered / totalRecipes;
  }
  
  // Get daily study goal progress
  int getDailyStudyGoal() => 5; // recipes per day
  
  double getDailyProgress() {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    int todayStudyCount = 0;
    _statistics.lastStudied.forEach((recipeId, dateString) {
      if (dateString.startsWith(todayString)) {
        todayStudyCount++;
      }
    });
    
    return todayStudyCount / getDailyStudyGoal();
  }
  
  // Check and unlock achievements
  Future<void> _checkAchievements() async {
    bool hasNewAchievement = false;
    final now = DateTime.now().toIso8601String();
    
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (achievement.unlocked) continue;
      
      bool shouldUnlock = false;
      
      switch (achievement.id) {
        case 'first_recipe':
          shouldUnlock = _statistics.recipesStudied > 0;
          break;
          
        case 'category_master':
          final categoryProgress = getCategoryProgress();
          shouldUnlock = categoryProgress.values.any((progress) => progress >= 1.0);
          break;
          
        case 'week_streak':
          shouldUnlock = _statistics.currentStreak >= 7;
          break;
          
        case 'game_perfect':
          final recentGames = _statistics.gameHistory.take(10).toList();
          shouldUnlock = recentGames.length >= 10 && 
                        recentGames.every((game) => game.successful);
          break;
          
        case 'master_chef':
          shouldUnlock = _statistics.recipesMastered >= recipeProvider.totalRecipeCount;
          break;
          
        case 'speed_learner':
          final today = DateTime.now();
          final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
          int todayStudyCount = 0;
          _statistics.lastStudied.forEach((recipeId, dateString) {
            if (dateString.startsWith(todayString)) {
              todayStudyCount++;
            }
          });
          shouldUnlock = todayStudyCount >= 10;
          break;
      }
      
      if (shouldUnlock) {
        _achievements[i] = achievement.copyWith(
          unlocked: true,
          unlockedDate: now,
        );
        hasNewAchievement = true;
      }
    }
    
    if (hasNewAchievement) {
      await _saveAchievements();
      notifyListeners();
    }
  }
  
  // Get recently unlocked achievements (within last 7 days)
  List<Achievement> getRecentAchievements() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    return _achievements.where((achievement) {
      if (!achievement.unlocked || achievement.unlockedDate == null) return false;
      final unlockedDate = DateTime.parse(achievement.unlockedDate!);
      return unlockedDate.isAfter(weekAgo);
    }).toList();
  }
  
  // Get study streak description
  String getStreakDescription() {
    if (_statistics.currentStreak == 0) {
      return '오늘 학습을 시작해보세요!';
    } else if (_statistics.currentStreak == 1) {
      return '좋은 시작이에요! 내일도 계속해보세요.';
    } else if (_statistics.currentStreak < 7) {
      return '${_statistics.currentStreak}일 연속 학습 중! 일주일까지 ${7 - _statistics.currentStreak}일 남았어요.';
    } else {
      return '${_statistics.currentStreak}일 연속 학습! 대단해요! 🔥';
    }
  }
  
  // Get study time formatted string
  String getFormattedStudyTime() {
    final hours = _statistics.totalStudyTime ~/ 60;
    final minutes = _statistics.totalStudyTime % 60;
    
    if (hours == 0) {
      return '${minutes}분';
    } else {
      return '${hours}시간 ${minutes}분';
    }
  }
  
  // Get learning suggestions based on statistics
  List<String> getLearningTips() {
    final tips = <String>[];
    
    if (_statistics.currentStreak == 0) {
      tips.add('매일 조금씩 학습하는 것이 효과적입니다.');
    }
    
    if (_statistics.gameSuccessRate < 0.7) {
      tips.add('게임 정답률이 낮습니다. 단계를 더 자세히 학습해보세요.');
    }
    
    final categoryProgress = getCategoryProgress();
    final lowProgressCategories = categoryProgress.entries
        .where((entry) => entry.value < 0.3)
        .map((entry) => entry.key)
        .toList();
    
    if (lowProgressCategories.isNotEmpty) {
      tips.add('${lowProgressCategories.first} 카테고리 학습에 더 집중해보세요.');
    }
    
    if (_statistics.averageStudyTimePerRecipe < 5) {
      tips.add('각 레시피를 더 깊이 학습해보세요. 평균 학습 시간이 짧습니다.');
    }
    
    if (tips.isEmpty) {
      tips.add('훌륭하게 학습하고 있습니다! 계속 진행하세요.');
    }
    
    return tips;
  }
  
  // Export statistics data
  Map<String, dynamic> exportData() {
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '3.0.0',
      'statistics': _statistics.toJson(),
      'achievements': _achievements.map((a) => a.toJson()).toList(),
    };
  }
  
  // Import statistics data
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      if (data['statistics'] != null) {
        _statistics = LearningStatistics.fromJson(data['statistics']);
        await _saveStatistics();
      }
      
      if (data['achievements'] != null) {
        _achievements = (data['achievements'] as List)
            .map((json) => Achievement.fromJson(json))
            .toList();
        await _saveAchievements();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }
  
  // Reset all statistics (for testing or fresh start)
  Future<void> resetAllStatistics() async {
    _statistics = LearningStatistics();
    _achievements = List.from(Achievement.allAchievements);
    
    await _saveStatistics();
    await _saveAchievements();
    
    notifyListeners();
  }
  
  // Get category statistics
  Map<String, int> getCategoryStats() {
    final categoryStats = <String, int>{};
    
    // Get category counts from recipe provider
    for (final recipe in recipeProvider.allRecipes) {
      final category = recipe.category;
      final studyCount = _statistics.studyCount[recipe.id.toString()] ?? 0;
      categoryStats[category] = (categoryStats[category] ?? 0) + studyCount;
    }
    
    return categoryStats;
  }
  
  
  // Get achievements that are in progress (not yet unlocked)
  List<Achievement> getProgressAchievements() {
    return _achievements.where((a) => !a.unlocked).take(5).toList();
  }
  
  // Get progress for a specific achievement (0.0 to 1.0)
  double getAchievementProgress(Achievement achievement) {
    switch (achievement.id) {
      case 'first_recipe':
        return _statistics.recipesStudied > 0 ? 1.0 : 0.0;
        
      case 'category_master':
        final categoryProgress = getCategoryProgress();
        final maxProgress = categoryProgress.values.isEmpty ? 0.0 : categoryProgress.values.reduce((a, b) => a > b ? a : b);
        return maxProgress;
        
      case 'week_streak':
        return (_statistics.currentStreak / 7.0).clamp(0.0, 1.0);
        
      case 'game_perfect':
        final recentGames = _statistics.gameHistory.take(10).toList();
        if (recentGames.length < 10) return recentGames.length / 10.0;
        final successfulCount = recentGames.where((game) => game.successful).length;
        return successfulCount / 10.0;
        
      case 'master_chef':
        final totalRecipes = recipeProvider.totalRecipeCount;
        return totalRecipes > 0 ? _statistics.recipesMastered / totalRecipes : 0.0;
        
      case 'speed_learner':
        final today = DateTime.now();
        final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        int todayStudyCount = 0;
        _statistics.lastStudied.forEach((recipeId, dateString) {
          if (dateString.startsWith(todayString)) {
            todayStudyCount++;
          }
        });
        return (todayStudyCount / 10.0).clamp(0.0, 1.0);
        
      default:
        return 0.0;
    }
  }
}