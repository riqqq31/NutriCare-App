import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/app_data.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppData();

    final List<double> weeklyData = [
      1800,
      1200,
      2000,
      1900,
      1500,
      appData.konsumsiKalori.toDouble(),
      0,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafik Konsumsi Kalori'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // Tambahin Widget ini biar bisa discroll
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Grafik Mingguan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              // ... (Kodingan sisanya biarin aja sama kayak sebelumnya) ...
              const SizedBox(height: 40),

              AspectRatio(
                aspectRatio: 1.5,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 3000,

                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const days = [
                              'Sen',
                              'Sel',
                              'Rab',
                              'Kam',
                              'Jum',
                              'Sab',
                              'Min',
                            ];
                            if (value.toInt() >= 0 &&
                                value.toInt() < days.length) {
                              return Text(
                                days[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),

                    // Setting Garis-garis Grid
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),

                    // DATA BATANGNYA
                    barGroups: weeklyData.asMap().entries.map((entry) {
                      int index = entry.key;
                      double value = entry.value;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            color: value > appData.targetKalori
                                ? Colors.red
                                : Colors
                                      .green, // Merah kalau over, Hijau kalau aman
                            width: 15,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Keterangan Warna
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegend(Colors.green, "Aman"),
                  const SizedBox(width: 20),
                  _buildLegend(Colors.red, "Over Kalori"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}
