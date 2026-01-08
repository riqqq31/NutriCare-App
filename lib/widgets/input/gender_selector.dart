import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// Widget untuk memilih gender dengan dua opsi (pria/wanita)
class GenderSelector extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Jenis Kelamin',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                context,
                'Laki-laki',
                Icons.male,
                'Pria',
                const Color(0xFF60A5FA), // Warna Biru
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption(
                context,
                'Perempuan',
                Icons.female,
                'Wanita',
                const Color(0xFFF472B6), // Warna Pink
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(
    BuildContext context,
    String value,
    IconData icon,
    String label,
    Color activeColor,
  ) {
    final isSelected = selectedGender == value;
    return GestureDetector(
      onTap: () => onGenderChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border(context),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? activeColor
                  : AppColors.textSecondary(context),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? activeColor
                    : AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
