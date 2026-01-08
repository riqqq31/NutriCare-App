import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/food_log_provider.dart';
import '../providers/theme_provider.dart';
import '../services/image_picker_service.dart';
import '../widgets/profile/stat_card.dart';
import '../widgets/profile/profile_menu_item.dart';
import '../widgets/profile/target_diet_card.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  /// Pick and save profile photo
  Future<void> _pickProfilePhoto() async {
    final photoPath = await ImagePickerService().pickProfilePhoto(context);
    if (photoPath != null && mounted) {
      await ref.read(userProvider.notifier).updateProfilePhoto(photoPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final foodLogState = ref.watch(foodLogProvider);

    // Calculate progress
    final calorieProgress = userState.targetKalori > 0
        ? (foodLogState.konsumsiKalori / userState.targetKalori).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader()),

          // Profile Avatar & Name
          SliverToBoxAdapter(child: _buildProfileHeader(userState)),

          // Stats Cards - Using extracted widget
          SliverToBoxAdapter(child: _buildStatsCards(userState)),

          // Target Diet Card - Using extracted widget
          SliverToBoxAdapter(
            child: TargetDietCard(
              targetKalori: userState.targetKalori,
              targetProtein: userState.targetProtein.toInt(),
              targetKarbo: userState.targetKarbo.toInt(),
              targetLemak: userState.targetLemak.toInt(),
              aktivitas: userState.aktivitas,
              calorieProgress: calorieProgress,
              onEditTap: () => Navigator.pushNamed(context, '/input_profil'),
            ),
          ),

          // Menu Section - Using extracted widget
          SliverToBoxAdapter(child: _buildMenuSection()),

          // Logout Button
          SliverToBoxAdapter(child: _buildLogoutButton()),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final userState = ref.watch(userProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background(context).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile Avatar
              GestureDetector(
                onTap: () => _pickProfilePhoto(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.isDark(context)
                          ? const Color(0xFF27272A)
                          : const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                    gradient: userState.profilePhoto == null
                        ? const LinearGradient(
                            colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                          )
                        : null,
                  ),
                  child: userState.profilePhoto != null
                      ? ClipOval(
                          child: Image.file(
                            File(userState.profilePhoto!),
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Akun Saya,',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserState userState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
      child: Column(
        children: [
          // Avatar with Edit Button
          GestureDetector(
            onTap: () => _pickProfilePhoto(),
            child: Stack(
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.isDark(context)
                          ? const Color(0xFF27272A)
                          : const Color(0xFFE2E8F0),
                      width: 4,
                    ),
                    gradient: userState.profilePhoto == null
                        ? const LinearGradient(
                            colors: [Color(0xFF60A5FA), Color(0xFF818CF8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF60A5FA).withValues(alpha: 0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: userState.profilePhoto != null
                      ? ClipOval(
                          child: Image.file(
                            File(userState.profilePhoto!),
                            fit: BoxFit.cover,
                            width: 112,
                            height: 112,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF60A5FA),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background(context),
                        width: 3,
                      ),
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
          const SizedBox(height: 20),

          // Name
          Text(
            userState.nama.isNotEmpty ? userState.nama : 'User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),

          // Join Date
          Text(
            'Bergabung sejak Januari 2024',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(UserState userState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'Berat',
              value: userState.beratBadan.round().toString(),
              unit: 'kg',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Tinggi',
              value: userState.tinggiBadan.round().toString(),
              unit: 'cm',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Umur',
              value: userState.usia.toString(),
              unit: 'th',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'AKUN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary(context),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ProfileMenuItem(
            icon: Icons.person,
            title: 'Data Pribadi',
            subtitle: 'Nama, Email, Password',
            onTap: () =>
                _showPersonalDataSheet(context, ref.read(userProvider)),
          ),
          ProfileMenuItem(
            icon: Icons.notifications,
            title: 'Notifikasi',
            subtitle: 'Pengingat Makan, Update',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'TAMPILAN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary(context),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF60A5FA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: const Color(0xFF60A5FA),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode Tampilan',
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isDark ? 'Dark Mode' : 'Light Mode',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isDark,
                  onChanged: (_) =>
                      ref.read(themeProvider.notifier).toggleTheme(),
                  activeThumbColor: const Color(0xFF60A5FA),
                  activeTrackColor: const Color(
                    0xFF60A5FA,
                  ).withValues(alpha: 0.3),
                  inactiveThumbColor: const Color(0xFFFBBF24),
                  inactiveTrackColor: const Color(
                    0xFFFBBF24,
                  ).withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              ref.read(userProvider.notifier).logout();
              ref.read(foodLogProvider.notifier).reset();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Keluar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Versi 1.0.4 (Build 2024)',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showPersonalDataSheet(BuildContext context, UserState userState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Data Pribadi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 24),
            _buildDataRow(
              context,
              Icons.person_outline,
              'Nama Lengkap',
              userState.nama,
            ),
            const SizedBox(height: 16),
            _buildDataRow(
              context,
              Icons.email_outlined,
              'Email / Username',
              userState.username,
            ),
            const SizedBox(height: 16),
            _buildDataRow(
              context,
              Icons.lock_outline,
              'Password',
              '••••••••',
              isPassword: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/input_profil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Edit Profil'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isPassword = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                  letterSpacing: isPassword ? 2 : 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
