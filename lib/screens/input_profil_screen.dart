import 'package:flutter/material.dart';
import '../models/app_data.dart'; // Import Data
import 'home_screen.dart';        // <--- PENTING: Import Halaman Home

class InputProfilScreen extends StatefulWidget {
  const InputProfilScreen({super.key});

  @override
  State<InputProfilScreen> createState() => _InputProfilScreenState();
}

class _InputProfilScreenState extends State<InputProfilScreen> {
  final _formKey = GlobalKey<FormState>(); // Buat validasi form
  final _namaController = TextEditingController();
  final _bbController = TextEditingController();
  final _tbController = TextEditingController();

  void _simpanDanLanjut() {
    // Cek apakah form udah diisi semua
    if (_formKey.currentState!.validate()) {
      
      // Simpan ke data dummy
      final appData = AppData();
      appData.nama = _namaController.text;
      
      // Pake tryParse ?? 0 biar gak error kayak tadi
      appData.beratBadan = double.tryParse(_bbController.text) ?? 0;
      appData.tinggiBadan = double.tryParse(_tbController.text) ?? 0;
      
      // Hitung BMR Dummy
      appData.targetKalori = (10 * appData.beratBadan + 6.25 * appData.tinggiBadan - 5 * 25 + 5).toInt();

      // --- NAVIGASI KE HOME ---
      // Pake pushReplacement biar user gak bisa back ke halaman profil lagi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()), // <--- TUJUAN: Home
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lengkapi Data Diri")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form( // Bungkus pake Form biar bisa validasi
          key: _formKey,
          child: Column(
            children: [
              const Text("Biar NutriCare bisa hitung gizi kamu, isi dulu ya!"),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Panggilan"),
                validator: (value) => value!.isEmpty ? 'Nama gak boleh kosong' : null,
              ),
              
              TextFormField(
                controller: _bbController,
                decoration: const InputDecoration(labelText: "Berat Badan (kg)"),
                keyboardType: TextInputType.number, // Keyboard Angka
                validator: (value) => value!.isEmpty ? 'Isi berat badan dulu' : null,
              ),
              
              TextFormField(
                controller: _tbController,
                decoration: const InputDecoration(labelText: "Tinggi Badan (cm)"),
                keyboardType: TextInputType.number, // Keyboard Angka
                validator: (value) => value!.isEmpty ? 'Isi tinggi badan dulu' : null,
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simpanDanLanjut,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text("SIMPAN & LANJUT"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}