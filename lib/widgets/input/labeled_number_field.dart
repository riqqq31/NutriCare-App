import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context), width: 1),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            validator: validator ?? (v) => v!.isEmpty ? 'Wajib diisi' : null,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              suffixText: suffix,
              suffixStyle: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.card(context),
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
