import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../core/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    String user = _usernameController.text.trim();
    String pass = _passwordController.text;
    String confirmPass = _confirmPasswordController.text;

    if (user.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      _showSnackBar("Mohon lengkapi semua field", isError: true);
      return;
    }

    if (pass != confirmPass) {
      _showSnackBar("Password konfirmasi tidak cocok", isError: true);
      return;
    }

    if (pass.length < 4) {
      _showSnackBar("Password minimal 4 karakter", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    // Cek apakah username sudah ada (handled by DB constraint, returns -1 if failed)
    int id = await DatabaseHelper.instance.registerUser(user, pass);

    setState(() => _isLoading = false);

    if (id != -1) {
      if (mounted) {
        _showSnackBar("Akun berhasil dibuat! Silakan Login.");
        // Tunggu sebentar biar user baca snackbar
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context); // Kembali ke Login Screen
      }
    } else {
      _showSnackBar("Username '$user' sudah dipakai!", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? NutriColors.error : NutriColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NutriRadius.md),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              NutriColors.primaryDark,
              NutriColors.primary,
              NutriColors.accent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(NutriSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back Button (Custom)
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Icon
                  Container(
                    padding: const EdgeInsets.all(NutriSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: NutriSpacing.lg),

                  const Text(
                    "Buat Akun Baru",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "Mulai perjalanan sehatmu bersama NutriCare",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: NutriSpacing.xxl),

                  // Register Card
                  Container(
                    padding: const EdgeInsets.all(NutriSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(NutriRadius.xl),
                      boxShadow: NutriShadows.large,
                    ),
                    child: Column(
                      children: [
                        // Username Field
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: "Username",
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: NutriColors.primary,
                            ),
                            filled: true,
                            fillColor: NutriColors.surfaceAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                NutriRadius.md,
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: NutriSpacing.md),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: NutriColors.primary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: NutriColors.textMuted,
                              ),
                              onPressed: () =>
                                  setState(() => _isObscure = !_isObscure),
                            ),
                            filled: true,
                            fillColor: NutriColors.surfaceAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                NutriRadius.md,
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: NutriSpacing.md),

                        // Confirm Password Field
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _isConfirmObscure,
                          decoration: InputDecoration(
                            labelText: "Konfirmasi Password",
                            prefixIcon: const Icon(
                              Icons.lock_reset,
                              color: NutriColors.primary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmObscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: NutriColors.textMuted,
                              ),
                              onPressed: () => setState(
                                () => _isConfirmObscure = !_isConfirmObscure,
                              ),
                            ),
                            filled: true,
                            fillColor: NutriColors.surfaceAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                NutriRadius.md,
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: NutriSpacing.lg),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NutriColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  NutriRadius.md,
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "DAFTAR SEKARANG",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: NutriSpacing.lg),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah punya akun? ",
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
