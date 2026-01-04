import 'package:flutter/material.dart';

/// Widget number field dengan label dan suffix
class LabeledNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String suffix;
  final String? Function(String?)? validator;

  const LabeledNumberField({
    super.key,
    required this.label,
    required this.controller,
    required this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            validator: validator ?? (v) => v!.isEmpty ? 'Wajib diisi' : null,
            style: const TextStyle(
              color: Color(0xFFF8FAFC),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              suffixText: suffix,
              suffixStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              filled: true,
              fillColor: const Color(0xFF18181B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
