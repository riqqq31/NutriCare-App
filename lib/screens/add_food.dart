import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../services/database_helper.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  // Variabel buat nyimpen makanan yang dipilih
  Map<String, dynamic>? _selectedFood;
  double _porsi = 1.0; // Default 1 porsi

  // Controller buat input porsi manual
  final TextEditingController _porsiController = TextEditingController(text: "1.0");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cari Makanan"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. SEARCH BAR CANGGIH (Autocomplete)
            Autocomplete<Map<String, dynamic>>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text == '') return const Iterable.empty();
                // Cari ke Database
                return await DatabaseHelper.instance.searchMakanan(textEditingValue.text);
              },
              displayStringForOption: (Map<String, dynamic> option) => option['nama'],
              onSelected: (Map<String, dynamic> selection) {
                setState(() {
                  _selectedFood = selection;
                  _porsi = 1.0;
                  _porsiController.text = "1.0";
                });
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: "Ketik nama makanan (cth: Ayam)",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 2. KARTU DETAIL MAKANAN (Muncul kalau udah pilih)
            if (_selectedFood != null) ...[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Text(_selectedFood!['nama'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(_selectedFood!['porsi_desc'] ?? '1 Porsi', style: const TextStyle(color: Colors.grey)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _nutrientInfo("Kalori", (_selectedFood!['kalori'] * _porsi).toInt(), "kkal"),
                        _nutrientInfo("Protein", (_selectedFood!['protein'] * _porsi).toStringAsFixed(1), "g"),
                        _nutrientInfo("Karbo", (_selectedFood!['karbo'] * _porsi).toStringAsFixed(1), "g"),
                        _nutrientInfo("Lemak", (_selectedFood!['lemak'] * _porsi).toStringAsFixed(1), "g"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. ATUR PORSI
              Row(
                children: [
                  const Text("Jumlah Porsi:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 15),
                  IconButton(onPressed: () => _updatePorsi(-0.5), icon: const Icon(Icons.remove_circle_outline, color: Colors.red)),
                  SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _porsiController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (val) {
                        double? newVal = double.tryParse(val);
                        if (newVal != null && newVal > 0) {
                          setState(() => _porsi = newVal);
                        }
                      },
                    ),
                  ),
                  IconButton(onPressed: () => _updatePorsi(0.5), icon: const Icon(Icons.add_circle_outline, color: Colors.green)),
                ],
              ),

              const Spacer(),

              // 4. TOMBOL SIMPAN
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () async {
                  await _simpanMakanan(context);
                },
                child: const Text("SIMPAN KE RIWAYAT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ] else ...[
               // Tampilan kalau belum pilih makanan
               const Expanded(
                 child: Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                       Text("Cari makananmu di atas", style: TextStyle(color: Colors.grey)),
                     ],
                   ),
                 ),
               )
            ],
          ],
        ),
      ),
    );
  }

  void _updatePorsi(double delta) {
    double newValue = _porsi + delta;
    if (newValue < 0.5) newValue = 0.5;
    setState(() {
      _porsi = newValue;
      _porsiController.text = _porsi.toString();
    });
  }

  Widget _nutrientInfo(String label, dynamic value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text("$value $unit", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Future<void> _simpanMakanan(BuildContext context) async {
    final appData = AppData();
    if (appData.activeUserId == null) return;

    // Data yang disimpan adalah HASIL PERKALIAN PORSI
    Map<String, dynamic> row = {
      'user_id': appData.activeUserId,
      'nama': _selectedFood!['nama'],
      'kalori': (_selectedFood!['kalori'] * _porsi).toInt(),
      'protein': _selectedFood!['protein'] * _porsi,
      'karbo': _selectedFood!['karbo'] * _porsi,
      'lemak': _selectedFood!['lemak'] * _porsi,
      'porsi': _porsi,
      'waktu': DateTime.now().toString(),
    };

    await DatabaseHelper.instance.insertMakanan(row);

    // Update RAM (Kalori aja dulu, makro nanti kalo dashboard udah support)
    appData.konsumsiKalori += (row['kalori'] as int);
    appData.riwayatMakan.add(row);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil disimpan!"), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }
}