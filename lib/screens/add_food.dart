import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../providers/food_log_provider.dart';
import '../services/database_helper.dart';
import '../widgets/food/food_card.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
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
      color: const Color(0xFF09090B),
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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF94A3B8),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Tambah Makanan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF8FAFC),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Search Input
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 12),
                    child: Icon(
                      Icons.search,
                      color: Color(0xFF64748B),
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _searchFood,
                      style: const TextStyle(
                        color: Color(0xFFF8FAFC),
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Cari makanan (mis. Dada Ayam)',
                        hintStyle: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFF18181B),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic, color: Color(0xFF64748B)),
                    onPressed: () {},
                  ),
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
        child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xFF52525B)),
            const SizedBox(height: 16),
            Text(
              'Makanan tidak ditemukan',
              style: TextStyle(color: Colors.grey[600]),
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
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF27272A))),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF3B82F6),
            indicatorWeight: 3,
            labelColor: const Color(0xFF3B82F6),
            unselectedLabelColor: const Color(0xFF94A3B8),
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
          const Icon(Icons.history, size: 48, color: Color(0xFF52525B)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Color(0xFF71717A))),
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
              const Color(0xFF09090B).withOpacity(0),
              const Color(0xFF09090B),
              const Color(0xFF09090B),
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
                  const Text(
                    'Total Dipilih',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$_totalCalories',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                      const Text(
                        ' kcal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
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
                      shadowColor: const Color(0xFF3B82F6).withOpacity(0.4),
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
