import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/add_food.dart';
import 'screens/home_screen.dart';
import 'screens/input_profil_screen.dart';
import 'screens/login_screen.dart';
import 'screens/chart_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();

  runApp(const ProviderScope(child: NutriCareApp()));
}

class NutriCareApp extends ConsumerWidget {
  const NutriCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;

    return MaterialApp(
      title: 'NutriCare',
      debugShowCheckedModeBanner: false,
      theme: isDark ? _darkTheme : _lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/input_profil': (context) => const InputProfilScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_food': (context) => const AddFoodScreen(),
        '/chart': (context) => const ChartScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
      },
    );
  }

  /// Dark Theme
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF60A5FA),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF09090B),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF09090B),
      foregroundColor: Color(0xFFF8FAFC),
    ),
    cardColor: const Color(0xFF18181B),
    dividerColor: const Color(0xFF27272A),
  );

  /// Light Theme
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF60A5FA),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8FAFC),
      foregroundColor: Color(0xFF09090B),
    ),
    cardColor: const Color(0xFFFFFFFF),
    dividerColor: const Color(0xFFE2E8F0),
  );
}
