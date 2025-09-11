import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_constants.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showIcon;
  
  const CategoryChip({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.showIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getCategoryColor(category);
    
    return AnimatedContainer(
      duration: AppAnimations.shortAnimation,
      curve: AppAnimations.defaultCurve,
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: color.withOpacity(0.2),
          child: AnimatedContainer(
            duration: AppAnimations.shortAnimation,
            curve: AppAnimations.defaultCurve,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcon && category != '전체') ...[
                  Text(
                    AppConstants.getCategoryIcon(category),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  category,
                  style: isSelected 
                    ? AppTextStyles.chipTextSelected
                    : AppTextStyles.chipText.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final bool showIcons;
  
  const CategoryFilterChips({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.showIcons = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryChip(
            category: category,
            isSelected: category == selectedCategory,
            onTap: () => onCategorySelected(category),
            showIcon: showIcons,
          );
        },
      ),
    );
  }
}