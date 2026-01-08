import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// Widget card untuk menampilkan artikel dalam daftar
class ArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;
  final VoidCallback onTap;
  final Map<String, int> categoryColors;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.categoryColors = const {
      'NUTRISI': 0xFFFB923C,
      'SNACK': 0xFF818CF8,
      'RESEP': 0xFF60A5FA,
      'TIPS': 0xFF22C55E,
    },
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border(context), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: AppColors.isDark(context) ? 0.4 : 0.1,
              ),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(context), width: 1),
                color: AppColors.isDark(context)
                    ? const Color(0xFF27272A)
                    : const Color(0xFFE2E8F0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article['image_url'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.isDark(context)
                        ? const Color(0xFF27272A)
                        : const Color(0xFFE2E8F0),
                    child: Icon(
                      Icons.article,
                      color: Color(
                        categoryColors[article['category']] ?? 0xFF60A5FA,
                      ),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Read Time
                  Row(
                    children: [
                      Text(
                        article['category'] ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(
                            categoryColors[article['category']] ?? 0xFF60A5FA,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${article['read_time'] ?? ''}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    article['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    article['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
