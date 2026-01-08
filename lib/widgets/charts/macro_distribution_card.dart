import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// Widget untuk menampilkan distribusi makro dalam bentuk donut chart
class MacroDistributionCard extends StatelessWidget {
  final int totalCalories;
  final int proteinPercent;
  final int karboPercent;
  final int lemakPercent;
  final double proteinGrams;
  final double karboGrams;
  final double lemakGrams;

  const MacroDistributionCard({
    super.key,
    required this.totalCalories,
    required this.proteinPercent,
    required this.karboPercent,
    required this.lemakPercent,
    required this.proteinGrams,
    required this.karboGrams,
    required this.lemakGrams,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border(context), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: AppColors.isDark(context) ? 0.4 : 0.1,
              ),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Glow
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribusi Makro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 24),

                // Donut Chart
                Center(
                  child: SizedBox(
                    width: 192,
                    height: 192,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pie Chart
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 72,
                            sections: [
                              PieChartSectionData(
                                value: proteinPercent.toDouble(),
                                color: const Color(0xFF818CF8),
                                radius: 20,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: karboPercent.toDouble(),
                                color: const Color(0xFF60A5FA),
                                radius: 20,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: lemakPercent.toDouble(),
                                color: const Color(0xFFFB923C),
                                radius: 20,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),

                        // Center Text
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total Kalori',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalCalories.toString(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            const Text(
                              'kcal',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF93C5FD),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Macro Summary
                Row(
                  children: [
                    Expanded(
                      child: _buildMacroSummaryItem(
                        context,
                        color: const Color(0xFF818CF8),
                        name: 'PROTEIN',
                        percent: proteinPercent,
                        grams: proteinGrams,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroSummaryItem(
                        context,
                        color: const Color(0xFF60A5FA),
                        name: 'KARBO',
                        percent: karboPercent,
                        grams: karboGrams,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroSummaryItem(
                        context,
                        color: const Color(0xFFFB923C),
                        name: 'LEMAK',
                        percent: lemakPercent,
                        grams: lemakGrams,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSummaryItem(
    BuildContext context, {
    required Color color,
    required String name,
    required int percent,
    required double grams,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.isDark(context)
            ? const Color(0xFF27272A).withValues(alpha: 0.5)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary(context),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          Text(
            '${grams.round()}g',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
