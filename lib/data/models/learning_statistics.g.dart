// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningStatistics _$LearningStatisticsFromJson(Map<String, dynamic> json) =>
    LearningStatistics(
      totalStudyTime: (json['totalStudyTime'] as num?)?.toInt() ?? 0,
      recipesStudied: (json['recipesStudied'] as num?)?.toInt() ?? 0,
      recipesMastered: (json['recipesMastered'] as num?)?.toInt() ?? 0,
      studyCount: (json['studyCount'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      lastStudied: (json['lastStudied'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      gameHistory: (json['gameHistory'] as List<dynamic>?)
          ?.map((e) => GameResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastActiveDate: json['lastActiveDate'] as String?,
    );

Map<String, dynamic> _$LearningStatisticsToJson(LearningStatistics instance) =>
    <String, dynamic>{
      'totalStudyTime': instance.totalStudyTime,
      'recipesStudied': instance.recipesStudied,
      'recipesMastered': instance.recipesMastered,
      'studyCount': instance.studyCount,
      'lastStudied': instance.lastStudied,
      'gameHistory': instance.gameHistory,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastActiveDate': instance.lastActiveDate,
    };

GameResult _$GameResultFromJson(Map<String, dynamic> json) => GameResult(
  recipeId: (json['recipeId'] as num).toInt(),
  recipeName: json['recipeName'] as String,
  successful: json['successful'] as bool,
  attempts: (json['attempts'] as num).toInt(),
  score: (json['score'] as num).toInt(),
  durationSeconds: (json['durationSeconds'] as num).toInt(),
  datePlayed: json['datePlayed'] as String?,
);

Map<String, dynamic> _$GameResultToJson(GameResult instance) =>
    <String, dynamic>{
      'recipeId': instance.recipeId,
      'recipeName': instance.recipeName,
      'successful': instance.successful,
      'attempts': instance.attempts,
      'score': instance.score,
      'durationSeconds': instance.durationSeconds,
      'datePlayed': instance.datePlayed,
    };

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
  unlocked: json['unlocked'] as bool? ?? false,
  unlockedDate: json['unlockedDate'] as String?,
);

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'unlocked': instance.unlocked,
      'unlockedDate': instance.unlockedDate,
    };
