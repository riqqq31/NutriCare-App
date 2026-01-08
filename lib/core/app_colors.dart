import 'package:flutter/material.dart';

/// Centralized app colors that respond to theme mode
class AppColors {
  // Private constructor
  AppColors._();

  // ===== DARK MODE COLORS =====
  static const Color darkBackground = Color(0xFF09090B);
  static const Color darkCard = Color(0xFF18181B);
  static const Color darkBorder = Color(0xFF27272A);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ===== LIGHT MODE COLORS =====
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF09090B);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // ===== ACCENT COLORS (sama untuk light/dark) =====
  static const Color primary = Color(0xFF60A5FA);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color purple = Color(0xFF818CF8);
  static const Color orange = Color(0xFFFB923C);

  /// Get background color based on theme brightness
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  /// Get card color based on theme brightness
  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : lightCard;
  }

  /// Get border color based on theme brightness
  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : lightBorder;
  }

  /// Get primary text color based on theme brightness
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }

  /// Get secondary text color based on theme brightness
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  /// Check if current theme is dark
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
