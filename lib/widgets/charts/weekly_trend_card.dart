import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// Widget untuk menampilkan tren mingguan dengan bar chart
class WeeklyTrendCard extends StatelessWidget {
  final List<double> weeklyData;
  final List<String> weeklyDates;
  final int targetKalori;

  const WeeklyTrendCard({
    super.key,
    required this.weeklyData,
    required this.weeklyDates,
    required this.targetKalori,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
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
        child: Column(
          children: [
            // Header
            Text(
              'Tren Minggu Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 24),

            // Bar Chart
            SizedBox(
              height: 128,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final value = index < weeklyData.length
                      ? weeklyData[index]
                      : 0.0;
                  final maxValue = targetKalori * 1.2;
                  final heightPercent = maxValue > 0
                      ? (value / maxValue).clamp(0.0, 1.0)
                      : 0.0;
                  final isToday = index == 6;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.isDark(context)
                                    ? const Color(0xFF27272A)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: heightPercent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? const Color(0xFF60A5FA)
                                          : const Color(
                                              0xFF60A5FA,
                                            ).withValues(alpha: 0.4),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                      boxShadow: isToday
                                          ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF60A5FA,
                                                ).withValues(alpha: 0.3),
                                                blurRadius: 15,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weeklyDates[index],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isToday
                                  ? const Color(0xFF60A5FA)
                                  : AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
