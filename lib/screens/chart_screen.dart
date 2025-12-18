import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../services/database_helper.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<double> _weeklyData = [0, 0, 0, 0, 0, 0, 0];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  // LOGIC: Narik data beneran dari SQLite
  void _fetchChartData() async {
    final appData = AppData();
    if (appData.activeUserId == null) return;

    // Ambil stats dari DB
    final stats = await DatabaseHelper.instance.getWeeklyStats(appData.activeUserId!);
    
    // Kita bikin list 7 hari (Index 6 adalah hari ini, Index 0 adalah 6 hari lalu)
    List<double> data = [0, 0, 0, 0, 0, 0, 0];
    
    // Map data dari DB ke List (Simpelnya: Kita cocokkan tanggal)
    DateTime now = DateTime.now();
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
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppData();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik Kalori"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Grafik 7 Hari Terakhir",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (appData.targetKalori * 1.5).toDouble(), 
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                // Tampilkan inisial hari
                                const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                int dayIndex = (DateTime.now().weekday - (6 - value.toInt()) - 1) % 7;
                                if (dayIndex < 0) dayIndex += 7;
                                return Text(days[dayIndex]);
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: _weeklyData.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value,
                                color: entry.value > appData.targetKalori ? Colors.red : Colors.green,
                                width: 18,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  _buildSummaryCard(appData),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSummaryCard(AppData appData) {
    double avg = _weeklyData.reduce((a, b) => a + b) / 7;
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Rata-rata Harian", style: TextStyle(color: Colors.grey)),
            Text("${avg.toInt()} kkal", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            Text(
              avg > appData.targetKalori 
                ? "Lu makannya kebanyakan, bro. Kurangin!" 
                : "Bagus! Lu konsisten di bawah target.",
              textAlign: TextAlign.center,
              style: TextStyle(color: avg > appData.targetKalori ? Colors.red : Colors.green),
            )
          ],
        ),
      ),
    );
  }
}