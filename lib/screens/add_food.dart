import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../providers/user_provider.dart';
import '../providers/food_log_provider.dart';
import '../services/database_helper.dart';
import '../widgets/food/food_card.dart';
import 'add_custom_food_screen.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const AddFoodScreen({super.key, this.onBack});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  // State variables
  List<Map<String, dynamic>> _searchResults = [];
  final List<Map<String, dynamic>> _selectedFoods = [];
  List<Map<String, dynamic>> _recentFoods = [];
  List<Map<String, dynamic>> _favoriteFoods = [];
  Set<String> _favoritesSet = {};

  bool _isSearching = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final userId = ref.read(userProvider).id;

      if (userId != null) {
        final recent = await DatabaseHelper.instance.getRecentFoods(userId);
        final favorite = await DatabaseHelper.instance.getUserFavorites(userId);

        if (mounted) {
          setState(() {
            _recentFoods = recent;
            _favoriteFoods = List<Map<String, dynamic>>.from(favorite);
            _favoritesSet = favorite.map((f) => f['nama'] as String).toSet();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  Future<void> _reloadFavorites() async {
    final userId = ref.read(userProvider).id;
    if (userId != null) {
      final favorite = await DatabaseHelper.instance.getUserFavorites(userId);
      if (mounted) {
        setState(() {
          _favoriteFoods = List<Map<String, dynamic>>.from(favorite);
          _favoritesSet = favorite.map((f) => f['nama'] as String).toSet();
        });
      }
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> food) async {
    try {
      final userId = ref.read(userProvider).id;
      if (userId == null) return;

      final foodName = food['nama'] as String;
      final isFavorited = _favoritesSet.contains(foodName);

      if (isFavorited) {
        await DatabaseHelper.instance.removeFromFavorites(userId, foodName);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$foodName dihapus dari favorit'),
              backgroundColor: const Color(0xFF64748B),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        final result = await DatabaseHelper.instance.addToFavorites(
          userId: userId,
          nama: foodName,
          kalori: (food['kalori'] as int? ?? 0),
          protein: (food['protein'] as num? ?? 0).toDouble(),
          karbo: (food['karbo'] as num? ?? 0).toDouble(),
          lemak: (food['lemak'] as num? ?? 0).toDouble(),
          porsiDesc: food['porsi_desc'] as String?,
          image: food['image'] as String?,
        );

        if (result != -1 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$foodName ditambahkan ke favorit'),
              backgroundColor: const Color(0xFF22C55E),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }

      await _reloadFavorites();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _searchFood(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final results = await DatabaseHelper.instance.searchMakanan(keyword);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  int get _totalCalories {
    return _selectedFoods.fold(
      0,
      (sum, food) => sum + (food['kalori'] as int? ?? 0),
    );
  }

  void _addToSelected(Map<String, dynamic> food) {
    setState(() {
      _selectedFoods.add({...food, 'porsi': 1.0});
    });
  }

  void _navigateToCustomFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCustomFoodScreen()),
    );
    if (result == true) {
      // Refresh data after adding custom food
      await _loadInitialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCustomFood,
        backgroundColor: AppColors.isDark(context)
            ? AppColors.darkCard
            : AppColors.lightCard,
        foregroundColor: AppColors.textPrimary(context),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1),
        ),
        icon: const Icon(Icons.add, size: 20, color: AppColors.primary),
        label: const Text(
          'Manual',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: _searchController.text.isNotEmpty
                    ? _buildSearchResults()
                    : _buildDefaultView(),
              ),
            ],
          ),

          // Bottom Action Bar
          if (_selectedFoods.isNotEmpty) _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.background(context),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Navbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textSecondary(context),
                    ),
                    onPressed: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Tambah Makanan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer for balance
                ],
              ),
            ),

            // Search Input
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: Icon(
                      Icons.search,
                      color: AppColors.textSecondary(context),
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _searchFood,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari makanan (mis. Dada Ayam)',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.card(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Right padding
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Makanan tidak ditemukan',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100, top: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        return FoodCard(
          food: food,
          isFavorited: _favoritesSet.contains(food['nama']),
          onToggleFavorite: () => _toggleFavorite(food),
          onAdd: () => _addToSelected(food),
        );
      },
    );
  }

  Widget _buildDefaultView() {
    return Column(
      children: [
        // Tab Bar
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border(context)),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary(context),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "TERKINI"),
              Tab(text: "FAVORIT"),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Recent Content
              _recentFoods.isEmpty
                  ? _buildEmptyState("Belum ada riwayat makan")
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100, top: 16),
                      itemCount: _recentFoods.length,
                      itemBuilder: (context, index) {
                        final food = _recentFoods[index];
                        return FoodCard(
                          food: food,
                          isFavorited: _favoritesSet.contains(food['nama']),
                          onToggleFavorite: () => _toggleFavorite(food),
                          onAdd: () => _addToSelected(food),
                        );
                      },
                    ),

              // Favorites Content
              _favoriteFoods.isEmpty
                  ? _buildEmptyState("Belum ada makanan favorit")
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100, top: 16),
                      itemCount: _favoriteFoods.length,
                      itemBuilder: (context, index) {
                        final food = _favoriteFoods[index];
                        return FoodCard(
                          food: food,
                          isFavorited: true,
                          onToggleFavorite: () => _toggleFavorite(food),
                          onAdd: () => _addToSelected(food),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background(context).withValues(alpha: 0),
              AppColors.background(context),
              AppColors.background(context),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Dipilih',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$_totalCalories',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        ' kcal',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _simpanSemuaMakanan(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(
                        0xFF3B82F6,
                      ).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Future<void> _simpanSemuaMakanan(BuildContext context) async {
    try {
      final userId = ref.read(userProvider).id;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User tidak ditemukan'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
        return;
      }

      if (_selectedFoods.isEmpty) return;

      final messenger = ScaffoldMessenger.of(context);
      final foodCount = _selectedFoods.length;

      for (var food in _selectedFoods) {
        await ref
            .read(foodLogProvider.notifier)
            .addFood(
              nama: food['nama'] ?? 'Makanan',
              kalori: (food['kalori'] as int? ?? 0),
              protein: (food['protein'] as num? ?? 0).toDouble(),
              karbo: (food['karbo'] as num? ?? 0).toDouble(),
              lemak: (food['lemak'] as num? ?? 0).toDouble(),
              porsi: 1.0,
              image: food['image'] as String?,
            );
      }

      if (!mounted) return;

      setState(() {
        _selectedFoods.clear();
        _searchController.clear();
        _searchResults = [];
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text('$foodCount makanan berhasil disimpan'),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      await _loadInitialData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
