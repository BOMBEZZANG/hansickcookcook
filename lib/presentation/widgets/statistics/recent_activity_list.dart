import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/learning_statistics.dart';

class RecentActivityList extends StatelessWidget {
  final List<GameResult> gameResults;

  const RecentActivityList({
    Key? key,
    required this.gameResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 활동',
                  style: AppTextStyles.cardContent.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (gameResults.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      // Navigate to full activity list
                    },
                    child: Text(
                      '전체 보기',
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (gameResults.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '아직 활동 기록이 없습니다',
                      style: AppTextStyles.cardSubtitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '게임을 플레이하여 활동을 시작해보세요!',
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: gameResults.map((result) => _buildActivityItem(result)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(GameResult result) {
    final date = DateTime.parse(result.datePlayed);
    final timeAgo = _getTimeAgo(date);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[100]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: result.successful
                  ? Colors.green[100]
                  : Colors.red[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              result.successful ? Icons.check : Icons.close,
              color: result.successful
                  ? Colors.green[600]
                  : Colors.red[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.recipeName,
                  style: AppTextStyles.cardContent.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      result.successful ? '성공' : '실패',
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: result.successful
                            ? Colors.green[600]
                            : Colors.red[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' • ${result.score}점',
                      style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                    ),
                    if (result.attempts > 1) ...[
                      Text(
                        ' • ${result.attempts}번째 시도',
                        style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeAgo,
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDuration(Duration(seconds: result.durationSeconds)),
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}분${seconds > 0 ? ' ${seconds}초' : ''}';
    } else {
      return '${seconds}초';
    }
  }
}