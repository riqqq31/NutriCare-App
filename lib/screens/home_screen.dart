import 'package:flutter/material.dart';
import '../models/app_data.dart'; 
import 'add_food.dart';
import 'login_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final appData = AppData();
    
    // Hitung persentase
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
          // TOMBOL RESET (SAMPAH)
          IconButton(
            icon: const Icon(Icons.delete), 
            onPressed: () {
              appData.konsumsiKalori = 0;
              appData.riwayatMakan.clear(); // Hapus juga list riwayatnya biar bersih total
              setState(() {});
            },
          ),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout), 
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            }
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. KARTU HIJAU ---
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
                  BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Sisa Kalori Harian", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${appData.targetKalori - appData.konsumsiKalori}",
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Text("kkal", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // PROGRESS BAR
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
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
            
            // --- 2. MENU CEPAT ---
            const Text("Menu Cepat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            // Baris 1
            Row(
              children: [
                Expanded(child: _buildMenuButton(Icons.restaurant_menu, "Catat Makan", () async {
                  await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const AddFoodScreen())
                  );
                  setState(() {}); 
                })),
                const SizedBox(width: 15),
                Expanded(child: _buildMenuButton(Icons.bar_chart, "Grafik", () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Grafik segera hadir!")));
                })),
              ],
            ),
            
            const SizedBox(height: 15),
            
            // Baris 2
            Row(
              children: [
                Expanded(child: _buildMenuButton(Icons.article, "Artikel", () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Artikel segera hadir!")));
                })),
                const SizedBox(width: 15),
                Expanded(child: _buildMenuButton(Icons.person, "Profil Saya", () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Edit Profil segera hadir!")));
                })),
              ],
            ), // <--- INI TUTUP ROW YANG BENER

            // --- 3. RIWAYAT MAKAN (Ditaruh di LUAR tombol, pake KOMA) ---
            
            const SizedBox(height: 30), // Pake KOMA (,) bukan TITIK KOMA (;)
            
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
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.restaurant, color: Colors.white, size: 20),
                    ),
                    title: Text(makanan['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Jam: ${makanan['waktu']}"),
                    trailing: Text(
                      "+${makanan['kalori']} kkal", 
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 50),

          ], // <--- Tutup Column Utama
        ),
      ),
    );
  }

  // Widget kecil buat tombol menu
  Widget _buildMenuButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.green),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}