import 'package:flutter/material.dart';
import 'macro_row.dart';

/// Widget card untuk menampilkan ringkasan kalori dan makro
class CalorieSummaryCard extends StatelessWidget {
  final int konsumsiKalori;
  final int targetKalori;
  final double protein;
  final double targetProtein;
  final double karbo;
  final double targetKarbo;
  final double lemak;
  final double targetLemak;

  const CalorieSummaryCard({
    super.key,
    required this.konsumsiKalori,
    required this.targetKalori,
    required this.protein,
    required this.targetProtein,
    required this.karbo,
    required this.targetKarbo,
    required this.lemak,
    required this.targetLemak,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = targetKalori > 0
        ? (konsumsiKalori / targetKalori).clamp(0.0, 1.0)
        : 0.0;

    final proteinPercentage = targetProtein > 0
        ? (protein / targetProtein).clamp(0.0, 1.0)
        : 0.0;
    final karboPercentage = targetKarbo > 0
        ? (karbo / targetKarbo).clamp(0.0, 1.0)
        : 0.0;
    final lemakPercentage = targetLemak > 0
        ? (lemak / targetLemak).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ringkasan Kalori",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$konsumsiKalori',
                        style: const TextStyle(
                          fontSize: 36,
                          color: Color(0xFFF8FAFC),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 8),
                        child: Text(
                          '/ $targetKalori kcal',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF60A5FA).withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Color(0xFF60A5FA),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${(percentage * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF60A5FA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF27272A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF60A5FA).withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sisa ${targetKalori - konsumsiKalori} kcal',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 20),
          // Macro nutrients
          MacroRow(
            icon: Icons.egg_alt,
            label: "Protein",
            value: "${protein.toInt()}g / ${targetProtein.toInt()}g",
            percentage: proteinPercentage,
            color: const Color(0xFF818CF8),
          ),
          const SizedBox(height: 20),
          MacroRow(
            icon: Icons.bakery_dining,
            label: "Karbo",
            value: "${karbo.toInt()}g / ${targetKarbo.toInt()}g",
            percentage: karboPercentage,
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(height: 20),
          MacroRow(
            icon: Icons.water_drop,
            label: "Lemak",
            value: "${lemak.toInt()}g / ${targetLemak.toInt()}g",
            percentage: lemakPercentage,
            color: const Color(0xFFFB923C),
          ),
        ],
      ),
    );
  }
}
