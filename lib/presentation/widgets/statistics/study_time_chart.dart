import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/learning_statistics.dart';

class StudyTimeChart extends StatelessWidget {
  final LearningStatistics statistics;

  const StudyTimeChart({
    Key? key,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '일별 학습시간 (분)',
                  style: AppTextStyles.cardContent.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '최근 7일',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final weeklyData = _getWeeklyStudyData();
    
    if (weeklyData.every((data) => data.y == 0)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              '아직 학습 데이터가 없습니다',
              style: AppTextStyles.cardSubtitle,
            ),
            const SizedBox(height: 4),
            Text(
              '레시피를 학습하여 차트를 확인해보세요!',
              style: AppTextStyles.cardSubtitle.copyWith(
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(weeklyData),
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: AppColors.primaryColor,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dayName = _getDayName(group.x.toInt());
              final minutes = rod.toY.toInt();
              return BarTooltipItem(
                '$dayName\n${minutes}분',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getDayName(value.toInt()),
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getInterval(_getMaxY(weeklyData)),
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getInterval(_getMaxY(weeklyData)),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200]!,
              strokeWidth: 1,
            );
          },
        ),
        barGroups: weeklyData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.y,
                color: AppColors.primaryColor.withOpacity(0.8),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<FlSpot> _getWeeklyStudyData() {
    // Generate last 7 days of study data
    final now = DateTime.now();
    final weekData = <FlSpot>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Calculate study time for this day from game history
      var dayMinutes = 0.0;
      for (final game in statistics.gameHistory) {
        final gameDate = DateTime.parse(game.datePlayed);
        final gameDateKey = '${gameDate.year}-${gameDate.month.toString().padLeft(2, '0')}-${gameDate.day.toString().padLeft(2, '0')}';
        
        if (gameDateKey == dayKey) {
          dayMinutes += game.durationSeconds / 60.0;
        }
      }
      
      weekData.add(FlSpot((6 - i).toDouble(), dayMinutes));
    }
    
    return weekData;
  }

  double _getMaxY(List<FlSpot> data) {
    if (data.isEmpty) return 60;
    final maxValue = data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return 60;
    
    // Round up to next interval
    final interval = _getInterval(maxValue);
    return ((maxValue / interval).ceil() * interval).toDouble();
  }

  double _getInterval(double maxValue) {
    if (maxValue <= 30) return 10;
    if (maxValue <= 60) return 15;
    if (maxValue <= 120) return 30;
    if (maxValue <= 300) return 60;
    return 120;
  }

  String _getDayName(int index) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    final now = DateTime.now();
    final targetDay = now.subtract(Duration(days: 6 - index));
    return days[targetDay.weekday - 1];
  }
}