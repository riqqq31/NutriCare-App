import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../services/database_helper.dart';
import '../core/theme.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<double> _weeklyData = [0, 0, 0, 0, 0, 0, 0];
  List<String> _weeklyDates = [];
  bool _isLoading = true;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  @override
  void didUpdateWidget(covariant ChartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchChartData();
  }

  void _fetchChartData() async {
    final appData = AppData();
    if (appData.activeUserId == null) return;

    final stats = await DatabaseHelper.instance.getWeeklyStats(
      appData.activeUserId!,
    );

    List<double> data = [0, 0, 0, 0, 0, 0, 0];
    List<String> dates = [];

    DateTime now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime dateToCheck = now.subtract(Duration(days: i));
      dates.add(_formatShortDate(dateToCheck));
    }

    for (int i = 0; i < 7; i++) {
      DateTime dateToCheck = now.subtract(Duration(days: i));
      String formattedDate = dateToCheck.toString().substring(0, 10);

      for (var row in stats) {
        if (row['tanggal'] == formattedDate) {
          data[6 - i] = (row['total'] as num).toDouble();
        }
      }
    }

    setState(() {
      _weeklyData = data;
      _weeklyDates = dates;
      _isLoading = false;
    });
  }

  String _formatShortDate(DateTime date) {
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppData();

    return Scaffold(
      backgroundColor: NutriColors.background,
      appBar: AppBar(
        backgroundColor: NutriColors.background,
        title: const Text(
          "Statistik Kalori",
          style: TextStyle(
            color: NutriColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: NutriColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(NutriSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(NutriSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: NutriColors.cardGradient,
                      borderRadius: BorderRadius.circular(NutriRadius.xl),
                      boxShadow: NutriShadows.glow,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Grafik 7 Hari Terakhir",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: NutriSpacing.xs),
                              const Text(
                                "Pantau konsumsi kalorimu",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(NutriSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NutriSpacing.xl),

                  // Chart Container
                  Container(
                    padding: const EdgeInsets.all(NutriSpacing.lg),
                    decoration: BoxDecoration(
                      color: NutriColors.surface,
                      borderRadius: BorderRadius.circular(NutriRadius.xl),
                      boxShadow: NutriShadows.medium,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 220,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (appData.targetKalori * 1.3).toDouble(),
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (_) =>
                                      NutriColors.textPrimary,
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          '${rod.toY.toInt()} kkal',
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                ),
                                touchCallback:
                                    (FlTouchEvent event, barTouchResponse) {
                                      setState(() {
                                        if (!event
                                                .isInterestedForInteractions ||
                                            barTouchResponse == null ||
                                            barTouchResponse.spot == null) {
                                          _touchedIndex = -1;
                                          return;
                                        }
                                        _touchedIndex = barTouchResponse
                                            .spot!
                                            .touchedBarGroupIndex;
                                      });
                                    },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      if (value == 0) return const SizedBox();
                                      return Text(
                                        '${(value / 1000).toStringAsFixed(1)}k',
                                        style: const TextStyle(
                                          color: NutriColors.textMuted,
                                          fontSize: 11,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      if (index >= 0 &&
                                          index < _weeklyDates.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Text(
                                            _weeklyDates[index],
                                            style: TextStyle(
                                              color: index == 6
                                                  ? NutriColors.primary
                                                  : NutriColors.textMuted,
                                              fontSize: 12,
                                              fontWeight: index == 6
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: appData.targetKalori / 2,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: NutriColors.border,
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  );
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: _weeklyData.asMap().entries.map((
                                entry,
                              ) {
                                int index = entry.key;
                                double value = entry.value;
                                bool isOver = value > appData.targetKalori;
                                bool isTouched = index == _touchedIndex;
                                bool isToday = index == 6;

                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: value,
                                      width: isTouched ? 22 : 18,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      ),
                                      gradient: LinearGradient(
                                        colors: isOver
                                            ? [
                                                NutriColors.error,
                                                NutriColors.error.withOpacity(
                                                  0.7,
                                                ),
                                              ]
                                            : isToday
                                            ? [
                                                NutriColors.primary,
                                                NutriColors.primaryLight,
                                              ]
                                            : [
                                                NutriColors.primarySoft,
                                                NutriColors.primaryBg,
                                              ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                              extraLinesData: ExtraLinesData(
                                horizontalLines: [
                                  HorizontalLine(
                                    y: appData.targetKalori.toDouble(),
                                    color: NutriColors.warning,
                                    strokeWidth: 2,
                                    dashArray: [10, 5],
                                    label: HorizontalLineLabel(
                                      show: true,
                                      alignment: Alignment.topRight,
                                      style: const TextStyle(
                                        color: NutriColors.warning,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      labelResolver: (_) => 'Target',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: NutriSpacing.md),
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(
                              NutriColors.primary,
                              "Dalam Target",
                            ),
                            const SizedBox(width: NutriSpacing.lg),
                            _buildLegendItem(
                              NutriColors.error,
                              "Melebihi Target",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NutriSpacing.lg),

                  // Summary Card
                  _buildSummaryCard(appData),
                ],
              ),
            ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: NutriSpacing.xs),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: NutriColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(AppData appData) {
    double avg = _weeklyData.reduce((a, b) => a + b) / 7;
    double total = _weeklyData.reduce((a, b) => a + b);
    int daysOverTarget = _weeklyData
        .where((v) => v > appData.targetKalori)
        .length;
    bool isGood = avg <= appData.targetKalori;

    return Container(
      padding: const EdgeInsets.all(NutriSpacing.lg),
      decoration: BoxDecoration(
        color: NutriColors.surface,
        borderRadius: BorderRadius.circular(NutriRadius.xl),
        boxShadow: NutriShadows.small,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Rata-rata",
                  "${avg.toInt()} kkal",
                  Icons.trending_flat,
                ),
              ),
              Container(width: 1, height: 40, color: NutriColors.border),
              Expanded(
                child: _buildStatItem(
                  "Total",
                  "${total.toInt()} kkal",
                  Icons.summarize_outlined,
                ),
              ),
            ],
          ),
          const Divider(height: NutriSpacing.xl),
          Container(
            padding: const EdgeInsets.all(NutriSpacing.md),
            decoration: BoxDecoration(
              color: isGood ? NutriColors.successBg : NutriColors.errorBg,
              borderRadius: BorderRadius.circular(NutriRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                  isGood ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: isGood ? NutriColors.success : NutriColors.error,
                ),
                const SizedBox(width: NutriSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGood ? "Performa Bagus! 🎉" : "Perlu Perhatian ⚠️",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isGood
                              ? NutriColors.success
                              : NutriColors.error,
                        ),
                      ),
                      Text(
                        isGood
                            ? "Rata-rata konsumsimu dalam batas target."
                            : "$daysOverTarget dari 7 hari melebihi target.",
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              (isGood ? NutriColors.success : NutriColors.error)
                                  .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: NutriColors.textMuted, size: 20),
        const SizedBox(height: NutriSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: NutriColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: NutriColors.textMuted),
        ),
      ],
    );
  }
}
