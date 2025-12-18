import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../services/database_helper.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final List<Map<String, dynamic>> _dummyFoods = [
    {'nama': 'Nasi Putih (1 porsi)', 'kalori': 204},
    {'nama': 'Nasi Uduk (1 porsi)', 'kalori': 260},
    {'nama': 'Ayam Goreng (1 potong)', 'kalori': 243},
    {'nama': 'Telur Dadar', 'kalori': 93},
    {'nama': 'Tahu Goreng', 'kalori': 35},
    {'nama': 'Sayur Asem', 'kalori': 80},
    {'nama': 'Es Teh Manis', 'kalori': 90},
    {'nama': 'Pisang Goreng', 'kalori': 140},
  ];

  String? _selectedFoodName;
  int _selectedCalories = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catat Makanan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Apa yang kamu makan?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              hint: const Text("Pilih menu makanan..."),
              items: _dummyFoods.map((food) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: food,
                  child: Text(food['nama']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFoodName = value!['nama'];
                  _selectedCalories = value['kalori'];
                });
              },
            ),
            
            const SizedBox(height: 20),
            if (_selectedFoodName != null)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Kalori:", style: TextStyle(fontSize: 16)),
                    Text("$_selectedCalories kkal", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),

            const Spacer(),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _selectedFoodName == null
                  ? null 
                  : () async {
                      final appData = AppData();
                      
                      // 1. CEK USER
                      if (appData.activeUserId == null) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Tidak ada user login!")));
                         return;
                      }

                      // 2. SIAPKAN DATA LENGKAP (TANGGAL + JAM)
                      String fullDate = DateTime.now().toString(); // "2025-11-20 14:30:00"

                      Map<String, dynamic> row = {
                        'user_id': appData.activeUserId,
                        'nama': _selectedFoodName,
                        'kalori': _selectedCalories,
                        'waktu': fullDate, 
                      };

                      // 3. SIMPAN KE DB
                      await DatabaseHelper.instance.insertMakanan(row);

                      // 4. UPDATE RAM (Biar UI responsif)
                      appData.konsumsiKalori += _selectedCalories;
                      appData.riwayatMakan.add(row);

                      if (context.mounted) {
                        // TAMPILKAN NOTIF DULU
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Nyam! $_selectedFoodName berhasil dicatat."), backgroundColor: Colors.green, duration: const Duration(seconds: 1)),
                        );
                        // BARU TUTUP LAYAR (Kasih delay dikit biar notif keliatan)
                        Future.delayed(const Duration(milliseconds: 500), () {
                           if (context.mounted) Navigator.pop(context);
                        });
                      }
                    },
              child: const Text("Simpan Catatan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}