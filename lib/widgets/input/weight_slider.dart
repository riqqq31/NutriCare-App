import 'package:flutter/material.dart';

/// Widget slider untuk memilih berat badan
class WeightSlider extends StatelessWidget {
  final double weight;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const WeightSlider({
    super.key,
    required this.weight,
    this.min = 40,
    this.max = 150,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Berat Badan',
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
                    weight.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF60A5FA),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      'kg',
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
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: const Color(0xFF60A5FA),
              inactiveTrackColor: const Color(0xFF27272A),
              thumbColor: const Color(0xFF60A5FA),
              overlayColor: const Color(0xFF60A5FA).withOpacity(0.2),
            ),
            child: Slider(
              value: weight,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min.toInt()}kg',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              Text(
                '${max.toInt()}kg',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
