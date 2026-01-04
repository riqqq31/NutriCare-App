import 'package:flutter/material.dart';

/// Widget card untuk target diet dengan kalori dan makro targets
class TargetDietCard extends StatelessWidget {
  final int targetKalori;
  final int targetProtein;
  final int targetKarbo;
  final int targetLemak;
  final String aktivitas;
  final double calorieProgress;
  final VoidCallback onEditTap;

  const TargetDietCard({
    super.key,
    required this.targetKalori,
    required this.targetProtein,
    required this.targetKarbo,
    required this.targetLemak,
    required this.aktivitas,
    required this.calorieProgress,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF18181B), Color(0xFF27272A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x0DFFFFFF), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Glow
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF60A5FA).withOpacity(0.05),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Target Diet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          aktivitas.split('(').first.trim(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onEditTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF60A5FA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: const Color(0xFF60A5FA).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Ubah',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF60A5FA),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Calorie Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kalori Harian',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          targetKalori.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF8FAFC),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4, left: 4),
                          child: Text(
                            'kcal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress Bar
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: const Color(0x0DFFFFFF),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: calorieProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF60A5FA),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF60A5FA).withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Macro Targets
                Row(
                  children: [
                    Expanded(
                      child: _buildMacroTarget(
                        label: 'PROTEIN',
                        value: '${targetProtein}g',
                        color: const Color(0xFF818CF8),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: const Color(0x0DFFFFFF),
                    ),
                    Expanded(
                      child: _buildMacroTarget(
                        label: 'KARBO',
                        value: '${targetKarbo}g',
                        color: const Color(0xFF60A5FA),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: const Color(0x0DFFFFFF),
                    ),
                    Expanded(
                      child: _buildMacroTarget(
                        label: 'LEMAK',
                        value: '${targetLemak}g',
                        color: const Color(0xFFFB923C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroTarget({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
