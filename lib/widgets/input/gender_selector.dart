import 'package:flutter/material.dart';

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
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Jenis Kelamin',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption('Laki-laki', Icons.male, 'Pria'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption('Perempuan', Icons.female, 'Wanita'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String value, IconData icon, String label) {
    final isSelected = selectedGender == value;
    return GestureDetector(
      onTap: () => onGenderChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF60A5FA).withOpacity(0.1)
              : const Color(0xFF18181B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF60A5FA)
                : const Color(0x1AFFFFFF),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF60A5FA)
                  : const Color(0xFF94A3B8),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF60A5FA)
                    : const Color(0xFFF8FAFC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
