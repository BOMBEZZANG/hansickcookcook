import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:ui';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/recipe.dart';
import '../../providers/game_provider.dart';
import '../../widgets/game/draggable_step_card.dart';
import '../../widgets/game/game_result_dialog.dart';
import '../../widgets/ads/banner_ad_widget.dart';

class StepOrderGameScreen extends StatefulWidget {
  final Recipe? recipe;

  const StepOrderGameScreen({Key? key, this.recipe}) : super(key: key);

  @override
  State<StepOrderGameScreen> createState() => _StepOrderGameScreenState();
}

class _StepOrderGameScreenState extends State<StepOrderGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Start game if recipe provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = context.read<GameProvider>();
      if (widget.recipe != null) {
        gameProvider.startGame(widget.recipe!);
      } else {
        gameProvider.startPracticeGame();
      }
      _updateProgress();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final gameProvider = context.read<GameProvider>();
    final progress = gameProvider.getProgressPercentage();
    _progressController.animateTo(progress);
  }

  void _onReorder(int oldIndex, int newIndex) {
    final gameProvider = context.read<GameProvider>();
    gameProvider.reorderSteps(oldIndex, newIndex);
    _updateProgress();

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _checkAnswer() async {
    final gameProvider = context.read<GameProvider>();
    final isCorrect = gameProvider.checkAnswer();

    if (isCorrect) {
      // Success animation
      _confettiController.play();
      HapticFeedback.heavyImpact();

      // Show success dialog after a short delay
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        _showResultDialog(true);
      }
    } else {
      // Failure animation
      _shakeController.reset();
      _shakeController.forward();
      HapticFeedback.heavyImpact();

      // Show failure dialog
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        _showResultDialog(false);
      }
    }
  }

  void _showResultDialog(bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
        success: success,
        onRetry: () {
          Navigator.of(context).pop();
          context.read<GameProvider>().resetGame();
          _updateProgress();
        },
        onNext: () {
          Navigator.of(context).pop();
          context.read<GameProvider>().nextRecipe();
          _updateProgress();
        },
        onHome: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        onShowAnswer: success
            ? null
            : () {
                Navigator.of(context).pop();
                context.read<GameProvider>().revealCorrectOrder();
                _updateProgress();
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: Stack(children: [_buildGameContent(), _buildConfetti()]),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      title: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final recipe = gameProvider.currentRecipe;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '순서 맞추기 게임',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (recipe != null)
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '시도: ${gameProvider.attempts}/3',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                Text(
                  '점수: ${gameProvider.score}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
              ],
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(8),
        child: Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressController.value,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[300]!),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final gameState = gameProvider.gameState;
        final steps = gameProvider.userOrderedSteps;

        if (gameState == GameState.ready) {
          return const Center(child: CircularProgressIndicator());
        }

        return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            final shake = _shakeAnimation.value;
            return Transform.translate(
              offset: Offset(shake * 10 * (1 - shake), 0),
              child: Column(
                children: [
                  _buildGameHeader(),
                  Expanded(child: _buildStepsList(steps)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final recipe = gameProvider.currentRecipe;
          if (recipe == null) return const SizedBox.shrink();

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        recipe.categoryIcon,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.name,
                              style: AppTextStyles.recipeNameLarge,
                            ),
                            Text(
                              '${recipe.category} • ${recipe.examTimeFormatted} • 난이도 ${recipe.difficulty}/5',
                              style: AppTextStyles.cardSubtitle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '왼쪽 손 모양(✋) 아이콘을 터치해서 카드를 올바른 순서로 배치하세요.',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepsList(List steps) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final originalSteps = gameProvider.originalSteps;
          final showCorrectness = gameProvider.gameState == GameState.failure;
          final showHints = gameProvider.showHints;

          return ReorderableListView.builder(
            onReorder: _onReorder,
            itemCount: steps.length,
            scrollController: ScrollController(),
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 8),
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) {
                  final double animValue = Curves.easeInOut.transform(
                    animation.value,
                  );
                  final double elevation = lerpDouble(0, 6, animValue)!;
                  final double scale = lerpDouble(1, 1.02, animValue)!;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: elevation,
                            offset: Offset(0, elevation / 2),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final step = steps[index];
              final isCorrect =
                  index < originalSteps.length &&
                  step.order == originalSteps[index].order;
              final hint = showHints
                  ? gameProvider.getHintForStep(index)
                  : null;

              return DraggableStepCard(
                key: ValueKey('step-${step.order}'),
                step: step,
                index: index,
                isCorrect: isCorrect,
                showCorrectness: showCorrectness,
                hint: hint,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final gameState = gameProvider.gameState;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BannerAdWidget(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Hint button
                    if (gameProvider.showHints)
                      IconButton(
                        onPressed: gameState == GameState.playing
                            ? gameProvider.toggleHints
                            : null,
                        icon: Icon(
                          gameProvider.showHints
                              ? Icons.lightbulb
                              : Icons.lightbulb_outline,
                          color: AppColors.primaryColor,
                        ),
                        tooltip: '힌트 토글',
                      ),

                    const Spacer(),

                    // Main action buttons
                    if (gameState == GameState.playing) ...[
                      OutlinedButton(
                        onPressed: () {
                          gameProvider.resetGame();
                          _updateProgress();
                        },
                        child: const Text('다시 섞기'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          '정답 확인',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ] else if (gameState == GameState.checking) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      const Text('답안 확인 중...'),
                    ],

                    const Spacer(),

                    // Settings button
                    IconButton(
                      onPressed: () => _showSettingsDialog(),
                      icon: const Icon(
                        Icons.settings,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: '게임 설정',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfetti() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: 3.14 / 2, // Down
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 50,
        gravity: 1,
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게임 설정'),
        content: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('힌트 표시'),
                  subtitle: const Text('단계별 힌트를 표시합니다'),
                  value: gameProvider.showHints,
                  onChanged: (_) => gameProvider.toggleHints(),
                ),
                SwitchListTile(
                  title: const Text('진동 피드백'),
                  subtitle: const Text('드래그 시 진동을 제공합니다'),
                  value: gameProvider.enableHapticFeedback,
                  onChanged: (_) => gameProvider.toggleHapticFeedback(),
                ),
              ],
            );
          },
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
