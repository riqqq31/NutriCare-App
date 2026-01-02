import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/add_food.dart';
import 'screens/home_screen.dart';
import 'screens/input_profil_screen.dart';
import 'screens/login_screen.dart';
import 'screens/chart_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const NutriCareApp());
}

class NutriCareApp extends StatelessWidget {
  const NutriCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriCare',
      debugShowCheckedModeBanner: false,
      theme: NutriTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/input_profil': (context) => const InputProfilScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_food': (context) => const AddFoodScreen(),
        '/chart': (context) => const ChartScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
