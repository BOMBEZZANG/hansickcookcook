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

/// Search screen for finding recipes
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  String _currentQuery = '';
  NavigationProvider? _navigationProvider;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = context.read<NavigationProvider>()
        .getScrollController(NavigationTab.search);
    
    // Restore previous search query if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigationProvider = context.read<NavigationProvider>();
      final savedQuery = navigationProvider.getSearchScreenQuery();
      if (savedQuery.isNotEmpty) {
        _searchController.text = savedQuery;
        _currentQuery = savedQuery;
        context.read<RecipeProvider>().searchRecipes(savedQuery);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to NavigationProvider for safe access in dispose
    _navigationProvider ??= context.read<NavigationProvider>();
  }

  @override
  void dispose() {
    // Save search query for state preservation using saved reference
    _navigationProvider?.saveSearchScreenQuery(_currentQuery);
    
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentQuery = query;
    });
    
    final recipeProvider = context.read<RecipeProvider>();
    recipeProvider.searchRecipes(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.search,
                  style: AppTextStyles.recipeNameMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: AppStrings.searchHint,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              suffixIcon: _currentQuery.isNotEmpty
                  ? IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            textInputAction: TextInputAction.search,
          ),
          if (_currentQuery.isNotEmpty) ...[
            const SizedBox(height: 12),
            Consumer<RecipeProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\'$_currentQuery\'에 대한 검색 결과: ${provider.displayedRecipeCount}개',
                      style: AppTextStyles.cardSubtitle,
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          if (_currentQuery.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.search,
              title: '검색어를 입력하세요',
              description: '레시피 이름, 재료, 카테고리로 검색할 수 있습니다.',
            );
          }

          if (recipeProvider.isLoading) {
            return const LoadingWidget(
              message: '검색 중...',
            );
          }

          if (recipeProvider.recipes.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.search_off,
              title: AppStrings.noSearchResults,
              description: '다른 검색어를 시도해보세요.\n레시피 이름, 재료, 카테고리로 검색 가능합니다.',
              action: ElevatedButton(
                onPressed: _clearSearch,
                child: const Text(AppStrings.clearSearch),
              ),
            );
          }

          return _buildSearchGrid(recipeProvider.recipes);
        },
      ),
    );
  }

  Widget _buildSearchGrid(List recipes) {
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
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: RecipeCard(
              key: ValueKey('search-recipe-${recipe.id}'),
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
    );
  }
}