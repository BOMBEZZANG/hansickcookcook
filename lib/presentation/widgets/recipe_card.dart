import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/recipe.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_animations.dart';
import '../../routes/app_routes.dart';
import '../providers/recipe_provider.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const RecipeCard({
    Key? key,
    required this.recipe,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bookmarkRotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.defaultCurve,
    ));
    
    _bookmarkRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.bounceCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  void _onTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Navigator.of(context).pushNamed(
        AppRoutes.flashcard,
        arguments: widget.recipe,
      );
    }
  }

  void _onBookmarkTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    context.read<RecipeProvider>().toggleBookmark(widget.recipe.id);
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _QuickActionsSheet(recipe: widget.recipe),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = widget.recipe.categoryColor;
    final categoryIcon = widget.recipe.categoryIcon;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Hero(
            tag: 'recipe-${widget.recipe.id}',
            child: Card(
              margin: const EdgeInsets.all(4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: AppColors.cardShadow,
              child: Material(
                color: categoryColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _onTap,
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  onLongPress: widget.onLongPress ?? _showQuickActions,
                  borderRadius: BorderRadius.circular(12),
                  splashColor: categoryColor.withOpacity(0.2),
                  highlightColor: categoryColor.withOpacity(0.1),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(
                      minHeight: 140,
                      minWidth: 120,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Category Icon (Top)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Text(
                            categoryIcon,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        
                        // Recipe Name (Middle)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              widget.recipe.name,
                              style: AppTextStyles.cardTitle.copyWith(
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        
                        // Bottom Row (Time and Bookmark)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Exam Time
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.recipe.examTimeFormatted,
                                  style: AppTextStyles.cardSubtitle.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Bookmark Button
                            Transform.rotate(
                              angle: _bookmarkRotationAnimation.value,
                              child: GestureDetector(
                                onTap: _onBookmarkTap,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: AnimatedSwitcher(
                                    duration: AppAnimations.shortAnimation,
                                    child: Icon(
                                      widget.recipe.bookmarked
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      key: ValueKey(widget.recipe.bookmarked),
                                      size: 20,
                                      color: widget.recipe.bookmarked
                                          ? AppColors.bookmarkActive
                                          : Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Optional: Mastery Level Progress Bar
                        if (widget.recipe.masteryLevel > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1.5),
                              color: Colors.white.withOpacity(0.3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: widget.recipe.masteryLevel / 5.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1.5),
                                  color: AppColors.progressBar,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionsSheet extends StatelessWidget {
  final Recipe recipe;
  
  const _QuickActionsSheet({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Recipe info
          Row(
            children: [
              Text(
                recipe.categoryIcon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: AppTextStyles.cardTitle,
                    ),
                    Text(
                      '${recipe.category} • ${recipe.examTimeFormatted}',
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Actions
          ListTile(
            leading: Icon(
              recipe.bookmarked ? Icons.bookmark_remove : Icons.bookmark_add,
              color: AppColors.primaryColor,
            ),
            title: Text(
              recipe.bookmarked ? '즐겨찾기 제거' : '즐겨찾기 추가',
            ),
            onTap: () {
              context.read<RecipeProvider>().toggleBookmark(recipe.id);
              Navigator.of(context).pop();
            },
          ),
          
          ListTile(
            leading: const Icon(
              Icons.games,
              color: AppColors.primaryColor,
            ),
            title: const Text('순서 맞추기 게임'),
            subtitle: Text('${recipe.steps.length}단계 요리순서 게임'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(
                '/game/step-order',
                arguments: recipe,
              );
            },
          ),
          
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: AppColors.primaryColor,
            ),
            title: const Text('레시피 정보'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(
                AppRoutes.flashcard,
                arguments: recipe,
              );
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}