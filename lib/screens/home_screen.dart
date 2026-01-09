import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../core/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/food_log_provider.dart';
import '../widgets/home/calorie_summary_card.dart';
import '../widgets/home/timeline_item.dart';
import 'add_food.dart';
import 'chart_screen.dart';
import 'article_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  int _selectedDayIndex = 6; // Default: hari ini (index terakhir)
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _weekDates = _generateWeekDates();
    Future.microtask(() {
      ref.read(foodLogProvider.notifier).loadTodayData();
    });
  }

  /// Generate 7 hari terakhir (hari ini di index 6)
  List<DateTime> _generateWeekDates() {
    final now = DateTime.now();
    return List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
  }

  /// Format nama hari singkat
  String _getDayName(DateTime date) {
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return days[date.weekday % 7];
  }

  /// Load data untuk tanggal yang dipilih
  void _onDateSelected(int index) {
    setState(() => _selectedDayIndex = index);
    ref.read(foodLogProvider.notifier).loadDataByDate(_weekDates[index]);
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final foodLogState = ref.watch(foodLogProvider);

    final List<Widget> pages = [
      _buildDashboardContent(userState, foodLogState),
      AddFoodScreen(onBack: () => setState(() => _currentIndex = 0)),
      const ChartScreen(showBackButton: false),
      const ArticleScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: IndexedStack(index: _currentIndex, children: pages),
      floatingActionButton: _currentIndex != 1
          ? FloatingActionButton(
              onPressed: () => setState(() => _currentIndex = 1),
              backgroundColor: AppColors.primary,
              elevation: 8,
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    // Map _currentIndex to SalomonBottomBar index (0->0, 3->1, 2->2, 4->3)
    int salomonIndex = 0;
    if (_currentIndex == 0)
      salomonIndex = 0;
    else if (_currentIndex == 3)
      salomonIndex = 1;
    else if (_currentIndex == 2)
      salomonIndex = 2;
    else if (_currentIndex == 4)
      salomonIndex = 3;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        border: Border(
          top: BorderSide(color: AppColors.border(context), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Left side nav items
              Expanded(
                child: SalomonBottomBar(
                  currentIndex: salomonIndex < 2 ? salomonIndex : -1,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.textSecondary(context),
                  onTap: (index) {
                    setState(() {
                      if (index == 0)
                        _currentIndex = 0;
                      else if (index == 1)
                        _currentIndex = 3;
                    });
                  },
                  items: [
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.dashboard_outlined),
                      activeIcon: const Icon(Icons.dashboard),
                      title: const Text('Home'),
                      selectedColor: const Color(0xFF3B82F6),
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.article_outlined),
                      activeIcon: const Icon(Icons.article),
                      title: const Text('Artikel'),
                      selectedColor: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),
              // Space for FAB
              const SizedBox(width: 72),
              // Right side nav items
              Expanded(
                child: SalomonBottomBar(
                  currentIndex: salomonIndex >= 2 ? salomonIndex - 2 : -1,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.textSecondary(context),
                  onTap: (index) {
                    setState(() {
                      if (index == 0)
                        _currentIndex = 2;
                      else if (index == 1)
                        _currentIndex = 4;
                    });
                  },
                  items: [
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.bar_chart_outlined),
                      activeIcon: const Icon(Icons.bar_chart),
                      title: const Text('Statistik'),
                      selectedColor: const Color(0xFF22C55E),
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.person_outline),
                      activeIcon: const Icon(Icons.person),
                      title: const Text('Profil'),
                      selectedColor: const Color(0xFF8B5CF6),
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

  Widget _buildDashboardContent(
    UserState userState,
    FoodLogState foodLogState,
  ) {
    return CustomScrollView(
      slivers: [
        // Header dengan date selector
        SliverAppBar(
          expandedHeight: 160,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.background(context).withValues(alpha: 0.9),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border(context),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Profile header
                    _buildProfileHeader(userState),
                    // Date selector
                    _buildDateSelector(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ringkasan Kalori Card - Using extracted widget
                CalorieSummaryCard(
                  konsumsiKalori: foodLogState.konsumsiKalori,
                  targetKalori: userState.targetKalori,
                  protein: foodLogState.protein,
                  targetProtein: userState.targetProtein,
                  karbo: foodLogState.karbo,
                  targetKarbo: userState.targetKarbo,
                  lemak: foodLogState.lemak,
                  targetLemak: userState.targetLemak,
                ),

                const SizedBox(height: 24),

                // Riwayat Hari Ini Section
                _buildHistorySection(foodLogState),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(UserState userState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selamat Pagi,",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  userState.nama.isNotEmpty ? userState.nama : "User",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(userProvider.notifier).logout();
              ref.read(foodLogProvider.notifier).reset();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: Icon(Icons.logout, color: AppColors.textPrimary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = _weekDates[index];
          final dayName = _getDayName(date);
          final isSelected = index == _selectedDayIndex;
          final isToday = index == 6;

          return GestureDetector(
            onTap: () => _onDateSelected(index),
            child: Container(
              width: 52,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isSelected
                    ? AppColors.primary
                    : isToday
                    ? AppColors.card(context)
                    : Colors.transparent,
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.border(context))
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? const Color(0xFF09090B)
                          : AppColors.textSecondary(context),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      color: isSelected
                          ? const Color(0xFF09090B)
                          : AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistorySection(FoodLogState foodLogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Riwayat Hari Ini",
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Timeline - Using extracted widget
        if (foodLogState.riwayatMakan.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                "Belum ada data makan hari ini",
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ...foodLogState.riwayatMakan.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == foodLogState.riwayatMakan.length - 1;
            final foodId = item['id'] as int?;
            return TimelineItem(
              time: item['waktu'].toString().substring(11, 16),
              title: item['nama'],
              subtitle: "Makanan",
              calories: item['kalori'],
              isLast: isLast,
              foodId: foodId,
              imageUrl: item['image'] as String?,
              onDelete: foodId != null
                  ? () => ref
                        .read(foodLogProvider.notifier)
                        .deleteFood(foodId, item)
                  : null,
            );
          }),
      ],
    );
  }
}
