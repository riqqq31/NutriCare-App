import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/app_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;

  // --- LOGIKA LOGIN UTAMA ---
  void _login() async {
    String user = _usernameController.text;
    String pass = _passwordController.text;

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi username & password dulu!")),
      );
      return;
    }

    // 1. Cek ke Database SQLite
    var userData = await DatabaseHelper.instance.loginUser(user, pass);

    if (userData != null) {
      // BERHASIL LOGIN!

      // 2. Simpan Data User ke AppData (Session)
      final appData = AppData();
      appData.activeUserId = userData['id'];
      appData.nama = userData['nama'] ?? user;
      appData.gender = userData['gender'] ?? "Laki-laki";
      appData.usia = userData['usia'] ?? 25;
      appData.beratBadan = (userData['berat'] ?? 0).toDouble();
      appData.tinggiBadan = (userData['tinggi'] ?? 0).toDouble();
      appData.aktivitas = userData['aktivitas'] ?? "Jarang Olahraga";

      // Hitung ulang target kalori (TDEE) kalau data ada
      if (appData.beratBadan > 0) {
        _hitungUlangTargetKalori(appData);
      }

      // 3. CEK: Profil udah diisi belum?
      if (appData.beratBadan == 0 || appData.tinggiBadan == 0) {
        // Belum isi profil -> Lempar ke Halaman Input Profil
        if (mounted) Navigator.pushReplacementNamed(context, '/input_profil');
      } else {
        // Udah lengkap -> Langsung ke Home
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      // Gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Username atau Password salah!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _hitungUlangTargetKalori(AppData appData) {
    double bmr =
        (10 * appData.beratBadan) +
        (6.25 * appData.tinggiBadan) -
        (5 * appData.usia);
    if (appData.gender == "Laki-laki") {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    // Faktor Aktivitas Sederhana (Default Sedenter)
    double factor = 1.2;
    if (appData.aktivitas.contains("Ringan")) factor = 1.375;
    if (appData.aktivitas.contains("Sedang")) factor = 1.55;
    if (appData.aktivitas.contains("Berat")) factor = 1.725;

    appData.targetKalori = (bmr * factor).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_dining_rounded,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                "NutriCare",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "MASUK",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text("Daftar di sini"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
