import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/recipe.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../widgets/flashcard_content.dart';
import '../../widgets/ads/banner_ad_widget.dart';

/// Flashcard screen for recipe memorization
class FlashcardScreen extends StatefulWidget {
  final Recipe recipe;

  const FlashcardScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  bool _isCompleted = false;

  void _onComplete() {
    setState(() {
      _isCompleted = true;
    });
    
    // Show completion dialog
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.celebration,
              color: AppColors.progressBar,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('완료!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.recipe.name} 레시피를 완료했습니다!',
              style: AppTextStyles.stepText,
            ),
            const SizedBox(height: 16),
            const Text(
              '마스터리 레벨을 업데이트하시겠습니까?',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentLevel = widget.recipe.masteryLevel;
              final newLevel = (currentLevel + 1).clamp(0, 5);
              
              // Update mastery level
              context.read<RecipeProvider>()
                  .updateMasteryLevel(widget.recipe.id, newLevel);
              
              // Add study session to statistics (assuming 5 minutes study time)
              await context.read<StatisticsProvider>()
                  .addStudySession(widget.recipe.id, 5);
              
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('업데이트'),
          ),
        ],
      ),
    );
  }

  void _toggleBookmark() {
    context.read<RecipeProvider>().toggleBookmark(widget.recipe.id);
  }

  void _resetFlashcard() {
    setState(() {
      _isCompleted = false;
    });
  }

  void _startGame() {
    Navigator.of(context).pushNamed(
      '/game/step-order',
      arguments: widget.recipe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.recipe.name,
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: widget.recipe.categoryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<RecipeProvider>(
            builder: (context, provider, child) {
              final recipe = provider.getRecipeById(widget.recipe.id) ?? widget.recipe;
              
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    recipe.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    key: ValueKey(recipe.bookmarked),
                    color: recipe.bookmarked ? AppColors.bookmarkActive : Colors.white,
                  ),
                ),
                onPressed: _toggleBookmark,
                tooltip: recipe.bookmarked ? '즐겨찾기 제거' : '즐겨찾기 추가',
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'reset':
                  _resetFlashcard();
                  break;
                case 'ingredients':
                  _showIngredientsDialog();
                  break;
                case 'requirements':
                  _showRequirementsDialog();
                  break;
                case 'game':
                  _startGame();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.replay),
                    SizedBox(width: 8),
                    Text('처음부터'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'ingredients',
                child: Row(
                  children: [
                    Icon(Icons.restaurant),
                    SizedBox(width: 8),
                    Text('재료 보기'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'requirements',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('주의사항 보기'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'game',
                child: Row(
                  children: [
                    Icon(Icons.games),
                    SizedBox(width: 8),
                    Text('순서 맞추기 게임'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FlashcardContent(
        key: ValueKey(_isCompleted),
        recipe: widget.recipe,
        onComplete: _onComplete,
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }


  void _showIngredientsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('재료 (Ingredients)'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.recipe.ingredients.map((ingredient) {
              return Chip(
                label: Text(
                  ingredient,
                  style: AppTextStyles.chipText,
                ),
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showRequirementsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주의사항 (Requirements)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.recipe.requirements.map((requirement) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        requirement,
                        style: AppTextStyles.stepText,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}