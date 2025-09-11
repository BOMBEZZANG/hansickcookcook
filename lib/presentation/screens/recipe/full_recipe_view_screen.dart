import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/recipe.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../widgets/ads/adaptive_banner_ad.dart';

/// Full recipe view screen showing all recipe information at once
class FullRecipeViewScreen extends StatefulWidget {
  final Recipe recipe;

  const FullRecipeViewScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  State<FullRecipeViewScreen> createState() => _FullRecipeViewScreenState();
}

class _FullRecipeViewScreenState extends State<FullRecipeViewScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Track this as a study session since user is viewing the recipe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>()
          .addStudySession(widget.recipe.id, 2); // 2 minutes for quick review
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    context.read<RecipeProvider>().toggleBookmark(widget.recipe.id);
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
                case 'game':
                  _startGame();
                  break;
              }
            },
            itemBuilder: (context) => [
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Header Info
                  _buildRecipeHeader(),
                  const SizedBox(height: 24),
                  
                  // Ingredients Section
                  _buildSection(
                    title: '재료 (Ingredients)',
                    icon: Icons.restaurant,
                    child: _buildIngredients(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Requirements Section
                  _buildSection(
                    title: '주의사항 (Requirements)',
                    icon: Icons.info_outline,
                    child: _buildRequirements(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Steps Section
                  _buildSection(
                    title: '조리 과정 (Steps)',
                    icon: Icons.format_list_numbered,
                    child: _buildSteps(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Tips Section
                  if (widget.recipe.tips.isNotEmpty) ...[
                    _buildSection(
                      title: '시험 팁 (Exam Tips)',
                      icon: Icons.lightbulb_outline,
                      child: _buildTips(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Common Mistakes Section
                  if (widget.recipe.commonMistakes.isNotEmpty) ...[
                    _buildSection(
                      title: '주의할 실수 (Common Mistakes)',
                      icon: Icons.warning_outlined,
                      child: _buildCommonMistakes(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
          // Fixed banner ad at bottom
          const AdaptiveBannerAd(
            isFloating: false,
            margin: EdgeInsets.all(0),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeHeader() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.recipe.categoryIcon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.name,
                        style: AppTextStyles.recipeNameLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.recipe.category,
                        style: AppTextStyles.cardSubtitle.copyWith(
                          color: widget.recipe.categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  Icons.schedule,
                  widget.recipe.examTimeFormatted,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  Icons.bar_chart,
                  '난이도 ${widget.recipe.difficulty}',
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                Consumer<RecipeProvider>(
                  builder: (context, provider, child) {
                    final recipe = provider.getRecipeById(widget.recipe.id) ?? widget.recipe;
                    return _buildInfoChip(
                      Icons.star,
                      '레벨 ${recipe.masteryLevel}',
                      Colors.amber,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.recipeNameMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildIngredients() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.recipe.ingredients.map((ingredient) {
            return Chip(
              label: Text(
                ingredient,
                style: AppTextStyles.chipText.copyWith(
                  color: Colors.black87,
                ),
              ),
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRequirements() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: widget.recipe.requirements.asMap().entries.map((entry) {
            final index = entry.key;
            final requirement = entry.value;
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < widget.recipe.requirements.length - 1 ? 12 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
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
    );
  }

  Widget _buildSteps() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: widget.recipe.steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < widget.recipe.steps.length - 1 ? 20 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${step.order}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.description,
                          style: AppTextStyles.stepText,
                        ),
                        if (step.tip != null && step.tip!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb_outline, 
                                     size: 16, color: Colors.blue[600]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    step.tip!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTips() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: widget.recipe.tips.asMap().entries.map((entry) {
            final index = entry.key;
            final tip = entry.value;
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < widget.recipe.tips.length - 1 ? 12 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber[600], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: AppTextStyles.stepText.copyWith(
                        color: Colors.amber[800],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCommonMistakes() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: widget.recipe.commonMistakes.asMap().entries.map((entry) {
            final index = entry.key;
            final mistake = entry.value;
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < widget.recipe.commonMistakes.length - 1 ? 12 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning, color: Colors.red[600], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mistake,
                      style: AppTextStyles.stepText.copyWith(
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}