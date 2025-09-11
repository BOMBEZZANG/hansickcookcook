import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import 'recipe_step.dart';

part 'recipe.g.dart';

@JsonSerializable()
class Recipe {
  final int id;
  final String name;
  final String category;
  final int examTime;
  final int difficulty; // NEW: 1-5 scale
  final List<String> ingredients;
  final List<String> requirements;
  final List<RecipeStep> steps;
  final List<String> tips; // NEW: Exam tips
  final List<String> commonMistakes; // NEW: Common mistakes
  bool bookmarked;
  int masteryLevel;

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.examTime,
    required this.difficulty,
    required this.ingredients,
    required this.requirements,
    required this.steps,
    required this.tips,
    required this.commonMistakes,
    this.bookmarked = false,
    this.masteryLevel = 0,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);

  // Helper getters
  String get categoryIcon => AppConstants.getCategoryIcon(category);
  Color get categoryColor => AppColors.getCategoryColor(category);
  String get examTimeFormatted => '$examTime분';
  
  // Copy with method for updating mutable fields
  Recipe copyWith({
    bool? bookmarked,
    int? masteryLevel,
  }) {
    return Recipe(
      id: id,
      name: name,
      category: category,
      examTime: examTime,
      difficulty: difficulty,
      ingredients: ingredients,
      requirements: requirements,
      steps: steps,
      tips: tips,
      commonMistakes: commonMistakes,
      bookmarked: bookmarked ?? this.bookmarked,
      masteryLevel: masteryLevel ?? this.masteryLevel,
    );
  }
  
  @override
  String toString() => 'Recipe(id: $id, name: $name, category: $category)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe &&
        other.id == id &&
        other.name == name &&
        other.category == category;
  }
  
  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ category.hashCode;
}