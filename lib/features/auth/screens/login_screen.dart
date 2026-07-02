import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahfidz_core/features/auth/providers/auth_provider.dart' hide AuthState;
import 'package:tahfidz_core/core/widgets/app_button.dart';
import 'package:tahfidz_core/features/auth/screens/register_lembaga_screen.dart';
// Import halaman lupa password (pastikan path ini sesuai nanti)
import 'package:tahfidz_core/features/auth/screens/forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadSavedIdentity();

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        if (mounted) {
          context.go('/dashboard');
        }
      }
    });
  }

  Future<void> _loadSavedIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _identityController.text = prefs.getString('saved_identity') ?? '';
      _rememberMe = _identityController.text.isNotEmpty;
    });
  }

  void _handleLogin() async {
    final identity = _identityController.text.trim();
    final password = _passwordController.text.trim();

    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_identity', identity);
    }

    if (identity.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email/No. HP dan Password wajib diisi')),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).login(identity, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo & Title - Menggunakan Emerald Green
                const Icon(Icons.admin_panel_settings_rounded, size: 100, color: Color(0xFF10B981)),
                const SizedBox(height: 24),
                const Text(
                  "TAHFIDZ CORE",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const Text(
                  "Manajemen Ekosistem Al-Qur'an",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Input Identitas
                TextField(
                  controller: _identityController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email atau Nomor HP',
                    hintText: 'Admin pakai Email, Wali pakai No HP',
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF10B981)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Password
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF10B981)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),

                // --- CHECKBOX REMEMBER ME & LUPA PASSWORD ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (val) => setState(() => _rememberMe = val!),
                          activeColor: const Color(0xFF10B981),
                        ),
                        const Text("Ingat Saya", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: const Text(
                        "Lupa Password?",
                        style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Tombol Masuk
                AppButton(
                  text: "Masuk",
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: 16),

                // --- TOMBOL GOOGLE ---
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () => ref.read(authProvider.notifier).loginWithGoogle(),
                  icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                  label: const Text("Masuk dengan Google"),
                ),

                const SizedBox(height: 32),

                // Tombol Daftar Lembaga
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya lembaga? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterLembagaScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Daftar Sekarang",
                        style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
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
    );
  }
}