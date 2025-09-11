import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/learning_statistics.dart';
import '../../providers/statistics_provider.dart';
import '../../widgets/statistics/study_time_chart.dart';
import '../../widgets/statistics/mastery_progress_chart.dart';
import '../../widgets/statistics/achievement_grid.dart';
import '../../widgets/statistics/recent_activity_list.dart';
import '../../widgets/statistics/statistics_card.dart';
import '../../widgets/ads/adaptive_banner_ad.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          '학습 통계',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.backgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.cardContent.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: AppTextStyles.cardContent,
          indicatorColor: AppColors.primaryColor,
          tabs: const [
            Tab(text: '개요'),
            Tab(text: '상세'),
            Tab(text: '성취'),
          ],
        ),
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, statisticsProvider, child) {
          return Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(statisticsProvider),
                    _buildDetailTab(statisticsProvider),
                    _buildAchievementTab(statisticsProvider),
                  ],
                ),
              ),
              // Fixed banner ad at bottom
              const AdaptiveBannerAd(
                isFloating: false,
                margin: EdgeInsets.all(0),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(StatisticsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Cards
          _buildQuickStats(provider),
          const SizedBox(height: 24),
          
          // Study Time Chart
          _buildSectionTitle('주간 학습 시간'),
          const SizedBox(height: 16),
          StudyTimeChart(statistics: provider.statistics),
          const SizedBox(height: 24),
          
          // Mastery Progress
          _buildSectionTitle('숙달도 현황'),
          const SizedBox(height: 16),
          MasteryProgressChart(statistics: provider.statistics),
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildSectionTitle('최근 활동'),
          const SizedBox(height: 16),
          RecentActivityList(
            gameResults: provider.statistics.gameHistory.take(5).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailTab(StatisticsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Detailed Statistics Cards
          _buildDetailedStats(provider),
          const SizedBox(height: 24),
          
          // Category Breakdown
          _buildSectionTitle('분야별 학습 현황'),
          const SizedBox(height: 16),
          _buildCategoryBreakdown(provider),
          const SizedBox(height: 24),
          
          // Streak Information
          _buildSectionTitle('연속 학습'),
          const SizedBox(height: 16),
          _buildStreakInfo(provider),
          const SizedBox(height: 24),
          
          // Game Performance
          _buildSectionTitle('게임 성과'),
          const SizedBox(height: 16),
          _buildGamePerformance(provider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAchievementTab(StatisticsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Achievement Grid
          _buildSectionTitle('획득한 성취'),
          const SizedBox(height: 16),
          AchievementGrid(
            achievements: provider.unlockedAchievements,
            allAchievements: provider.allAchievements,
          ),
          const SizedBox(height: 24),
          
          // Progress to Next Achievements
          _buildSectionTitle('진행 중인 성취'),
          const SizedBox(height: 16),
          _buildProgressAchievements(provider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuickStats(StatisticsProvider provider) {
    final stats = provider.statistics;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatisticsCard(
                title: '총 학습시간',
                value: _formatStudyTime(stats.totalStudyTime),
                icon: Icons.schedule,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatisticsCard(
                title: '학습한 레시피',
                value: '${stats.recipesStudied}개',
                icon: Icons.book,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatisticsCard(
                title: '숙달한 레시피',
                value: '${stats.recipesMastered}개',
                icon: Icons.star,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatisticsCard(
                title: '현재 연속기록',
                value: '${stats.currentStreak}일',
                icon: Icons.local_fire_department,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailedStats(StatisticsProvider provider) {
    final stats = provider.statistics;
    
    return Column(
      children: [
        StatisticsCard(
          title: '평균 게임 점수',
          value: stats.gameHistory.isNotEmpty
              ? '${_calculateAverageScore(stats.gameHistory).toStringAsFixed(1)}점'
              : '0점',
          icon: Icons.trending_up,
          color: Colors.purple,
          subtitle: '총 ${stats.gameHistory.length}번의 게임',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatisticsCard(
                title: '최장 연속기록',
                value: '${stats.longestStreak}일',
                icon: Icons.emoji_events,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatisticsCard(
                title: '평균 학습시간',
                value: stats.recipesStudied > 0
                    ? _formatStudyTime(stats.totalStudyTime ~/ stats.recipesStudied)
                    : '0분',
                icon: Icons.timer,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(StatisticsProvider provider) {
    final categoryStats = provider.getCategoryStats();
    
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: categoryStats.entries.map((entry) {
            final category = entry.key;
            final studyCount = entry.value;
            final maxCount = categoryStats.values.isEmpty 
                ? 1 
                : categoryStats.values.reduce((a, b) => a > b ? a : b);
            final progress = _calculateSafeProgress(studyCount, maxCount);
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: AppTextStyles.cardContent.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${studyCount}회',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor.withOpacity(0.8),
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

  Widget _buildStreakInfo(StatisticsProvider provider) {
    final stats = provider.statistics;
    
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: stats.currentStreak > 0 ? Colors.orange[100] : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    size: 30,
                    color: stats.currentStreak > 0 ? Colors.orange[600] : Colors.grey[400],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats.currentStreak}일 연속 학습',
                        style: AppTextStyles.cardContent.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '최고 기록: ${stats.longestStreak}일',
                        style: AppTextStyles.cardSubtitle,
                      ),
                      if (stats.currentStreak > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '훌륭해요! 계속 이어가세요 🔥',
                          style: AppTextStyles.cardSubtitle.copyWith(
                            color: Colors.orange[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamePerformance(StatisticsProvider provider) {
    final gameHistory = provider.statistics.gameHistory;
    
    if (gameHistory.isEmpty) {
      return Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.games,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                '아직 게임을 플레이하지 않았습니다',
                style: AppTextStyles.cardContent,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '게임을 플레이하여 통계를 확인해보세요!',
                style: AppTextStyles.cardSubtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final successCount = gameHistory.where((game) => game.successful).length;
    final successRate = (successCount / gameHistory.length * 100);
    final averageScore = _calculateAverageScore(gameHistory);

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '성공률',
                        style: AppTextStyles.cardSubtitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${successRate.toStringAsFixed(1)}%',
                        style: AppTextStyles.cardContent.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '평균 점수',
                        style: AppTextStyles.cardSubtitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${averageScore.toStringAsFixed(1)}점',
                        style: AppTextStyles.cardContent.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '총 게임',
                        style: AppTextStyles.cardSubtitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${gameHistory.length}회',
                        style: AppTextStyles.cardContent.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressAchievements(StatisticsProvider provider) {
    final progressAchievements = provider.getProgressAchievements();
    
    if (progressAchievements.isEmpty) {
      return Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green[400],
              ),
              const SizedBox(height: 12),
              Text(
                '모든 성취를 달성했습니다!',
                style: AppTextStyles.cardContent.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: progressAchievements.map((achievement) {
        final progress = provider.getAchievementProgress(achievement);
        
        return Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: AppTextStyles.cardContent.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: AppTextStyles.cardSubtitle,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _validateProgress(progress),
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(_validateProgress(progress) * 100).toInt()}% 완료',
                        style: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.recipeNameLarge.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatStudyTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}분';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}시간';
      } else {
        return '${hours}시간 ${remainingMinutes}분';
      }
    }
  }

  double _calculateAverageScore(List<GameResult> gameHistory) {
    if (gameHistory.isEmpty) return 0.0;
    
    final totalScore = gameHistory.fold<double>(
      0.0,
      (sum, game) => sum + game.score.toDouble(),
    );
    
    return totalScore / gameHistory.length;
  }

  double _calculateSafeProgress(num studyCount, num maxCount) {
    // Handle edge cases that could cause NaN or Infinity
    if (maxCount <= 0 || studyCount < 0) {
      return 0.0;
    }
    
    final progress = studyCount / maxCount;
    
    // Ensure the result is finite and within valid range
    if (!progress.isFinite) {
      return 0.0;
    }
    
    // Clamp between 0.0 and 1.0 for LinearProgressIndicator
    return progress.clamp(0.0, 1.0);
  }

  double _validateProgress(double progress) {
    // Ensure the progress value is valid for LinearProgressIndicator
    if (!progress.isFinite) {
      return 0.0;
    }
    
    // Clamp between 0.0 and 1.0
    return progress.clamp(0.0, 1.0);
  }
}