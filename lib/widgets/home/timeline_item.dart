import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/app_colors.dart';

/// Widget timeline item untuk menampilkan riwayat makanan dengan swipe-to-delete
class TimelineItem extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final int calories;
  final bool isLast;
  final int? foodId;
  final String? imageUrl; // Food image URL
  final VoidCallback? onDelete;

  const TimelineItem({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.calories,
    this.isLast = false,
    this.foodId,
    this.imageUrl,
    this.onDelete,
  });

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.card(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Hapus Makanan?',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus "$title" dari riwayat?',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Batal',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFEF4444,
                  ).withValues(alpha: 0.1),
                ),
                child: const Text(
                  'Hapus',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 60,
                  color: AppColors.border(context),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.isDark(context)
                          ? const Color(0xFF27272A)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: _buildFoodImage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$calories',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'kcal',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Wrap with Dismissible if onDelete is provided
    if (onDelete != null && foodId != null) {
      return Dismissible(
        key: Key('food_$foodId'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmDelete(context),
        onDismissed: (_) => onDelete!(),
        background: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 56),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text(
                'Hapus',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        child: content,
      );
    }

    return content;
  }

  /// Build food image widget that supports both network URLs and local files
  Widget _buildFoodImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Icon(Icons.restaurant, color: AppColors.primary, size: 24);
    }

    final isNetworkImage =
        imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://');

    if (isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: 48,
        height: 48,
        placeholder: (_, __) =>
            const Icon(Icons.restaurant, color: AppColors.primary, size: 24),
        errorWidget: (_, __, ___) =>
            const Icon(Icons.restaurant, color: AppColors.primary, size: 24),
      );
    }

    // Local file
    final file = File(imageUrl!);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: 48,
        height: 48,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.restaurant, color: AppColors.primary, size: 24),
      );
    }

    return const Icon(Icons.restaurant, color: AppColors.primary, size: 24);
  }
}
