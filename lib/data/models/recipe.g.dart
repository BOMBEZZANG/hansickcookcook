// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  category: json['category'] as String,
  examTime: (json['examTime'] as num).toInt(),
  difficulty: (json['difficulty'] as num).toInt(),
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requirements: (json['requirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  steps: (json['steps'] as List<dynamic>)
      .map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
      .toList(),
  tips: (json['tips'] as List<dynamic>).map((e) => e as String).toList(),
  commonMistakes: (json['commonMistakes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  bookmarked: json['bookmarked'] as bool? ?? false,
  masteryLevel: (json['masteryLevel'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'examTime': instance.examTime,
  'difficulty': instance.difficulty,
  'ingredients': instance.ingredients,
  'requirements': instance.requirements,
  'steps': instance.steps,
  'tips': instance.tips,
  'commonMistakes': instance.commonMistakes,
  'bookmarked': instance.bookmarked,
  'masteryLevel': instance.masteryLevel,
};
