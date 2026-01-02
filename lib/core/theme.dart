import 'package:flutter/material.dart';

/// NutriCare Design System
/// Premium color palette, typography, and component styles

class NutriColors {
  // Primary Green Gradient
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primarySoft = Color(0xFFA5D6A7);
  static const Color primaryBg = Color(0xFFE8F5E9);

  // Accent Colors
  static const Color accent = Color(0xFF00BFA5);
  static const Color accentLight = Color(0xFF64FFDA);

  // Semantic Colors
  static const Color error = Color(0xFFE53935);
  static const Color errorBg = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningBg = Color(0xFFFFF3E0);
  static const Color success = Color(0xFF43A047);
  static const Color successBg = Color(0xFFE8F5E9);

  // Neutral Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF3F4F6);

  // Macro Colors
  static const Color protein = Color(0xFFE91E63);
  static const Color carbs = Color(0xFF2196F3);
  static const Color fat = Color(0xFFFF9800);
  static const Color calories = Color(0xFF4CAF50);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class NutriSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class NutriRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

class NutriShadows {
  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get glow => [
    BoxShadow(
      color: NutriColors.primary.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}

class NutriTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: NutriColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: NutriColors.background,
      fontFamily: 'Poppins',

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: NutriColors.textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: NutriColors.textPrimary,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NutriRadius.lg),
        ),
        color: NutriColors.surface,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NutriColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: NutriSpacing.md,
          vertical: NutriSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NutriRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NutriRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NutriRadius.md),
          borderSide: const BorderSide(color: NutriColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NutriRadius.md),
          borderSide: const BorderSide(color: NutriColors.error, width: 1),
        ),
        hintStyle: const TextStyle(color: NutriColors.textMuted),
        labelStyle: const TextStyle(color: NutriColors.textSecondary),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NutriColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: NutriSpacing.lg,
            vertical: NutriSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NutriRadius.md),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NutriColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NutriColors.surface,
        selectedItemColor: NutriColors.primary,
        unselectedItemColor: NutriColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NutriRadius.md),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: NutriColors.border,
        thickness: 1,
        space: NutriSpacing.lg,
      ),
    );
  }
}

/// Reusable styled components
class NutriWidgets {
  /// Primary gradient container
  static Widget gradientCard({
    required Widget child,
    EdgeInsets? padding,
    double? borderRadius,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(NutriSpacing.lg),
      decoration: BoxDecoration(
        gradient: NutriColors.cardGradient,
        borderRadius: BorderRadius.circular(borderRadius ?? NutriRadius.xl),
        boxShadow: NutriShadows.glow,
      ),
      child: child,
    );
  }

  /// Glassmorphism card
  static Widget glassCard({
    required Widget child,
    EdgeInsets? padding,
    double? borderRadius,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(NutriSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(borderRadius ?? NutriRadius.xl),
        boxShadow: NutriShadows.medium,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: child,
    );
  }

  /// Macro nutrient badge
  static Widget macroBadge({
    required String label,
    required String value,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NutriSpacing.md,
        vertical: NutriSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(NutriRadius.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: color, size: 20),
          const SizedBox(height: NutriSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
