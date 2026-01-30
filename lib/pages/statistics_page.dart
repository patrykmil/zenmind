import 'package:belfort/core/constants/app_colors.dart';
import 'package:belfort/core/constants/mood_options.dart';
import 'package:belfort/services/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  bool _isTodayFromDoc(Map<String, dynamic> data, DateTime now) {
    final createdAt = data['createdAt'];
    if (createdAt == null) return false;

    final dt = createdAt is Timestamp
        ? createdAt.toDate()
        : DateTime.fromMillisecondsSinceEpoch(createdAt as int);
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  Widget _statCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Icon(icon, color: AppColors.greenDark),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid ?? '')
            .collection('reactions')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          final now = DateTime.now();

          final totalReactions = docs.length;
          final todayReactions = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _isTodayFromDoc(data, now);
          }).length;

          final fourteenDaysAgo = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 14));

          final filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final createdAt = data['createdAt'];
            if (createdAt == null) return false;
            final dt = createdAt is Timestamp
                ? createdAt.toDate()
                : DateTime.fromMillisecondsSinceEpoch(createdAt as int);
            return dt.isAfter(fourteenDaysAgo);
          }).toList();

          final moodCounts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
          final dailyScores = <DateTime, List<int>>{};

          for (final doc in filteredDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final score = (data['score'] as num?)?.toInt();
            final createdAt = data['createdAt'];

            if (score != null) {
              if (moodCounts.containsKey(score)) {
                moodCounts[score] = moodCounts[score]! + 1;
              }
              if (createdAt != null) {
                final dateTime = createdAt is Timestamp
                    ? createdAt.toDate()
                    : DateTime.fromMillisecondsSinceEpoch(createdAt as int);
                final date = DateTime(
                  dateTime.year,
                  dateTime.month,
                  dateTime.day,
                );
                dailyScores.putIfAbsent(date, () => []).add(score);
              }
            }
          }

          final trendData = dailyScores.entries.map((e) {
            final avg = e.value.reduce((a, b) => a + b) / e.value.length;
            return MapEntry(e.key, avg);
          }).toList()..sort((a, b) => a.key.compareTo(b.key));

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            context: context,
                            title: 'Total reactions',
                            value: '$totalReactions',
                            icon: Icons.auto_graph,
                            tint: AppColors.softTint,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            context: context,
                            title: 'Today reactions',
                            value: '$todayReactions',
                            icon: Icons.today,
                            tint: AppColors.greenPrimary.withValues(
                              alpha: 0.14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Your Mood in Past 2 Weeks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          minY: 0,
                          maxY: moodCounts.values.isEmpty
                              ? 10
                              : (moodCounts.values.reduce(
                                          (a, b) => a > b ? a : b,
                                        ) +
                                        2)
                                    .toDouble(),
                          barGroups: moodCounts.entries.map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.toDouble(),
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 32,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                              ],
                              showingTooltipIndicators: [0],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (value, meta) {
                                  final mood = moodOptions.firstWhere(
                                    (m) => m.score == value.toInt(),
                                  );
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 10,
                                    child: Text(
                                      mood.emoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            enabled: false,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => Colors.transparent,
                              tooltipPadding: EdgeInsets.zero,
                              tooltipMargin: 8,
                              getTooltipItem:
                                  (
                                    BarChartGroupData group,
                                    int groupIndex,
                                    BarChartRodData rod,
                                    int rodIndex,
                                  ) {
                                    return BarTooltipItem(
                                      rod.toY.toInt().toString(),
                                      const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    const Text(
                      'Your Mood Over Time',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (trendData.isEmpty)
                      const Text('No trend data available')
                    else
                      SizedBox(
                        height: 250,
                        child: LineChart(
                          LineChartData(
                            lineTouchData: const LineTouchData(enabled: false),
                            minY: 1,
                            maxY: 5.2,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(
                              show: false,
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value < 0 ||
                                        value >= trendData.length ||
                                        value != value.toInt()) {
                                      return const SizedBox.shrink();
                                    }
                                    final date = trendData[value.toInt()].key;
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        DateFormat('MM/dd').format(date),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    if (value < 1 ||
                                        value > 5 ||
                                        value != value.toInt()) {
                                      return const SizedBox.shrink();
                                    }
                                    final mood = moodOptions.firstWhere(
                                      (m) => m.score == value.toInt(),
                                    );
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        mood.emoji,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: trendData
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => FlSpot(
                                        e.key.toDouble(),
                                        e.value.value,
                                      ),
                                    )
                                    .toList(),
                                isCurved: true,
                                color: Colors.green,
                                barWidth: 4,
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
