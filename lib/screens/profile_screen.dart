import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../services/database_helper.dart';
import '../core/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usiaController = TextEditingController();
  final _bbController = TextEditingController();
  final _tbController = TextEditingController();

  String _selectedGender = "Laki-laki";
  String _selectedActivity = "Jarang Olahraga (Sedenter)";
  bool _isEditing = false;
  bool _isLoading = false;

  final Map<String, double> _activityLevels = {
    "Jarang Olahraga (Sedenter)": 1.2,
    "Olahraga Ringan (1-3 hari/minggu)": 1.375,
    "Olahraga Sedang (3-5 hari/minggu)": 1.55,
    "Olahraga Berat (6-7 hari/minggu)": 1.725,
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final appData = AppData();
    _namaController.text = appData.nama;
    _usiaController.text = appData.usia.toString();
    _bbController.text = appData.beratBadan.toString();
    _tbController.text = appData.tinggiBadan.toString();
    _selectedGender = appData.gender;
    _selectedActivity = appData.aktivitas;
    if (!_activityLevels.containsKey(_selectedActivity)) {
      _selectedActivity = _activityLevels.keys.first;
    }
    setState(() {});
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final appData = AppData();

      // Update local state
      appData.nama = _namaController.text;
      appData.gender = _selectedGender;
      appData.usia = int.tryParse(_usiaController.text) ?? 25;
      appData.beratBadan = double.tryParse(_bbController.text) ?? 0;
      appData.tinggiBadan = double.tryParse(_tbController.text) ?? 0;
      appData.aktivitas = _selectedActivity;

      // Calculate BMR & TDEE
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

      // Update Database
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

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Profil berhasil diperbarui!"),
            backgroundColor: NutriColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NutriRadius.md),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutriColors.background,
      appBar: AppBar(
        backgroundColor: NutriColors.background,
        elevation: 0,
        title: const Text(
          "Profil Saya",
          style: TextStyle(
            color: NutriColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: NutriColors.primary,
            ),
            onPressed: () {
              if (_isEditing) _loadProfileData(); // Reset if cancel
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(NutriSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(NutriSpacing.lg),
                decoration: BoxDecoration(
                  gradient: NutriColors.cardGradient,
                  borderRadius: BorderRadius.circular(NutriRadius.xl),
                  boxShadow: NutriShadows.glow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(NutriSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: NutriSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _namaController.text.isNotEmpty
                                ? _namaController.text
                                : "User",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Target: ${AppData().targetKalori} kkal",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NutriSpacing.xl),

              // Form Fields
              _buildEditableTextField(
                label: "Nama Panggilan",
                controller: _namaController,
                icon: Icons.badge_outlined,
                enabled: _isEditing,
              ),
              const SizedBox(height: NutriSpacing.md),

              _isEditing
                  ? _buildDropdown(
                      label: "Jenis Kelamin",
                      value: _selectedGender,
                      items: ["Laki-laki", "Perempuan"],
                      onChanged: (v) => setState(() => _selectedGender = v!),
                      icon: Icons.wc_outlined,
                    )
                  : _buildReadOnlyField(
                      "Jenis Kelamin",
                      _selectedGender,
                      Icons.wc_outlined,
                    ),

              const SizedBox(height: NutriSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: _buildEditableTextField(
                      label: "Usia (th)",
                      controller: _usiaController,
                      icon: Icons.cake_outlined,
                      enabled: _isEditing,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: NutriSpacing.md),
                  Expanded(
                    child: _buildEditableTextField(
                      label: "Berat (kg)",
                      controller: _bbController,
                      icon: Icons.fitness_center_outlined,
                      enabled: _isEditing,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NutriSpacing.md),
              _buildEditableTextField(
                label: "Tinggi Badan (cm)",
                controller: _tbController,
                icon: Icons.height_outlined,
                enabled: _isEditing,
                isNumber: true,
              ),

              const SizedBox(height: NutriSpacing.md),

              _isEditing
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Aktivitas",
                          style: TextStyle(
                            color: NutriColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._activityLevels.keys.map((activity) {
                          bool isSelected = _selectedActivity == activity;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedActivity = activity),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
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
                                ),
                              ),
                              child: Text(
                                activity,
                                style: TextStyle(
                                  color: isSelected
                                      ? NutriColors.primary
                                      : NutriColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    )
                  : _buildReadOnlyField(
                      "Aktivitas",
                      _selectedActivity,
                      Icons.directions_run_outlined,
                    ),

              const SizedBox(height: NutriSpacing.xxl),

              // Save Button
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NutriColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(NutriRadius.md),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "SIMPAN PERUBAHAN",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

              // Logout Button (Only show when not editing)
              if (!_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      AppData().activeUserId = null;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: NutriColors.error,
                      side: const BorderSide(color: NutriColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(NutriRadius.md),
                      ),
                    ),
                    child: const Text(
                      "KELUAR AKUN",
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

  Widget _buildEditableTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: enabled ? NutriColors.primary : NutriColors.textMuted,
        ),
        filled: true,
        fillColor: enabled ? NutriColors.surface : NutriColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NutriRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NutriRadius.md),
          borderSide: const BorderSide(color: NutriColors.primary, width: 2),
        ),
        enabledBorder: enabled
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(NutriRadius.md),
                borderSide: const BorderSide(color: NutriColors.border),
              )
            : null,
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: NutriColors.surfaceAlt,
        borderRadius: BorderRadius.circular(NutriRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: NutriColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: NutriColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: NutriColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: NutriColors.primary),
        filled: true,
        fillColor: NutriColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NutriRadius.md),
          borderSide: const BorderSide(color: NutriColors.border),
        ),
      ),
    );
  }
}
