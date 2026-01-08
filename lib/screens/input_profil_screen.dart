import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../providers/food_log_provider.dart';
import '../services/image_picker_service.dart';
import '../widgets/input/weight_slider.dart';
import '../widgets/input/gender_selector.dart';
import '../widgets/input/labeled_text_field.dart';
import '../widgets/input/labeled_number_field.dart';
import '../core/app_colors.dart';

class InputProfilScreen extends ConsumerStatefulWidget {
  const InputProfilScreen({super.key});

  @override
  ConsumerState<InputProfilScreen> createState() => _InputProfilScreenState();
}

class _InputProfilScreenState extends ConsumerState<InputProfilScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _usiaController = TextEditingController();
  final _tbController = TextEditingController();
  final _bbController = TextEditingController();

  String _selectedGender = "Laki-laki";
  String _selectedActivity = "Jarang Olahraga (Sedenter)";
  String _selectedTujuanDiet = "Maintenance";
  double _beratBadan = 0;
  bool _isLoading = false;

  final Map<String, double> _activityLevels = {
    "Jarang Olahraga (Sedenter)": 1.2,
    "Olahraga Ringan (1-3 hari/minggu)": 1.375,
    "Olahraga Sedang (3-5 hari/minggu)": 1.55,
    "Olahraga Berat (6-7 hari/minggu)": 1.725,
  };

  final _dietDescriptions = {
    'Cutting': 'Defisit kalori untuk turunkan berat badan',
    'Maintenance': 'Pertahankan berat badan saat ini',
    'Bulking': 'Surplus kalori untuk naikkan massa otot',
  };

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final userState = ref.read(userProvider);
    if (userState.nama.isNotEmpty) {
      _namaController.text = userState.nama;
      _usiaController.text = userState.usia.toString();
      _tbController.text = userState.tinggiBadan.round().toString();
      _selectedGender = userState.gender;
      _beratBadan = userState.beratBadan > 0 ? userState.beratBadan : 0;
      if (_activityLevels.containsKey(userState.aktivitas)) {
        _selectedActivity = userState.aktivitas;
      }
      _bbController.text = _beratBadan.toStringAsFixed(1);
      _selectedTujuanDiet = userState.tujuanDiet;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usiaController.dispose();
    _tbController.dispose();
    _bbController.dispose();
    super.dispose();
  }

  void _simpanDanLanjut() async {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      setState(() => _isLoading = true);

      try {
        if (ref.read(userProvider).id == null) {
          throw Exception("User ID tidak ditemukan. Silakan login ulang.");
        }

        await ref
            .read(userProvider.notifier)
            .updateProfile(
              nama: _namaController.text,
              gender: _selectedGender,
              usia: int.tryParse(_usiaController.text) ?? 0,
              beratBadan: _beratBadan,
              tinggiBadan: double.tryParse(_tbController.text) ?? 0,
              aktivitas: _selectedActivity,
              tujuanDiet: _selectedTujuanDiet,
            );

        await ref.read(foodLogProvider.notifier).loadTodayData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Profil berhasil disimpan!"),
              backgroundColor: const Color(0xFF22C55E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menyimpan: ${e.toString()}"),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Mohon lengkapi data dengan benar"),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Avatar Section
                      _buildAvatarSection(),
                      const SizedBox(height: 24),

                      // Name Field - Using extracted widget
                      LabeledTextField(
                        label: 'Nama Lengkap',
                        controller: _namaController,
                        icon: Icons.person,
                        hint: 'Masukkan nama lengkap',
                      ),
                      const SizedBox(height: 20),

                      // Gender Selection - Using extracted widget
                      GenderSelector(
                        selectedGender: _selectedGender,
                        onGenderChanged: (value) =>
                            setState(() => _selectedGender = value),
                      ),
                      const SizedBox(height: 20),

                      // Age & Height Row - Using extracted widgets
                      Row(
                        children: [
                          Expanded(
                            child: LabeledNumberField(
                              label: 'Umur',
                              controller: _usiaController,
                              suffix: 'thn',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: LabeledNumberField(
                              label: 'Tinggi Badan',
                              controller: _tbController,
                              suffix: 'cm',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Weight Slider - Using extracted widget
                      WeightSlider(
                        weight: _beratBadan,
                        controller: _bbController,
                        onChanged: (value) =>
                            setState(() => _beratBadan = value),
                      ),
                      const SizedBox(height: 20),

                      // Activity Level
                      _buildActivityDropdown(),
                      const SizedBox(height: 20),

                      // Diet Goal
                      _buildDietGoalDropdown(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background(context).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border(context),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.textSecondary(context),
                    size: 22,
                  ),
                ),
              ),
              Text(
                'Data Pribadi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick and save profile photo
  Future<void> _pickProfilePhoto() async {
    final photoPath = await ImagePickerService().pickProfilePhoto(context);
    if (photoPath != null && mounted) {
      await ref.read(userProvider.notifier).updateProfilePhoto(photoPath);
    }
  }

  Widget _buildAvatarSection() {
    final userState = ref.watch(userProvider);
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfilePhoto,
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.isDark(context)
                        ? const Color(0xFF27272A)
                        : const Color(0xFFE2E8F0),
                    border: Border.all(
                      color: AppColors.card(context),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: userState.profilePhoto != null
                      ? ClipOval(
                          child: Image.file(
                            File(userState.profilePhoto!),
                            fit: BoxFit.cover,
                            width: 96,
                            height: 96,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person,
                              color: AppColors.textSecondary(context),
                              size: 40,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.person,
                            color: AppColors.textSecondary(context),
                            size: 40,
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF60A5FA),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background(context),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF60A5FA).withValues(alpha: 0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.isDark(context)
                          ? const Color(0xFF09090B)
                          : Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ketuk untuk mengubah foto',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Aktivitas Harian',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context), width: 1),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedActivity,
            dropdownColor: AppColors.card(context),
            icon: Icon(
              Icons.expand_more,
              color: AppColors.textSecondary(context),
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  Icons.directions_run,
                  color: AppColors.textSecondary(context),
                  size: 22,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 50),
              filled: true,
              fillColor: AppColors.card(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.only(right: 16),
            ),
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 14,
            ),
            items: _activityLevels.keys.map((activity) {
              return DropdownMenuItem<String>(
                value: activity,
                child: Text(
                  activity,
                  style: TextStyle(color: AppColors.textPrimary(context)),
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedActivity = value!),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 8),
          child: Text(
            'Pilih tingkat aktivitas untuk menghitung kebutuhan kalori harian Anda.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDietGoalDropdown() {
    final dietOptions = ['Cutting', 'Maintenance', 'Bulking'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Tujuan Diet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context), width: 1),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedTujuanDiet,
            dropdownColor: AppColors.card(context),
            icon: Icon(
              Icons.expand_more,
              color: AppColors.textSecondary(context),
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  Icons.flag_outlined,
                  color: AppColors.textSecondary(context),
                  size: 22,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 50),
              filled: true,
              fillColor: AppColors.card(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.only(right: 16),
            ),
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 14,
            ),
            items: dietOptions.map((goal) {
              return DropdownMenuItem<String>(
                value: goal,
                child: Text(
                  goal,
                  style: TextStyle(color: AppColors.textPrimary(context)),
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedTujuanDiet = value!),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 8),
          child: Text(
            _dietDescriptions[_selectedTujuanDiet] ?? '',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.background(context).withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _simpanDanLanjut,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF60A5FA),
            foregroundColor: const Color(0xFF09090B),
            disabledBackgroundColor: const Color(
              0xFF60A5FA,
            ).withValues(alpha: 0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.isDark(context)
                          ? const Color(0xFF09090B)
                          : Colors.white,
                    ),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.check, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}
