import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/app_data.dart';
import '../core/theme.dart';

class InputProfilScreen extends StatefulWidget {
  const InputProfilScreen({super.key});

  @override
  State<InputProfilScreen> createState() => _InputProfilScreenState();
}

class _InputProfilScreenState extends State<InputProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  final _namaController = TextEditingController();
  final _usiaController = TextEditingController();
  final _bbController = TextEditingController();
  final _tbController = TextEditingController();

  String _selectedGender = "Laki-laki";
  String _selectedActivity = "Jarang Olahraga (Sedenter)";

  final Map<String, double> _activityLevels = {
    "Jarang Olahraga (Sedenter)": 1.2,
    "Olahraga Ringan (1-3 hari/minggu)": 1.375,
    "Olahraga Sedang (3-5 hari/minggu)": 1.55,
    "Olahraga Berat (6-7 hari/minggu)": 1.725,
  };

  void _simpanDanLanjut() async {
    if (_formKey.currentState!.validate()) {
      final appData = AppData();

      appData.nama = _namaController.text;
      appData.gender = _selectedGender;
      appData.usia = int.tryParse(_usiaController.text) ?? 25;
      appData.beratBadan = double.tryParse(_bbController.text) ?? 0;
      appData.tinggiBadan = double.tryParse(_tbController.text) ?? 0;
      appData.aktivitas = _selectedActivity;

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

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutriColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(NutriSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: NutriColors.primaryBg,
                          borderRadius: BorderRadius.circular(NutriRadius.md),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: NutriColors.primary,
                        ),
                      ),
                      const SizedBox(width: NutriSpacing.md),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lengkapi Profil",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: NutriColors.textPrimary,
                              ),
                            ),
                            Text(
                              "Data ini untuk menghitung kebutuhan gizimu",
                              style: TextStyle(
                                fontSize: 13,
                                color: NutriColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NutriSpacing.lg),
                  // Progress Indicator
                  Row(
                    children: List.generate(3, (index) {
                      bool isActive = index <= _currentStep;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                          height: 4,
                          decoration: BoxDecoration(
                            color: isActive
                                ? NutriColors.primary
                                : NutriColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: NutriSpacing.lg,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step 1: Personal Info
                      _buildSectionCard(
                        title: "Informasi Pribadi",
                        icon: Icons.badge_outlined,
                        children: [
                          _buildTextField(
                            controller: _namaController,
                            label: "Nama Panggilan",
                            icon: Icons.person_outline,
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: NutriSpacing.md),
                          _buildDropdown(
                            value: _selectedGender,
                            label: "Jenis Kelamin",
                            icon: Icons.wc_outlined,
                            items: ["Laki-laki", "Perempuan"],
                            onChanged: (v) =>
                                setState(() => _selectedGender = v!),
                          ),
                        ],
                      ),
                      const SizedBox(height: NutriSpacing.md),

                      // Step 2: Physical Data
                      _buildSectionCard(
                        title: "Data Fisik",
                        icon: Icons.monitor_weight_outlined,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _usiaController,
                                  label: "Usia",
                                  suffix: "tahun",
                                  icon: Icons.cake_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v!.isEmpty ? 'Isi' : null,
                                ),
                              ),
                              const SizedBox(width: NutriSpacing.md),
                              Expanded(
                                child: _buildTextField(
                                  controller: _bbController,
                                  label: "Berat",
                                  suffix: "kg",
                                  icon: Icons.fitness_center,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v!.isEmpty ? 'Isi' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: NutriSpacing.md),
                          _buildTextField(
                            controller: _tbController,
                            label: "Tinggi Badan",
                            suffix: "cm",
                            icon: Icons.height,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Isi' : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: NutriSpacing.md),

                      // Step 3: Activity Level
                      _buildSectionCard(
                        title: "Tingkat Aktivitas",
                        icon: Icons.directions_run_outlined,
                        children: [
                          ...(_activityLevels.keys.map((activity) {
                            bool isSelected = _selectedActivity == activity;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedActivity = activity),
                              child: Container(
                                margin: const EdgeInsets.only(
                                  bottom: NutriSpacing.sm,
                                ),
                                padding: const EdgeInsets.all(NutriSpacing.md),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? NutriColors.primaryBg
                                      : NutriColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(
                                    NutriRadius.md,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? NutriColors.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? NutriColors.primary
                                            : NutriColors.border,
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 14,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: NutriSpacing.md),
                                    Expanded(
                                      child: Text(
                                        activity,
                                        style: TextStyle(
                                          color: isSelected
                                              ? NutriColors.primary
                                              : NutriColors.textPrimary,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })),
                        ],
                      ),
                      const SizedBox(height: NutriSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.all(NutriSpacing.lg),
              decoration: BoxDecoration(
                color: NutriColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _simpanDanLanjut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NutriColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NutriRadius.md),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calculate_outlined),
                      SizedBox(width: NutriSpacing.sm),
                      Text(
                        "HITUNG KEBUTUHAN GIZI",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(NutriSpacing.md),
      decoration: BoxDecoration(
        color: NutriColors.surface,
        borderRadius: BorderRadius.circular(NutriRadius.lg),
        boxShadow: NutriShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: NutriColors.primary, size: 20),
              const SizedBox(width: NutriSpacing.sm),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: NutriColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: NutriSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: icon != null
            ? Icon(icon, color: NutriColors.textMuted)
            : null,
        filled: true,
        fillColor: NutriColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NutriRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NutriRadius.md),
          borderSide: const BorderSide(color: NutriColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: NutriColors.textMuted),
        filled: true,
        fillColor: NutriColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NutriRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((String val) {
        return DropdownMenuItem(value: val, child: Text(val));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
