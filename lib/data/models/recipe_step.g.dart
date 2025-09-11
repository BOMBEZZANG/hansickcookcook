// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeStep _$RecipeStepFromJson(Map<String, dynamic> json) => RecipeStep(
  order: (json['order'] as num).toInt(),
  description: json['description'] as String,
  tip: json['tip'] as String?,
  keyPoint: json['keyPoint'] as String?,
  timeEstimate: (json['timeEstimate'] as num?)?.toInt(),
);

Map<String, dynamic> _$RecipeStepToJson(RecipeStep instance) =>
    <String, dynamic>{
      'order': instance.order,
      'description': instance.description,
      'tip': instance.tip,
      'keyPoint': instance.keyPoint,
      'timeEstimate': instance.timeEstimate,
    };
