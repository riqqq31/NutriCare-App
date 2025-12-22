import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/database_helper.dart';
import '../models/app_data.dart';

class InputProfilScreen extends StatefulWidget {
  const InputProfilScreen({super.key});

  @override
  State<InputProfilScreen> createState() => _InputProfilScreenState();
}

class _InputProfilScreenState extends State<InputProfilScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller buat Text Input
  final _namaController = TextEditingController();
  final _usiaController = TextEditingController();
  final _bbController = TextEditingController();
  final _tbController = TextEditingController();

  // Variabel buat Dropdown
  String _selectedGender = "Laki-laki";
  String _selectedActivity = "Jarang Olahraga (Sedenter)";

  // Data Pilihan Aktivitas & Faktor Pengalinya
  final Map<String, double> _activityLevels = {
    "Jarang Olahraga (Sedenter)": 1.2,
    "Olahraga Ringan (1-3 hari/minggu)": 1.375,
    "Olahraga Sedang (3-5 hari/minggu)": 1.55,
    "Olahraga Berat (6-7 hari/minggu)": 1.725,
  };

  void _simpanDanLanjut() async {
    // <--- Tambahin ASYNC
    if (_formKey.currentState!.validate()) {
      final appData = AppData();

      // Update data di RAM (Singleton)
      appData.nama = _namaController.text;
      appData.gender = _selectedGender;
      appData.usia = int.tryParse(_usiaController.text) ?? 25;
      appData.beratBadan = double.tryParse(_bbController.text) ?? 0;
      appData.tinggiBadan = double.tryParse(_tbController.text) ?? 0;
      appData.aktivitas = _selectedActivity;

      // Hitung BMR & Target (Logic yg sama)
      double bmr =
          (10 * appData.beratBadan) +
          (6.25 * appData.tinggiBadan) -
          (5 * appData.usia);
      if (appData.gender == "Laki-laki") {
        bmr += 5;
      } else {
        bmr -= 161;
      }
      double activityFactor = _activityLevels[_selectedActivity] ?? 1.2;
      appData.targetKalori = (bmr * activityFactor).toInt();

      // --- INI YANG BARU: SIMPAN KE DATABASE ---
      if (appData.activeUserId != null) {
        await DatabaseHelper.instance.updateProfile(appData.activeUserId!, {
          'nama': appData.nama,
          'gender': appData.gender,
          'usia': appData.usia,
          'berat': appData.beratBadan,
          'tinggi': appData.tinggiBadan,
          'aktivitas': appData.aktivitas,
        });
      }
      // ----------------------------------------

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lengkapi Profil")),
      body: SingleChildScrollView(
        // Pake Scroll biar gak mentok keyboard
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Data ini digunakan untuk menghitung kebutuhan gizimu.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Nama
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: "Nama Panggilan",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 15),

              // Gender (Dropdown)
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: "Jenis Kelamin",
                  border: OutlineInputBorder(),
                ),
                items: ["Laki-laki", "Perempuan"].map((String val) {
                  return DropdownMenuItem(value: val, child: Text(val));
                }).toList(),
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),
              const SizedBox(height: 15),

              // Row buat Usia, BB, TB (Biar Rapi Sebaris/Dua Baris)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _usiaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Usia (th)",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Isi' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _bbController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Berat (kg)",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Isi' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _tbController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Tinggi (cm)",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Isi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Aktivitas (Dropdown) - INI KRUSIAL BUAT FLOWCHART
              DropdownButtonFormField<String>(
                initialValue: _selectedActivity,
                isExpanded: true, // Biar teks panjang gak error
                decoration: const InputDecoration(
                  labelText: "Tingkat Aktivitas Harian",
                  border: OutlineInputBorder(),
                ),
                items: _activityLevels.keys.map((String val) {
                  return DropdownMenuItem(
                    value: val,
                    child: Text(val, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedActivity = val!),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _simpanDanLanjut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "HITUNG KEBUTUHAN GIZI",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
