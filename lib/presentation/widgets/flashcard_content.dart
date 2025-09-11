import 'package:flutter/material.dart';
import '../../data/models/recipe.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_animations.dart';

enum FlashcardState {
  overview,
  ingredients,
  requirements,
  steps,
}

class FlashcardContent extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback? onComplete;
  
  const FlashcardContent({
    Key? key,
    required this.recipe,
    this.onComplete,
  }) : super(key: key);

  @override
  State<FlashcardContent> createState() => _FlashcardContentState();
}

class _FlashcardContentState extends State<FlashcardContent>
    with TickerProviderStateMixin {
  FlashcardState _currentState = FlashcardState.overview;
  int _currentStepIndex = 0;
  List<int> _visibleSteps = [];
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    
    _scrollController = ScrollController();
    
    _fadeController = AnimationController(
      duration: AppAnimations.shortAnimation,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppAnimations.mediumAnimation,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.fadeInCurve,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.slideInCurve,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTap() {
    // Only handle step progression when already showing steps
    if (_currentState == FlashcardState.steps) {
      _showNextStep();
    }
    // Don't handle overview tap here - let the TAP TO START button handle it
  }

  void _setState(FlashcardState newState) {
    if (_currentState != newState) {
      _fadeController.reverse().then((_) {
        setState(() {
          _currentState = newState;
          if (newState == FlashcardState.steps) {
            _visibleSteps = [0];
            _currentStepIndex = 0;
          }
        });
        _fadeController.forward().then((_) {
          // Auto-scroll to top when entering steps
          if (newState == FlashcardState.steps) {
            _scrollToTop();
          }
        });
      });
    }
  }

  void _showNextStep() {
    if (_currentStepIndex < widget.recipe.steps.length - 1) {
      _slideController.forward().then((_) {
        setState(() {
          _currentStepIndex++;
          _visibleSteps.add(_currentStepIndex);
        });
        _slideController.reset();
        // Auto-scroll down to show the new step
        _scrollToNewStep();
      });
    } else if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  void _resetSteps() {
    _fadeController.reverse().then((_) {
      setState(() {
        _currentState = FlashcardState.overview;
        _currentStepIndex = 0;
        _visibleSteps.clear();
      });
      _fadeController.forward();
    });
  }

  // Auto-scroll to top of content
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Auto-scroll to show new step
  void _scrollToNewStep() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        final viewportHeight = _scrollController.position.viewportDimension;
        
        // Calculate scroll position to show the new step
        final targetScroll = (currentScroll + viewportHeight * 0.3).clamp(0.0, maxScroll);
        
        _scrollController.animateTo(
          targetScroll,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  // Show ingredients modal
  void _showIngredientsModal() {
    showDialog(
      context: context,
      builder: (context) => _IngredientDialog(recipe: widget.recipe),
    );
  }

  // Show requirements modal
  void _showRequirementsModal() {
    showDialog(
      context: context,
      builder: (context) => _RequirementDialog(recipe: widget.recipe),
    );
  }

  // Start showing steps inline
  void _startSteps() {
    setState(() {
      _currentState = FlashcardState.steps;
      _visibleSteps = [0];
      _currentStepIndex = 0;
    });
    
    // Auto-scroll to show the steps section
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSteps();
    });
  }

  // Collapse steps back to overview
  void _collapseSteps() {
    setState(() {
      _currentState = FlashcardState.overview;
      _visibleSteps.clear();
      _currentStepIndex = 0;
    });
    
    // Auto-scroll back to top
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTop();
    });
  }

  // Scroll to steps section
  void _scrollToSteps() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent * 0.7, // Scroll to about 70% down
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: _buildCurrentContent(),
          ),
        ),
      );
  }

  Widget _buildCurrentContent() {
    switch (_currentState) {
      case FlashcardState.overview:
        return _buildOverviewContent();
      case FlashcardState.ingredients:
        return _buildIngredientsContent();
      case FlashcardState.requirements:
        return _buildRequirementsContent();
      case FlashcardState.steps:
        return _buildOverviewWithSteps();
    }
  }

  Widget _buildOverviewWithSteps() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildOverviewContent(),
        const SizedBox(height: 32),
        _buildStepsContent(),
      ],
    );
  }

  Widget _buildOverviewContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.recipe.categoryIcon,
          style: const TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 16),
        Text(
          widget.recipe.name,
          style: AppTextStyles.recipeNameLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 1,
          color: AppColors.divider,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              Icons.access_time,
              '시험시간',
              widget.recipe.examTimeFormatted,
            ),
            _buildInfoItem(
              Icons.restaurant,
              '카테고리',
              widget.recipe.category,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildClickableInfoItem(
              Icons.restaurant_menu,
              '재료',
              '${widget.recipe.ingredients.length}개',
              () => _showIngredientsModal(),
            ),
            _buildClickableInfoItem(
              Icons.checklist,
              '요구사항',
              '${widget.recipe.requirements.length}개',
              () => _showRequirementsModal(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 1,
          color: AppColors.divider,
        ),
        const SizedBox(height: 20),
        // Only show TAP TO START button when not in steps mode
        if (_currentState == FlashcardState.overview)
          GestureDetector(
            onTap: _startSteps,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TAP TO START',
                    style: AppTextStyles.progressText.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.cardSubtitle,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.cardTitle,
        ),
      ],
    );
  }

  Widget _buildClickableInfoItem(IconData icon, String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.cardSubtitle,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.cardTitle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '재료 (Ingredients)',
          style: AppTextStyles.recipeNameMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.recipe.ingredients.map((ingredient) {
            return Chip(
              label: Text(
                ingredient,
                style: AppTextStyles.chipText.copyWith(
                  color: Colors.black,
                ),
              ),
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRequirementsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '요구사항 (Requirements)',
          style: AppTextStyles.recipeNameMedium,
        ),
        const SizedBox(height: 16),
        ...widget.recipe.requirements.map((requirement) {
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
      ],
    );
  }

  Widget _buildStepsContent() {
    return GestureDetector(
      onTap: _onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${_currentStepIndex + 1} of ${widget.recipe.steps.length}',
              style: AppTextStyles.stepNumber,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_currentStepIndex == widget.recipe.steps.length - 1)
                  Icon(
                    Icons.celebration,
                    color: AppColors.progressBar,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                // Collapse button
                GestureDetector(
                  onTap: _collapseSteps,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 20),
        
        // Visible steps
        ...widget.recipe.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          
          if (!_visibleSteps.contains(index)) {
            return const SizedBox.shrink();
          }
          
          final isLatest = index == _currentStepIndex;
          
          return SlideTransition(
            position: isLatest ? _slideAnimation : 
                Tween<Offset>(begin: Offset.zero, end: Offset.zero)
                    .animate(_slideController),
            child: FadeTransition(
              opacity: isLatest ? _fadeAnimation :
                  Tween<double>(begin: 1.0, end: 1.0)
                      .animate(_fadeController),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLatest 
                      ? AppColors.primaryColor.withOpacity(0.05)
                      : AppColors.backgroundColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLatest 
                        ? AppColors.primaryColor.withOpacity(0.3)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${step.order}단계',
                      style: AppTextStyles.stepNumber.copyWith(
                        color: isLatest 
                            ? AppColors.primaryColor 
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.description,
                      style: AppTextStyles.stepText.copyWith(
                        color: isLatest 
                            ? AppColors.textPrimary 
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        
        if (_currentStepIndex < widget.recipe.steps.length - 1) ...[
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: AppColors.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap anywhere to continue',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ],
      ),
    );
  }
}

// Ingredient Dialog
class _IngredientDialog extends StatelessWidget {
  final Recipe recipe;
  
  const _IngredientDialog({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '재료 (Ingredients)',
                    style: AppTextStyles.recipeNameMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              recipe.name,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Ingredients List
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recipe.ingredients.map((ingredient) {
                    return Chip(
                      label: Text(
                        ingredient,
                        style: AppTextStyles.chipText.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      side: BorderSide(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Requirements Dialog
class _RequirementDialog extends StatelessWidget {
  final Recipe recipe;
  
  const _RequirementDialog({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.checklist,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '요구사항 (Requirements)',
                    style: AppTextStyles.recipeNameMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              recipe.name,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Requirements List
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recipe.requirements.map((requirement) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 8, right: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              requirement,
                              style: AppTextStyles.cardContent.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}