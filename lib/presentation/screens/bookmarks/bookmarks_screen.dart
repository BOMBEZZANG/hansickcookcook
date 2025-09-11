import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../routes/app_routes.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';

/// Bookmarks screen displaying favorited recipes
class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = context.read<NavigationProvider>()
        .getScrollController(NavigationTab.bookmarks);
  }

  void _removeAllBookmarks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 즐겨찾기 제거'),
        content: const Text('모든 즐겨찾기를 제거하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final recipeProvider = context.read<RecipeProvider>();
              final bookmarkedRecipes = recipeProvider.bookmarkedRecipes;
              
              // Remove all bookmarks
              for (final recipe in bookmarkedRecipes) {
                await recipeProvider.toggleBookmark(recipe.id);
              }
              
              Navigator.of(context).pop();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('모든 즐겨찾기가 제거되었습니다'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('제거', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildBookmarksList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          final bookmarkCount = recipeProvider.bookmarkedCount;
          
          return Row(
            children: [
              IconButton(
                onPressed: () {
                  context.read<NavigationProvider>().setTab(NavigationTab.home);
                },
                icon: const Icon(
                  Icons.home_rounded,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                tooltip: '홈으로',
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.bookmark,
                color: AppColors.bookmarkActive,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.bookmarks,
                      style: AppTextStyles.recipeNameMedium,
                    ),
                    Text(
                      '${bookmarkCount}개의 레시피',
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ],
                ),
              ),
              if (bookmarkCount > 0)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'clear_all':
                        _removeAllBookmarks();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all, color: Colors.red),
                          SizedBox(width: 8),
                          Text('모두 제거'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookmarksList() {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        if (recipeProvider.isLoading) {
          return const LoadingWidget(
            message: '즐겨찾기 로딩 중...',
          );
        }

        final bookmarkedRecipes = recipeProvider.bookmarkedRecipes;

        if (bookmarkedRecipes.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.bookmark_border,
            title: AppStrings.noBookmarks,
            description: '마음에 드는 레시피를 즐겨찾기에 추가해보세요.\n홈 화면에서 레시피 카드의 별 아이콘을 탭하면 됩니다.',
            action: ElevatedButton.icon(
              onPressed: () {
                final navigationProvider = context.read<NavigationProvider>();
                navigationProvider.setTab(NavigationTab.home);
              },
              icon: const Icon(Icons.home),
              label: const Text('홈으로 가기'),
            ),
          );
        }

        return _buildBookmarksGrid(bookmarkedRecipes);
      },
    );
  }

  Widget _buildBookmarksGrid(List bookmarkedRecipes) {
    final columns = ResponsiveHelper.getGridColumns(context);
    final spacing = ResponsiveHelper.getGridSpacing(context);
    final padding = ResponsiveHelper.getScreenPadding(context);

    return Padding(
      padding: padding,
      child: MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: columns,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        itemCount: bookmarkedRecipes.length,
        itemBuilder: (context, index) {
          final recipe = bookmarkedRecipes[index];
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: RecipeCard(
              key: ValueKey('bookmark-recipe-${recipe.id}'),
              recipe: recipe,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.fullRecipeView,
                  arguments: recipe,
                );
              },
              onLongPress: () {
                _showRemoveBookmarkDialog(recipe);
              },
            ),
          );
        },
      ),
    );
  }

  void _showRemoveBookmarkDialog(recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(recipe.categoryIcon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                recipe.name,
                style: AppTextStyles.cardTitle,
              ),
            ),
          ],
        ),
        content: const Text('이 레시피를 즐겨찾기에서 제거하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<RecipeProvider>().toggleBookmark(recipe.id);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${recipe.name}이(가) 즐겨찾기에서 제거되었습니다'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: '실행취소',
                    onPressed: () {
                      context.read<RecipeProvider>().toggleBookmark(recipe.id);
                    },
                  ),
                ),
              );
            },
            child: const Text('제거'),
          ),
        ],
      ),
    );
  }
}