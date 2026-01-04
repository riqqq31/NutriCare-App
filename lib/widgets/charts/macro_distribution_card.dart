import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x0DFFFFFF), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
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
                  color: const Color(0xFF93C5FD).withOpacity(0.05),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Distribusi Makro',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF8FAFC),
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
                            const Text(
                              'Total Kalori',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFA1A1AA),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalCalories.toString(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF8FAFC),
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
                        color: const Color(0xFF818CF8),
                        name: 'PROTEIN',
                        percent: proteinPercent,
                        grams: proteinGrams,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroSummaryItem(
                        color: const Color(0xFF60A5FA),
                        name: 'KARBO',
                        percent: karboPercent,
                        grams: karboGrams,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroSummaryItem(
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

  Widget _buildMacroSummaryItem({
    required Color color,
    required String name,
    required int percent,
    required double grams,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF27272A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0DFFFFFF), width: 1),
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
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA1A1AA),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$percent%',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF8FAFC),
            ),
          ),
          Text(
            '${grams.round()}g',
            style: const TextStyle(fontSize: 12, color: Color(0xFFA1A1AA)),
          ),
        ],
      ),
    );
  }
}
