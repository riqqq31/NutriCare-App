import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// Theme mode enum
enum AppThemeMode { light, dark }

/// Notifier untuk manage theme state
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final NotificationService _notificationService = NotificationService();

  ThemeNotifier() : super(AppThemeMode.dark) {
    // Load saved theme on init
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final isDark = await _notificationService.loadThemeMode();
    state = isDark ? AppThemeMode.dark : AppThemeMode.light;
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    state = state == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark;
    await _notificationService.saveThemeMode(state == AppThemeMode.dark);
  }

  /// Set specific theme
  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    await _notificationService.saveThemeMode(mode == AppThemeMode.dark);
  }

  /// Check if current theme is dark
  bool get isDark => state == AppThemeMode.dark;
}

/// Provider untuk theme state
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});
