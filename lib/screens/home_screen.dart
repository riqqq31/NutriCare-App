import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../models/app_data.dart';
import '../services/database_helper.dart';
import 'add_food.dart';
import 'chart_screen.dart';
import 'article_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDataFromDB();
  }

  void _loadDataFromDB() async {
    final appData = AppData();
    if (appData.activeUserId != null) {
      final dataList = await DatabaseHelper.instance.getRiwayatByUser(
        appData.activeUserId!,
      );
      String todayDate = DateTime.now().toString().substring(0, 10);
      int totalHariIni = 0;
      List<Map<String, dynamic>> riwayatHariIni = [];

      for (var item in dataList) {
        String itemDate = (item['waktu'] as String).substring(0, 10);
        if (itemDate == todayDate) {
          totalHariIni += (item['kalori'] as int);
          riwayatHariIni.add(item);
        }
      }
      appData.konsumsiKalori = totalHariIni;
      appData.riwayatMakan = riwayatHariIni;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppData();

    // List halaman untuk navigasi
    final List<Widget> _pages = [
      _buildDashboardContent(appData), // 0: Home
      const AddFoodScreen(), // 1: Catat Makan
      ChartScreen(), // 2: Statistik
      const ArticleScreen(), // 3: Artikel
      const ProfileScreen(), // 4: Profil
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // BALIKIN APPBAR
      appBar: _currentIndex == 0
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Halo, Semangat Pagi!",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    appData.nama.isNotEmpty ? appData.nama : "User",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                // TOMBOL HAPUS RIWAYAT
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    if (appData.activeUserId != null) {
                      await DatabaseHelper.instance.deleteRiwayatByUser(
                        appData.activeUserId!,
                      );
                      _loadDataFromDB();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Riwayat makanmu bersih!"),
                        ),
                      );
                    }
                  },
                ),
                // TOMBOL LOGOUT
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    appData.activeUserId = null;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            )
          : null, // AppBar cuma muncul di Home

      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) _loadDataFromDB();
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Home"),
            selectedColor: Colors.green,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.add_circle),
            title: const Text("Catat Makan"),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.bar_chart),
            title: const Text("Statistik"),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.article),
            title: const Text("Artikel"),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Profil"),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(AppData appData) {
    double percentage = (appData.targetKalori > 0)
        ? (appData.konsumsiKalori / appData.targetKalori).clamp(0.0, 1.0)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KARTU HIJAU SESUAI DESAIN LAMA
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sisa Kalori Harian",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${appData.targetKalori - appData.konsumsiKalori}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "kkal",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Terisi: ${appData.konsumsiKalori}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "Target: ${appData.targetKalori}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            "Riwayat Makan Hari Ini",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // LIST RIWAYAT
          appData.riwayatMakan.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Belum ada data makan."),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appData.riwayatMakan.length,
                  itemBuilder: (context, index) {
                    final item = appData.riwayatMakan[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item['nama'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Jam: ${item['waktu'].toString().substring(11, 16)}",
                        ),
                        trailing: Text(
                          "+${item['kalori']} kkal",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
