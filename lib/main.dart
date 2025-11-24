import 'package:flutter/material.dart';
import 'screens/add_food.dart';
import 'screens/input_profil_screen.dart';
import 'screens/login_screen.dart';



// ==========================================
// 1. DUMMY DATA & STATE (Sederhana)
// ==========================================


// ==========================================
// 2. MAIN ENTRY POINT
// ==========================================
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
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Warna netral
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/': (context) => const InputProfilScreen(),
        '/home': (context) => const LoginScreen(),
        '/add_food': (context) => const AddFoodScreen(),
      },
    );
  }
}

// ==========================================
// 3. SCREEN: INPUT PROFIL
// ==========================================


// ==========================================
// 4. SCREEN: HOME (DASHBOARD)
// ==========================================


// ==========================================
// 5. SCREEN: ADD FOOD
// ==========================================
