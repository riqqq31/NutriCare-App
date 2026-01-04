import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../widgets/article/article_card.dart';
import '../widgets/article/featured_article_card.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  int _selectedCategoryIndex = 0;

  Map<String, dynamic>? _featuredArticle;
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'Semua',
    'NUTRISI',
    'SNACK',
    'RESEP',
    'TIPS',
  ];

  final Map<String, int> _categoryColors = {
    'NUTRISI': 0xFFFB923C,
    'SNACK': 0xFF818CF8,
    'RESEP': 0xFF60A5FA,
    'TIPS': 0xFF22C55E,
  };

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);

    final featured = await DatabaseHelper.instance.getFeaturedArticle();
    final category = _selectedCategoryIndex == 0
        ? null
        : _categories[_selectedCategoryIndex];
    final articles = await DatabaseHelper.instance.getArticles(
      category: category,
    );

    setState(() {
      _featuredArticle = featured;
      _articles = articles.where((a) => a['is_featured'] != 1).toList();
      _isLoading = false;
    });
  }

  void _onCategorySelected(int index) {
    setState(() => _selectedCategoryIndex = index);
    _loadArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF60A5FA)),
            )
          : CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader()),

                // Category Filters
                SliverToBoxAdapter(child: _buildCategoryFilters()),

                // Featured Article - Using extracted widget
                SliverToBoxAdapter(
                  child: FeaturedArticleCard(
                    article: _featuredArticle,
                    onTap: () => _featuredArticle != null
                        ? _showArticleDetail(_featuredArticle!)
                        : null,
                  ),
                ),

                // Latest Articles Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Artikel Terbaru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF8FAFC),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF60A5FA),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Article List - Using extracted widget
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ArticleCard(
                        article: _articles[index],
                        categoryColors: _categoryColors,
                        onTap: () => _showArticleDetail(_articles[index]),
                      ),
                      childCount: _articles.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF09090B),
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF), width: 1)),
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
                  border: Border.all(color: const Color(0xFF27272A), width: 2),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF60A5FA), Color(0xFF818CF8)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),

              // Title
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temukan Inspirasi,',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    Text(
                      'Artikel Kesehatan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF8FAFC),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x0DFFFFFF), width: 1),
                ),
                child: const Icon(
                  Icons.search,
                  color: Color(0xFFF8FAFC),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: EdgeInsets.only(
              right: index < _categories.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => _onCategorySelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF18181B),
                  borderRadius: BorderRadius.circular(50),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0x0DFFFFFF), width: 1),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF60A5FA).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 0),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF09090B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showArticleDetail(Map<String, dynamic> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF18181B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27272A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Category Badge
                    if (article['category'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(
                            _categoryColors[article['category']] ?? 0xFF60A5FA,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article['category'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(
                              _categoryColors[article['category']] ??
                                  0xFF60A5FA,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      article['title'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF8FAFC),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Read Time
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article['read_time'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '04 Jan 2026',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32, color: Color(0xFF27272A)),

                    // Content
                    Text(
                      '${article['description']}\n\n${article['content'] ?? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFF8FAFC),
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
