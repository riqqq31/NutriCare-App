import 'package:flutter/material.dart';

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
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tren Minggu Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF8FAFC),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Lihat Detail',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF93C5FD),
                    ),
                  ),
                ),
              ],
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
                              decoration: const BoxDecoration(
                                color: Color(0xFF27272A),
                                borderRadius: BorderRadius.vertical(
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
                                          ? const Color(0xFF93C5FD)
                                          : const Color(
                                              0xFF93C5FD,
                                            ).withOpacity(0.4),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                      boxShadow: isToday
                                          ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF93C5FD,
                                                ).withOpacity(0.3),
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
                                  ? const Color(0xFF93C5FD)
                                  : const Color(0xFFA1A1AA),
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
