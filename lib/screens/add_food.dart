import 'package:flutter/material.dart';
import '../models/app_data.dart'; // <--- Pastikan ini ngarah ke file model yang bener

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  // Database Makanan Palsu
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
            const Text(
              "Apa yang kamu makan?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Dropdown Menu
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
            
            // Kotak Info Kalori
            if (_selectedFoodName != null)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Kalori:", style: TextStyle(fontSize: 16)),
                    Text(
                      "$_selectedCalories kkal",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),

            const Spacer(),
            
            // Tombol Simpan
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
             onPressed: _selectedFoodName == null
                  ? null 
                  : () {
                      final appData = AppData();
                      
                      // 1. Update Total (Yang lama)
                      appData.konsumsiKalori += _selectedCalories; 
                      
                      // 2. Masukin ke Keranjang (YANG BARU)
                      appData.riwayatMakan.add({
                        'nama': _selectedFoodName,
                        'kalori': _selectedCalories,
                        'waktu': DateTime.now().toString().substring(11, 16), // Jam:Menit
                      });

                      Navigator.pop(context); 
                      // ... snackbar code ...
                    }, child: const Text(
                      "Simpan Catatan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

            ),
          ],
        ),
      ),
    );
  }
}