import 'package:flutter/material.dart';
import '../core/theme.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key});

  final List<Map<String, String>> articles = const [
    {
      "title": "Pentingnya Protein untuk Otot",
      "category": "Nutrisi",
      "readTime": "3 min baca",
      "content":
          "Protein adalah makronutrien esensial yang berperan penting dalam pembentukan dan perbaikan jaringan tubuh, terutama otot. Asupan protein yang cukup membantu mempercepat pemulihan setelah olahraga dan menjaga massa otot agar metabolisme tetap tinggi.",
    },
    {
      "title": "Cara Menghitung Kalori Harian",
      "category": "Tips",
      "readTime": "5 min baca",
      "content":
          "Mengetahui kebutuhan kalori harian (TDEE) adalah langkah awal diet sukses. TDEE dihitung berdasarkan BMR (Basal Metabolic Rate) dikalikan dengan faktor aktivitas. Jika ingin turun berat badan, ciptakan defisit kalori sekitar 300-500 kkal dari TDEE Anda.",
    },
    {
      "title": "Diet Sehat Tanpa Rasa Lapar",
      "category": "Diet",
      "readTime": "4 min baca",
      "content":
          "Kunci diet tanpa lapar adalah memperbanyak konsumsi serat dari sayuran dan buah, serta protein. Makanan berserat tinggi membuat perut kenyang lebih lama karena dicerna perlahan. Jangan lupa minum air putih yang cukup!",
    },
    {
      "title": "Bahaya Gula Berlebih",
      "category": "Kesehatan",
      "readTime": "3 min baca",
      "content":
          "Konsumsi gula berlebih dapat meningkatkan risiko diabetes tipe 2, obesitas, dan penyakit jantung. Batasi asupan gula tambahan maksimal 50 gram (sekitar 4 sendok makan) per hari untuk orang dewasa sehat.",
    },
    {
      "title": "Manfaat Minum Air Putih",
      "category": "Hidrasi",
      "readTime": "2 min baca",
      "content":
          "Sekitar 60% tubuh manusia terdiri dari air. Dehidrasi ringan saja bisa menurunkan konsentrasi dan energi. Minumlah minimal 8 gelas sehari, atau lebih jika Anda aktif berolahraga, untuk menjaga fungsi organ tubuh tetap optimal.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutriColors.background,
      appBar: AppBar(
        backgroundColor: NutriColors.background,
        elevation: 0,
        title: const Text(
          "Artikel Kesehatan",
          style: TextStyle(
            color: NutriColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(NutriSpacing.lg),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return _buildArticleCard(context, article, index);
        },
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context,
    Map<String, String> article,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _showArticleDetail(context, article),
      child: Container(
        margin: const EdgeInsets.only(bottom: NutriSpacing.md),
        decoration: BoxDecoration(
          color: NutriColors.surface,
          borderRadius: BorderRadius.circular(NutriRadius.lg),
          boxShadow: NutriShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder Image Gradient
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(NutriRadius.lg),
                ),
                gradient: LinearGradient(
                  colors: [
                    NutriColors.primary.withOpacity(0.8),
                    NutriColors.primaryDark.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.article_outlined,
                      size: 100,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(NutriSpacing.md),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(NutriRadius.sm),
                        ),
                        child: Text(
                          article["category"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(NutriSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article["title"]!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: NutriColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: NutriSpacing.sm),
                  Text(
                    article["content"]!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NutriColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: NutriSpacing.md),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: NutriColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article["readTime"]!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: NutriColors.textMuted,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "Baca Selengkapnya",
                        style: TextStyle(
                          color: NutriColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: NutriColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArticleDetail(BuildContext context, Map<String, String> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: NutriColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(NutriRadius.xl),
            ),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: NutriSpacing.md),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NutriColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(NutriSpacing.lg),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: NutriColors.primaryBg,
                        borderRadius: BorderRadius.circular(NutriRadius.md),
                      ),
                      child: Text(
                        article["category"]!,
                        style: const TextStyle(
                          color: NutriColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: NutriSpacing.md),
                    Text(
                      article["title"]!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: NutriColors.textPrimary,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: NutriSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: NutriColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article["readTime"]!,
                          style: const TextStyle(
                            color: NutriColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: NutriColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "02 Jan 2026",
                          style: TextStyle(color: NutriColors.textSecondary),
                        ),
                      ],
                    ),
                    const Divider(height: NutriSpacing.xxl),
                    Text(
                      article["content"]! *
                          5, // Duplicate content for demo purpose length
                      style: const TextStyle(
                        fontSize: 16,
                        color: NutriColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: NutriSpacing.xxl),
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
