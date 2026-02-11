import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahfidz_core/services/auth_service.dart';

class RegisterLembagaScreen extends ConsumerStatefulWidget {
  const RegisterLembagaScreen({super.key});

  @override
  ConsumerState<RegisterLembagaScreen> createState() => _RegisterLembagaScreenState();
}

class _RegisterLembagaScreenState extends ConsumerState<RegisterLembagaScreen> {
  final _namaLembaga = TextEditingController();
  final _namaAdmin = TextEditingController();
  final _emailAdmin = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    setState(() => _isLoading = true);
    try {
      // Menggunakan data yang sudah dibersihkan (trim) otomatis di service
      await ref.read(authServiceProvider).registerLembaga(
        namaLembaga: _namaLembaga.text,
        namaAdmin: _namaAdmin.text,
        emailAdmin: _emailAdmin.text,
        password: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran Berhasil! Silakan Login.'))
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Daftar Lembaga Baru"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.app_registration_rounded, size: 80, color: Color(0xFF10B981)),
            const SizedBox(height: 16),
            const Text(
              "Mulai Digitalisasi Tahfidz",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text("Lengkapi data lembaga Anda di bawah ini", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            _buildTextField(_namaLembaga, "Nama Lembaga", Icons.school_outlined),
            const SizedBox(height: 16),
            _buildTextField(_namaAdmin, "Nama Lengkap Admin", Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(_emailAdmin, "Email Admin", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(_password, "Password", Icons.lock_outline, isPassword: true),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Daftar Sekarang", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
      ),
    );
  }
}