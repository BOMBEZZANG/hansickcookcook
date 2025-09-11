import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/game_provider.dart';

class GameResultDialog extends StatefulWidget {
  final bool success;
  final VoidCallback onRetry;
  final VoidCallback onNext;
  final VoidCallback onHome;
  final VoidCallback? onShowAnswer;
  
  const GameResultDialog({
    Key? key,
    required this.success,
    required this.onRetry,
    required this.onNext,
    required this.onHome,
    this.onShowAnswer,
  }) : super(key: key);

  @override
  State<GameResultDialog> createState() => _GameResultDialogState();
}

class _GameResultDialogState extends State<GameResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: widget.success
                        ? [Colors.green[50]!, Colors.white]
                        : [Colors.red[50]!, Colors.white],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildContent(),
                    const SizedBox(height: 20),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.success ? Colors.green[400] : Colors.red[400],
            boxShadow: [
              BoxShadow(
                color: (widget.success ? Colors.green : Colors.red).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            widget.success ? Icons.check_circle : Icons.close,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.success ? '정답입니다! 🎉' : '다시 도전하세요',
          style: AppTextStyles.recipeNameLarge.copyWith(
            color: widget.success ? Colors.green[700] : Colors.red[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildContent() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (widget.success) {
          return _buildSuccessContent(gameProvider);
        } else {
          return _buildFailureContent(gameProvider);
        }
      },
    );
  }
  
  Widget _buildSuccessContent(GameProvider gameProvider) {
    return Column(
      children: [
        Text(
          '완벽하게 순서를 맞추셨습니다!',
          style: AppTextStyles.cardContent.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '시도 횟수:',
                    style: AppTextStyles.cardSubtitle,
                  ),
                  Text(
                    '${gameProvider.attempts}회',
                    style: AppTextStyles.cardContent.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '획득 점수:',
                    style: AppTextStyles.cardSubtitle,
                  ),
                  Text(
                    '${gameProvider.score}점',
                    style: AppTextStyles.cardContent.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '소요 시간:',
                    style: AppTextStyles.cardSubtitle,
                  ),
                  Text(
                    _formatDuration(gameProvider.gameDuration),
                    style: AppTextStyles.cardContent.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFailureContent(GameProvider gameProvider) {
    final incorrectIndices = gameProvider.getIncorrectStepIndices();
    
    return Column(
      children: [
        Text(
          gameProvider.attempts >= 3
              ? '3번의 시도를 모두 사용하셨습니다.'
              : '일부 단계의 순서가 잘못되었습니다.',
          style: AppTextStyles.cardContent.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (incorrectIndices.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '틀린 위치:',
                  style: AppTextStyles.cardSubtitle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: incorrectIndices.map((index) {
                    return Chip(
                      label: Text('${index + 1}번째'),
                      backgroundColor: Colors.red[50],
                      side: BorderSide(color: Colors.red[300]!),
                      labelStyle: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (gameProvider.attempts < 3)
          Text(
            '남은 시도: ${3 - gameProvider.attempts}회',
            style: AppTextStyles.cardSubtitle.copyWith(
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
  
  Widget _buildActions() {
    if (widget.success) {
      return _buildSuccessActions();
    } else {
      return _buildFailureActions();
    }
  }
  
  Widget _buildSuccessActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onRetry,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.green[400]!),
                  foregroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('다시 하기'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('다음 레시피'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: widget.onHome,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('홈으로 가기'),
        ),
      ],
    );
  }
  
  Widget _buildFailureActions() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final canRetry = gameProvider.attempts < 3;
        
        return Column(
          children: [
            if (canRetry) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onRetry,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryColor),
                        foregroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('다시 시도'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (widget.onShowAnswer != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onShowAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('정답 보기'),
                      ),
                    ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('다른 레시피'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (widget.onShowAnswer != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onShowAnswer,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange[400]!),
                          foregroundColor: Colors.orange[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('정답 보기'),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.onHome,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('홈으로 가기'),
            ),
          ],
        );
      },
    );
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}분 ${seconds}초';
    } else {
      return '${seconds}초';
    }
  }
}