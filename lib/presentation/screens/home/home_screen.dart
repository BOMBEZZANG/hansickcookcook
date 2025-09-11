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
import '../../widgets/common/category_chip.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../services/interstitial_ad_manager.dart';

/// Home screen displaying recipe grid
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showFilters = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = context.read<NavigationProvider>()
        .getScrollController(NavigationTab.home);
  }

  void _onSearchTap() {
    final navigationProvider = context.read<NavigationProvider>();
    navigationProvider.setTab(NavigationTab.search);
  }

  void _onBookmarkTap() {
    final navigationProvider = context.read<NavigationProvider>();
    navigationProvider.setTab(NavigationTab.bookmarks);
  }

  void _onGameTap() {
    print('🎮 Game icon clicked - attempting to show interstitial ad');
    // Show interstitial ad before showing game selection
    InterstitialAdManager.instance.showAdAndNavigate(
      onNavigate: () {
        print('🎮 Interstitial ad completed, showing game selection dialog');
        _showGameSelectionDialog();
      },
    );
  }

  void _onStatsTap() {
    print('📊 Statistics icon clicked - attempting to show interstitial ad');
    // Show interstitial ad before navigating to statistics
    InterstitialAdManager.instance.showAdAndNavigate(
      onNavigate: () {
        print('📊 Interstitial ad completed, navigating to statistics');
        Navigator.of(context).pushNamed('/statistics');
      },
    );
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _showGameSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<RecipeProvider>(
          builder: (context, recipeProvider, child) {
            return AlertDialog(
              title: const Text('게임 선택'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.shuffle, color: AppColors.primaryColor),
                    title: const Text('랜덤 레시피 게임'),
                    subtitle: const Text('무작위로 선택된 레시피로 게임을 시작합니다'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _startRandomGame(recipeProvider);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.category, color: AppColors.primaryColor),
                    title: const Text('카테고리별 게임'),
                    subtitle: const Text('원하는 분야의 레시피로 게임을 시작합니다'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showCategoryGameDialog(recipeProvider);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startRandomGame(RecipeProvider recipeProvider) {
    final availableRecipes = recipeProvider.allRecipes;
    if (availableRecipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('게임할 레시피가 없습니다'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final randomRecipe = availableRecipes[
      DateTime.now().millisecondsSinceEpoch % availableRecipes.length
    ];

    Navigator.of(context).pushNamed(
      '/game/step-order',
      arguments: randomRecipe,
    );
  }

  void _showCategoryGameDialog(RecipeProvider recipeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('카테고리 선택'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: recipeProvider.categories
                  .where((category) => category != AppStrings.allCategories)
                  .map((category) {
                final categoryRecipes = recipeProvider.allRecipes
                    .where((recipe) => recipe.category == category)
                    .toList();
                
                return ListTile(
                  title: Text(category),
                  subtitle: Text('${categoryRecipes.length}개 레시피'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).pop();
                    _startCategoryGame(category, categoryRecipes);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void _startCategoryGame(String category, List categoryRecipes) {
    if (categoryRecipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$category에 게임할 레시피가 없습니다'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final randomRecipe = categoryRecipes[
      DateTime.now().millisecondsSinceEpoch % categoryRecipes.length
    ];

    Navigator.of(context).pushNamed(
      '/game/step-order',
      arguments: randomRecipe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            if (_showFilters) _buildCategoryFilters(),
            Expanded(
              child: _buildRecipeGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        final masteredCount = recipeProvider.allRecipes
            .where((recipe) => recipe.masteryLevel >= 3)
            .length;
        
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First line: App Title
              Text(
                '한식조리기능사 실기 레시피',
                style: AppTextStyles.appBarTitle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Second line: 4 Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconButton(
                    icon: Icons.search,
                    label: '검색',
                    onTap: _onSearchTap,
                  ),
                  _buildIconButton(
                    icon: Icons.bookmark,
                    label: '즐겨찾기',
                    onTap: _onBookmarkTap,
                  ),
                  _buildIconButton(
                    icon: Icons.games,
                    label: '게임',
                    onTap: _onGameTap,
                  ),
                  _buildIconButton(
                    icon: Icons.analytics,
                    label: '통계',
                    onTap: _onStatsTap,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Third line: Progress Bar
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.amber[300],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$masteredCount/${recipeProvider.totalRecipeCount} 마스터',
                    style: AppTextStyles.progressText.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: recipeProvider.totalRecipeCount > 0
                          ? masteredCount / recipeProvider.totalRecipeCount
                          : 0.0,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.amber[300]!,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFilters ? 52 : 0,
      child: _showFilters 
        ? Consumer<RecipeProvider>(
            builder: (context, recipeProvider, child) {
              return CategoryFilterChips(
                categories: recipeProvider.categories,
                selectedCategory: recipeProvider.selectedCategory,
                onCategorySelected: recipeProvider.filterByCategory,
                showIcons: true,
              );
            },
          )
        : const SizedBox.shrink(),
    );
  }

  Widget _buildRecipeGrid() {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        if (recipeProvider.isLoading) {
          return const LoadingWidget(
            message: '레시피 로딩 중...',
          );
        }

        if (recipeProvider.error != null) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: '오류 발생',
            description: recipeProvider.error!,
            action: ElevatedButton(
              onPressed: recipeProvider.loadRecipes,
              child: const Text('다시 시도'),
            ),
          );
        }

        if (recipeProvider.recipes.isEmpty) {
          final isFiltered = recipeProvider.selectedCategory != AppStrings.allCategories;
          
          return EmptyStateWidget(
            icon: isFiltered ? Icons.filter_alt : Icons.restaurant_menu,
            title: isFiltered ? '해당 카테고리에 레시피가 없습니다' : '레시피가 없습니다',
            description: isFiltered 
                ? '다른 카테고리를 선택해보세요.'
                : '레시피 데이터를 불러올 수 없습니다.',
            action: isFiltered ? ElevatedButton(
              onPressed: () => recipeProvider.filterByCategory(AppStrings.allCategories),
              child: const Text('전체 보기'),
            ) : null,
          );
        }

        return _buildResponsiveGrid(recipeProvider.recipes);
      },
    );
  }

  Widget _buildResponsiveGrid(List recipes) {
    final columns = ResponsiveHelper.getGridColumns(context);
    final spacing = ResponsiveHelper.getGridSpacing(context);
    final padding = ResponsiveHelper.getScreenPadding(context);

    return Padding(
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - padding.horizontal,
        ),
        child: MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: columns,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: RecipeCard(
              key: ValueKey('recipe-${recipe.id}'),
              recipe: recipe,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.flashcard,
                  arguments: recipe,
                );
              },
            ),
          );
        },
        ),
      ),
    );
  }
}