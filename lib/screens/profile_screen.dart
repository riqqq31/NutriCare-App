import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../providers/food_log_provider.dart';
import '../widgets/profile/stat_card.dart';
import '../widgets/profile/profile_menu_item.dart';
import '../widgets/profile/target_diet_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final foodLogState = ref.watch(foodLogProvider);

    // Calculate progress
    final calorieProgress = userState.targetKalori > 0
        ? (foodLogState.konsumsiKalori / userState.targetKalori).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF09090B).withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0x0DFFFFFF), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF8FAFC),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF18181B),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x0DFFFFFF),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
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
          Stack(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF27272A), width: 4),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF60A5FA), Color(0xFF818CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF60A5FA).withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white, size: 50),
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
                      color: const Color(0xFF09090B),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF09090B),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Name
          Text(
            userState.nama.isNotEmpty ? userState.nama : 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 4),

          // Join Date
          const Text(
            'Bergabung sejak Januari 2024',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'AKUN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ProfileMenuItem(
            icon: Icons.person,
            title: 'Data Pribadi',
            subtitle: 'Nama, Email, Password',
            onTap: () => Navigator.pushNamed(context, '/input_profil'),
          ),
          const SizedBox(height: 12),
          ProfileMenuItem(
            icon: Icons.notifications,
            title: 'Notifikasi',
            subtitle: 'Pengingat Makan, Update',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          ProfileMenuItem(
            icon: Icons.health_and_safety,
            title: 'Kesehatan',
            subtitle: 'Sinkronisasi Apple Health',
            onTap: () {},
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
                  color: const Color(0xFFEF4444).withOpacity(0.2),
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
          const Text(
            'Versi 1.0.4 (Build 2024)',
            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
