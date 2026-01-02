import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../services/database_helper.dart';
import '../core/theme.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  Map<String, dynamic>? _selectedFood;
  double _porsi = 1.0;
  final TextEditingController _porsiController = TextEditingController(
    text: "1.0",
  );
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _porsiController.dispose();
    _searchController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutriColors.background,
      appBar: AppBar(
        backgroundColor: NutriColors.background,
        title: const Text(
          "Cari Makanan",
          style: TextStyle(
            color: NutriColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(NutriSpacing.lg),
            decoration: BoxDecoration(
              color: NutriColors.surface,
              boxShadow: NutriShadows.small,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _searchFood,
              decoration: InputDecoration(
                hintText: "Ketik nama makanan (cth: Ayam, Nasi)",
                prefixIcon: const Icon(
                  Icons.search,
                  color: NutriColors.primary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: NutriColors.textMuted,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _searchFood("");
                        },
                      )
                    : null,
                filled: true,
                fillColor: NutriColors.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(NutriRadius.md),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(NutriRadius.md),
                  borderSide: const BorderSide(
                    color: NutriColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: _selectedFood != null
                ? _buildFoodDetailView()
                : _buildSearchResultsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsView() {
    if (_searchController.text.isEmpty) {
      return _buildEmptySearchState();
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: NutriColors.primary),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(NutriSpacing.lg),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        return _buildFoodResultCard(food);
      },
    );
  }

  Widget _buildFoodResultCard(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFood = food;
          _porsi = 1.0;
          _porsiController.text = "1.0";
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: NutriSpacing.sm),
        padding: const EdgeInsets.all(NutriSpacing.md),
        decoration: BoxDecoration(
          color: NutriColors.surface,
          borderRadius: BorderRadius.circular(NutriRadius.md),
          boxShadow: NutriShadows.small,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: NutriColors.cardGradient,
                borderRadius: BorderRadius.circular(NutriRadius.sm),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: NutriSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['nama'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: NutriColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    food['porsi_desc'] ?? '1 Porsi',
                    style: const TextStyle(
                      fontSize: 12,
                      color: NutriColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: NutriSpacing.sm,
                vertical: NutriSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: NutriColors.calories.withOpacity(0.1),
                borderRadius: BorderRadius.circular(NutriRadius.sm),
              ),
              child: Text(
                "${food['kalori']} kkal",
                style: const TextStyle(
                  color: NutriColors.calories,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: NutriSpacing.sm),
            const Icon(Icons.chevron_right, color: NutriColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodDetailView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(NutriSpacing.lg),
      child: Column(
        children: [
          // Back button
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedFood = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NutriSpacing.md,
                    vertical: NutriSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: NutriColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(NutriRadius.md),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: NutriColors.textSecondary,
                      ),
                      SizedBox(width: NutriSpacing.xs),
                      Text(
                        "Kembali",
                        style: TextStyle(color: NutriColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NutriSpacing.lg),

          // Food Detail Card
          Container(
            padding: const EdgeInsets.all(NutriSpacing.lg),
            decoration: BoxDecoration(
              color: NutriColors.surface,
              borderRadius: BorderRadius.circular(NutriRadius.xl),
              boxShadow: NutriShadows.medium,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(NutriSpacing.md),
                  decoration: BoxDecoration(
                    gradient: NutriColors.cardGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: NutriSpacing.md),
                Text(
                  _selectedFood!['nama'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: NutriColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _selectedFood!['porsi_desc'] ?? '1 Porsi',
                  style: const TextStyle(color: NutriColors.textMuted),
                ),
                const SizedBox(height: NutriSpacing.lg),
                const Divider(),
                const SizedBox(height: NutriSpacing.md),

                // Nutrition Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientInfo(
                      "Kalori",
                      "${(_selectedFood!['kalori'] * _porsi).toInt()}",
                      "kkal",
                      NutriColors.calories,
                    ),
                    _buildNutrientInfo(
                      "Protein",
                      (_selectedFood!['protein'] * _porsi).toStringAsFixed(1),
                      "g",
                      NutriColors.protein,
                    ),
                    _buildNutrientInfo(
                      "Karbo",
                      (_selectedFood!['karbo'] * _porsi).toStringAsFixed(1),
                      "g",
                      NutriColors.carbs,
                    ),
                    _buildNutrientInfo(
                      "Lemak",
                      (_selectedFood!['lemak'] * _porsi).toStringAsFixed(1),
                      "g",
                      NutriColors.fat,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: NutriSpacing.lg),

          // Portion Selector
          Container(
            padding: const EdgeInsets.all(NutriSpacing.lg),
            decoration: BoxDecoration(
              color: NutriColors.surface,
              borderRadius: BorderRadius.circular(NutriRadius.lg),
              boxShadow: NutriShadows.small,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Jumlah Porsi",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: NutriColors.textPrimary,
                  ),
                ),
                const SizedBox(height: NutriSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPortionButton(Icons.remove, () => _updatePorsi(-0.5)),
                    const SizedBox(width: NutriSpacing.lg),
                    Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(
                        horizontal: NutriSpacing.md,
                        vertical: NutriSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: NutriColors.primaryBg,
                        borderRadius: BorderRadius.circular(NutriRadius.md),
                      ),
                      child: Text(
                        _porsi.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NutriColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: NutriSpacing.lg),
                    _buildPortionButton(Icons.add, () => _updatePorsi(0.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: NutriSpacing.lg),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _simpanMakanan(context),
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
                  Icon(Icons.check_circle_outline),
                  SizedBox(width: NutriSpacing.sm),
                  Text(
                    "SIMPAN KE RIWAYAT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(height: NutriSpacing.xs),
        Text(
          "$unit",
          style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: NutriColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildPortionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(NutriSpacing.md),
        decoration: BoxDecoration(
          color: NutriColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  void _updatePorsi(double delta) {
    double newValue = _porsi + delta;
    if (newValue < 0.5) newValue = 0.5;
    if (newValue > 10) newValue = 10;
    setState(() {
      _porsi = newValue;
      _porsiController.text = _porsi.toString();
    });
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(NutriSpacing.xl),
            decoration: BoxDecoration(
              color: NutriColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 48,
              color: NutriColors.textMuted,
            ),
          ),
          const SizedBox(height: NutriSpacing.md),
          const Text(
            "Cari makananmu di atas",
            style: TextStyle(
              color: NutriColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: NutriSpacing.xs),
          const Text(
            "Dataset berisi 1300+ makanan Indonesia",
            style: TextStyle(color: NutriColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(NutriSpacing.xl),
            decoration: BoxDecoration(
              color: NutriColors.warningBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 48,
              color: NutriColors.warning,
            ),
          ),
          const SizedBox(height: NutriSpacing.md),
          const Text(
            "Makanan tidak ditemukan",
            style: TextStyle(
              color: NutriColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: NutriSpacing.xs),
          const Text(
            "Coba kata kunci yang berbeda",
            style: TextStyle(color: NutriColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _simpanMakanan(BuildContext context) async {
    final appData = AppData();
    if (appData.activeUserId == null) return;

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

    appData.konsumsiKalori += (row['kalori'] as int);
    appData.riwayatMakan.insert(0, row);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: NutriSpacing.sm),
              Text("${_selectedFood!['nama']} berhasil disimpan!"),
            ],
          ),
          backgroundColor: NutriColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutriRadius.md),
          ),
        ),
      );

      setState(() {
        _selectedFood = null;
        _porsi = 1.0;
        _porsiController.text = "1.0";
        _searchController.clear();
        _searchResults = [];
      });
    }
  }
}
