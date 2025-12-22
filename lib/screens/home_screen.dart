import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
    _loadDataFromDB();
  }

  // Logic: Tarik Data & Filter Hari Ini
  void _loadDataFromDB() async {
    final appData = AppData();
    if (appData.activeUserId != null) {
      final dataList = await DatabaseHelper.instance.getRiwayatByUser(appData.activeUserId!);
      
      // Ambil tanggal hari ini (yyyy-mm-dd)
      String todayDate = DateTime.now().toString().substring(0, 10);
      
      int totalHariIni = 0;
      List<Map<String, dynamic>> riwayatHariIni = [];

      for (var item in dataList) {
        // Ambil tanggal data (10 huruf pertama)
        String itemDate = (item['waktu'] as String).substring(0, 10);
        
        if (itemDate == todayDate) {
          totalHariIni += (item['kalori'] as int);
          riwayatHariIni.add(item);
        }
      }

      appData.konsumsiKalori = totalHariIni;
      appData.riwayatMakan = riwayatHariIni;

      setState(() {}); // Refresh Layar
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppData();

    double percentage = 0;
    if (appData.targetKalori > 0) {
      percentage = appData.konsumsiKalori / appData.targetKalori;
      if (percentage > 1.0) percentage = 1.0;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Halo, Semangat Pagi!", style: TextStyle(fontSize: 14)),
            Text(appData.nama.isNotEmpty ? appData.nama : "User", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              if (appData.activeUserId != null) {
                await DatabaseHelper.instance.deleteRiwayatByUser(appData.activeUserId!);
                _loadDataFromDB(); // Reload biar kosong
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Riwayat makanmu bersih!")));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              appData.activeUserId = null;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // KARTU HIJAU
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green.shade700, Colors.green.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Sisa Kalori Harian", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${appData.targetKalori - appData.konsumsiKalori}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      const Text("kkal", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(value: percentage, minHeight: 10, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Terisi: ${appData.konsumsiKalori}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      Text("Target: ${appData.targetKalori}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // MENU CEPAT
            const Text("Menu Cepat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Column(
              children: [
                Row(
                  children: [
                    _buildMenuButton(Icons.restaurant_menu, "Catat Makan", () async {
                      await Navigator.pushNamed(context, '/add_food');
                      _loadDataFromDB(); // RELOAD OTOMATIS pas balik
                    }),
                    const SizedBox(width: 15),
                    _buildMenuButton(Icons.bar_chart, "Grafik", () {
                      Navigator.pushNamed(context, '/chart');
                    }),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _buildMenuButton(Icons.article, "Artikel", () {
                      Navigator.pushNamed(context, '/articles');
                    }),
                    const SizedBox(width: 15),
                    _buildMenuButton(Icons.person, "Profil", () {
                      Navigator.pushNamed(context, '/profile');
                    }),
                  ],
                ),
              ],
            ),
            
      
            
            
            // LIST RIWAYAT
            const SizedBox(height: 30),
            const Text("Riwayat Makan Hari Ini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appData.riwayatMakan.length,
              itemBuilder: (context, index) {
                final makanan = appData.riwayatMakan[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.restaurant, color: Colors.white, size: 20)),
                    title: Text(makanan['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    // Potong Waktu Biar Cuma Tampil JAM (HH:MM)
                    subtitle: Text("Jam: ${makanan['waktu'].toString().substring(11, 16)}"),
                    trailing: Text("+${makanan['kalori']} kkal", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20), // Sesuaikan tinggi tombol
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    )
    );
  }
}