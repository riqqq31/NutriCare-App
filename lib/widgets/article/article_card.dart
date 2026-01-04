import 'package:flutter/material.dart';

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
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x0DFFFFFF), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
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
                border: Border.all(color: const Color(0x0DFFFFFF), width: 1),
                color: const Color(0xFF27272A),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article['image_url'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF27272A),
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
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF8FAFC),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    article['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
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
