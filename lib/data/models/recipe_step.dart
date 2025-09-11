import 'package:json_annotation/json_annotation.dart';

part 'recipe_step.g.dart';

@JsonSerializable()
class RecipeStep {
  final int order;
  final String description;
  final String? tip;
  final String? keyPoint; // NEW: Key memorization point
  final int? timeEstimate; // NEW: Minutes for this step

  RecipeStep({
    required this.order,
    required this.description,
    this.tip,
    this.keyPoint,
    this.timeEstimate,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) => 
      _$RecipeStepFromJson(json);
  
  Map<String, dynamic> toJson() => _$RecipeStepToJson(this);
  
  @override
  String toString() => 'RecipeStep(order: $order, description: $description)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeStep &&
        other.order == order &&
        other.description == description &&
        other.tip == tip;
  }
  
  @override
  int get hashCode => order.hashCode ^ description.hashCode ^ tip.hashCode;
}