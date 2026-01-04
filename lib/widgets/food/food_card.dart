import 'package:flutter/material.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon/Image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF27272A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Color(0xFF64748B),
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
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  food['porsi_desc'] ?? '100g',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
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
                    _buildSimpleMacro("P: ${_fmt(food['protein'])}g"),
                    const SizedBox(width: 8),
                    _buildSimpleMacro("K: ${_fmt(food['karbo'])}g"),
                    const SizedBox(width: 8),
                    _buildSimpleMacro("L: ${_fmt(food['lemak'])}g"),
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
        color: color.withOpacity(0.2),
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

  Widget _buildSimpleMacro(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF71717A),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
