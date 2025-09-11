import 'package:json_annotation/json_annotation.dart';

part 'learning_statistics.g.dart';

@JsonSerializable()
class LearningStatistics {
  int totalStudyTime; // minutes
  int recipesStudied; // count
  int recipesMastered; // mastery level >= 4
  Map<String, int> studyCount; // recipe_id: count
  Map<String, String> lastStudied; // recipe_id: ISO date string
  List<GameResult> gameHistory;
  int currentStreak; // days
  int longestStreak; // days
  String lastActiveDate; // ISO date string

  LearningStatistics({
    this.totalStudyTime = 0,
    this.recipesStudied = 0,
    this.recipesMastered = 0,
    Map<String, int>? studyCount,
    Map<String, String>? lastStudied,
    List<GameResult>? gameHistory,
    this.currentStreak = 0,
    this.longestStreak = 0,
    String? lastActiveDate,
  }) : studyCount = studyCount ?? {},
       lastStudied = lastStudied ?? {},
       gameHistory = gameHistory ?? [],
       lastActiveDate = lastActiveDate ?? DateTime.now().toIso8601String();

  factory LearningStatistics.fromJson(Map<String, dynamic> json) =>
      _$LearningStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$LearningStatisticsToJson(this);

  // Helper methods
  void addStudySession(int recipeId, int durationMinutes) {
    final key = recipeId.toString();
    studyCount[key] = (studyCount[key] ?? 0) + 1;
    lastStudied[key] = DateTime.now().toIso8601String();
    totalStudyTime += durationMinutes;
    recipesStudied = studyCount.length;
    _updateStreak();
  }

  void addGameResult(GameResult result) {
    gameHistory.add(result);
    // Keep only last 100 results
    if (gameHistory.length > 100) {
      gameHistory.removeAt(0);
    }
  }

  void updateMasteryCount(int masteredCount) {
    recipesMastered = masteredCount;
  }

  void _updateStreak() {
    final now = DateTime.now();
    final lastActive = DateTime.parse(lastActiveDate);
    final daysDiff = now.difference(lastActive).inDays;

    if (daysDiff == 0) {
      // Same day, maintain streak
      return;
    } else if (daysDiff == 1) {
      // Next day, continue streak
      currentStreak++;
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    } else {
      // Streak broken
      currentStreak = 1;
    }
    
    lastActiveDate = now.toIso8601String();
  }

  // Statistics getters
  double get averageStudyTimePerRecipe {
    return recipesStudied > 0 ? totalStudyTime / recipesStudied : 0.0;
  }

  int get totalGamesPlayed => gameHistory.length;

  double get gameSuccessRate {
    if (gameHistory.isEmpty) return 0.0;
    final successful = gameHistory.where((r) => r.successful).length;
    return successful / gameHistory.length;
  }

  Map<String, double> getCategoryProgress(Map<String, List<int>> categoryRecipes, Map<int, int> masteryLevels) {
    final progress = <String, double>{};
    
    categoryRecipes.forEach((category, recipeIds) {
      final masteredInCategory = recipeIds.where((id) => (masteryLevels[id] ?? 0) >= 4).length;
      progress[category] = recipeIds.isNotEmpty ? masteredInCategory / recipeIds.length : 0.0;
    });
    
    return progress;
  }
}

@JsonSerializable()
class GameResult {
  final int recipeId;
  final String recipeName;
  final bool successful;
  final int attempts;
  final int score;
  final int durationSeconds;
  final String datePlayed; // ISO date string

  GameResult({
    required this.recipeId,
    required this.recipeName,
    required this.successful,
    required this.attempts,
    required this.score,
    required this.durationSeconds,
    String? datePlayed,
  }) : datePlayed = datePlayed ?? DateTime.now().toIso8601String();

  factory GameResult.fromJson(Map<String, dynamic> json) =>
      _$GameResultFromJson(json);

  Map<String, dynamic> toJson() => _$GameResultToJson(this);
}

@JsonSerializable()
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final String? unlockedDate; // ISO date string

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
    this.unlockedDate,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  Achievement copyWith({
    bool? unlocked,
    String? unlockedDate,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
    );
  }

  static const List<Achievement> allAchievements = [
    Achievement(
      id: 'first_recipe',
      title: '첫 걸음',
      description: '첫 레시피 학습 완료',
      icon: '🌱',
    ),
    Achievement(
      id: 'category_master',
      title: '카테고리 마스터',
      description: '한 카테고리 전체 마스터',
      icon: '👑',
    ),
    Achievement(
      id: 'week_streak',
      title: '열공 일주일',
      description: '7일 연속 학습',
      icon: '🔥',
    ),
    Achievement(
      id: 'game_perfect',
      title: '완벽한 기억',
      description: '게임 10회 연속 정답',
      icon: '🎯',
    ),
    Achievement(
      id: 'master_chef',
      title: '마스터 셰프',
      description: '모든 레시피 마스터',
      icon: '🏆',
    ),
    Achievement(
      id: 'speed_learner',
      title: '스피드 러너',
      description: '하루에 10개 레시피 학습',
      icon: '⚡',
    ),
  ];
}