import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';

/// Widget card untuk menampilkan item makanan dengan info nutrisi
class FoodCard extends StatelessWidget {
  final Map<String, dynamic> food;
  final bool isFavorited;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAdd;

  const FoodCard({
    super.key,
    required this.food,
    required this.isFavorited,
    required this.onToggleFavorite,
    required this.onAdd,
  });

  String _fmt(dynamic val) {
    if (val == null) return "0";
    if (val is int) return val.toString();
    if (val is double) {
      return val.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    }
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = food['image'] as String?;
    // Check if URL is valid (HTTP/HTTPS) or local file
    final isNetworkImage =
        imageUrl != null &&
        imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
    final isLocalImage =
        imageUrl != null &&
        imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http') &&
        File(imageUrl).existsSync();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.isDark(context)
                  ? const Color(0xFF27272A)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: isNetworkImage
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.restaurant,
                      color: AppColors.textSecondary(context),
                      size: 24,
                    ),
                  )
                : isLocalImage
                ? Image.file(
                    File(imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.restaurant,
                      color: AppColors.textSecondary(context),
                      size: 24,
                    ),
                  )
                : Icon(
                    Icons.restaurant,
                    color: AppColors.textSecondary(context),
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),

          // Info & Macros
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['nama'] ?? 'Tanpa Nama',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  food['porsi_desc'] ?? '100g',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),

                // Macros Row
                Row(
                  children: [
                    _buildMacroPill(
                      "${food['kalori']} kcal",
                      const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    _buildSimpleMacro(context, "P: ${_fmt(food['protein'])}g"),
                    const SizedBox(width: 8),
                    _buildSimpleMacro(context, "K: ${_fmt(food['karbo'])}g"),
                    const SizedBox(width: 8),
                    _buildSimpleMacro(context, "L: ${_fmt(food['lemak'])}g"),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons (Favorite + Add)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Favorite Button
              IconButton(
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorited ? Icons.star : Icons.star_border,
                  color: const Color(0xFFFBBF24),
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 4),
              // Add Button
              IconButton(
                onPressed: onAdd,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF3B82F6),
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSimpleMacro(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary(context),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
