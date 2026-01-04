import 'package:flutter/material.dart';

/// Widget timeline item untuk menampilkan riwayat makanan
class TimelineItem extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;
  final int calories;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.calories,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
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
                  color: const Color(0xFF60A5FA),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF60A5FA).withOpacity(0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(width: 1, height: 60, color: const Color(0xFF27272A)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF27272A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Color(0xFF60A5FA),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFF8FAFC),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
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
                          color: Color(0xFF60A5FA),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'kcal',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
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
  }
}
