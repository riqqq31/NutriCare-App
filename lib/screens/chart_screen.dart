import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/food_log_provider.dart';
import '../widgets/charts/macro_distribution_card.dart';
import '../widgets/charts/nutrient_card.dart';
import '../widgets/charts/weekly_trend_card.dart';

class ChartScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final bool showBackButton;

  const ChartScreen({super.key, this.onBack, this.showBackButton = true});

  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = ['Harian', 'Mingguan', 'Bulanan'];

  String _formatShortDate(DateTime date) {
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return days[date.weekday % 7];
  }

  List<String> _getWeeklyDates() {
    List<String> dates = [];
    DateTime now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime dateToCheck = now.subtract(Duration(days: i));
      dates.add(_formatShortDate(dateToCheck));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final foodLogState = ref.watch(foodLogProvider);
    final userState = ref.watch(userProvider);
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);
    final weeklyDates = _getWeeklyDates();

    // Calculate macro percentages
    final totalMacros =
        foodLogState.protein + foodLogState.karbo + foodLogState.lemak;
    final proteinPercent = totalMacros > 0
        ? (foodLogState.protein / totalMacros * 100).round()
        : 0;
    final karboPercent = totalMacros > 0
        ? (foodLogState.karbo / totalMacros * 100).round()
        : 0;
    final lemakPercent = totalMacros > 0
        ? (foodLogState.lemak / totalMacros * 100).round()
        : 0;

    // Calculate target macros from targetKalori
    final targetProtein = (userState.targetKalori * 0.20 / 4)
        .round()
        .toDouble();
    final targetKarbo = (userState.targetKalori * 0.50 / 4).round().toDouble();
    final targetLemak = (userState.targetKalori * 0.30 / 9).round().toDouble();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader()),

          // Tab Selector
          SliverToBoxAdapter(child: _buildTabSelector()),

          // Macro Distribution Card - Using extracted widget
          SliverToBoxAdapter(
            child: MacroDistributionCard(
              totalCalories: foodLogState.konsumsiKalori,
              proteinPercent: proteinPercent,
              karboPercent: karboPercent,
              lemakPercent: lemakPercent,
              proteinGrams: foodLogState.protein,
              karboGrams: foodLogState.karbo,
              lemakGrams: foodLogState.lemak,
            ),
          ),

          // Detail Nutrisi Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Detail Nutrisi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
          ),

          // Nutrient Detail Cards - Using extracted widget
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  NutrientCard(
                    icon: Icons.egg_alt,
                    name: 'Protein',
                    current: foodLogState.protein,
                    target: targetProtein,
                    color: const Color(0xFF818CF8),
                  ),
                  const SizedBox(height: 12),
                  NutrientCard(
                    icon: Icons.bakery_dining,
                    name: 'Karbohidrat',
                    current: foodLogState.karbo,
                    target: targetKarbo,
                    color: const Color(0xFF60A5FA),
                  ),
                  const SizedBox(height: 12),
                  NutrientCard(
                    icon: Icons.water_drop,
                    name: 'Lemak',
                    current: foodLogState.lemak,
                    target: targetLemak,
                    color: const Color(0xFFFB923C),
                  ),
                ],
              ),
            ),
          ),

          // Weekly Trend Chart - Using extracted widget
          SliverToBoxAdapter(
            child: weeklyStatsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'Error: $error',
                    style: TextStyle(color: AppColors.textPrimary(context)),
                  ),
                ),
              ),
              data: (weeklyData) => WeeklyTrendCard(
                weeklyData: weeklyData,
                weeklyDates: weeklyDates,
                targetKalori: userState.targetKalori,
              ),
            ),
          ),

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
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik,',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Grafik Makro',
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

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context), width: 1),
        ),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTabIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.isDark(context)
                              ? const Color(0xFF27272A)
                              : const Color(0xFFF1F5F9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.textPrimary(context)
                          : AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
