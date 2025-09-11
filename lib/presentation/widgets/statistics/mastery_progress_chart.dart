import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/learning_statistics.dart';

class MasteryProgressChart extends StatelessWidget {
  final LearningStatistics statistics;

  const MasteryProgressChart({
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
            Text(
              '숙달도 분포',
              style: AppTextStyles.cardContent.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildChart(context),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final masteryData = _getMasteryDistribution();
    
    if (masteryData.every((section) => section.value == 0)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              '아직 학습 데이터가 없습니다',
              style: AppTextStyles.cardSubtitle,
            ),
          ],
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: masteryData,
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        startDegreeOffset: 270,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Handle touch events if needed
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final colors = [
      Colors.red[400]!,
      Colors.orange[400]!,
      Colors.yellow[600]!,
      Colors.lightGreen[400]!,
      Colors.green[500]!,
    ];
    
    final labels = ['레벨 0', '레벨 1', '레벨 2', '레벨 3', '레벨 4'];
    final counts = _getMasteryCounts();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: List.generate(5, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${labels[index]} (${counts[index]})',
              style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
            ),
          ],
        );
      }),
    );
  }

  List<PieChartSectionData> _getMasteryDistribution() {
    final counts = _getMasteryCounts();
    final total = counts.reduce((a, b) => a + b);
    
    if (total == 0) {
      return List.generate(5, (index) => 
        PieChartSectionData(
          value: 0,
          color: Colors.grey[300]!,
          title: '',
          radius: 50,
        )
      );
    }

    final colors = [
      Colors.red[400]!,
      Colors.orange[400]!,
      Colors.yellow[600]!,
      Colors.lightGreen[400]!,
      Colors.green[500]!,
    ];

    return List.generate(5, (index) {
      final count = counts[index];
      final percentage = (count / total * 100);
      
      return PieChartSectionData(
        value: count.toDouble(),
        color: colors[index],
        title: count > 0 ? '${percentage.toInt()}%' : '',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 50,
      );
    });
  }

  List<int> _getMasteryCounts() {
    // Count recipes by mastery level
    final counts = List.filled(5, 0);
    
    // This would ideally come from the statistics provider
    // For now, we'll simulate data based on study counts
    for (final entry in statistics.studyCount.entries) {
      final studyCount = entry.value;
      int masteryLevel;
      
      if (studyCount >= 10) {
        masteryLevel = 4;
      } else if (studyCount >= 7) {
        masteryLevel = 3;
      } else if (studyCount >= 4) {
        masteryLevel = 2;
      } else if (studyCount >= 2) {
        masteryLevel = 1;
      } else {
        masteryLevel = 0;
      }
      
      counts[masteryLevel]++;
    }
    
    // If no study data, show some recipes at level 0
    if (counts.every((count) => count == 0)) {
      counts[0] = 33; // Total recipe count
    }
    
    return counts;
  }
}