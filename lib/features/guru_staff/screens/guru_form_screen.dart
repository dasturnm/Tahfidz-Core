import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahfidz_core/services/auth_service.dart';
import 'package:tahfidz_core/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GuruFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? guru; // Jika null = Tambah, Jika ada = Edit
  const GuruFormScreen({super.key, this.guru});

  @override
  ConsumerState<GuruFormScreen> createState() => _GuruFormScreenState();
}

class _GuruFormScreenState extends ConsumerState<GuruFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _passwordController = TextEditingController(); // Controller Password Utama

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // DEFENSIVE CODING: Mencegah error 'Null is not subtype of String' saat Edit
    if (widget.guru != null) {
      _namaController.text = widget.guru!['nama_lengkap'] ?? '';
      _emailController.text = widget.guru!['email'] ?? '';
      _noHpController.text = widget.guru!['no_hp'] ?? '';
      // Password tidak diisi saat edit
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _simpanGuru() async {
    if (!_formKey.currentState!.validate()) return;

    // 1. Ambil Data Admin & Validasi Lembaga ID
    final adminProfile = ref.read(authProvider).profile;

    // Debugging: Cek data admin di console
    // print("DEBUG ADMIN PROFILE: $adminProfile");

    if (adminProfile == null || adminProfile['lembaga_id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error Fatal: Akun Admin tidak memiliki ID Lembaga. Hubungi Super Admin.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop proses agar tidak crash
    }

    final String lembagaId = adminProfile['lembaga_id']; // Aman di-cast ke String

    setState(() => _isLoading = true);

    try {
      if (widget.guru == null) {
        // --- PROSES TAMBAH GURU (Create User Auth) ---
        await ref.read(authServiceProvider).registerGuru(
          nama: _namaController.text,
          email: _emailController.text,
          noHp: _noHpController.text,
          password: _passwordController.text,
          lembagaId: lembagaId, // Kirim ID yang sudah divalidasi
        );

        if (!mounted) return;
        _showSuccessDialog();
      } else {
        // --- PROSES EDIT (Update Profile Database Saja) ---
        await Supabase.instance.client.from('profiles').update({
          'nama_lengkap': _namaController.text,
          'no_hp': _noHpController.text,
          // Email tidak diupdate di sini karena terkait Auth
        }).eq('id', widget.guru!['id']);

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data guru berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF10B981)),
            SizedBox(width: 10),
            Text("Berhasil!"),
          ],
        ),
        content: Text(
          "Guru berhasil didaftarkan.\n\n"
              "Email: ${_emailController.text}\n"
              "Password: ${_passwordController.text}\n\n"
              "Silakan berikan data ini ke guru terkait. Admin akan otomatis keluar untuk keamanan.",
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("OK, Login Kembali", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cek Mode: Edit atau Tambah?
    final isEditMode = widget.guru != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Guru" : "Tambah Guru"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Nama Lengkap
              _buildField(_namaController, "Nama Lengkap", Icons.person),
              const SizedBox(height: 16),

              // 2. Email (Read Only jika Edit)
              _buildField(
                _emailController,
                "Email Guru",
                Icons.email,
                enabled: !isEditMode, // Matikan jika edit
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // 3. No HP
              _buildField(
                _noHpController,
                "Nomor HP",
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // 4. Password (HANYA MUNCUL JIKA TAMBAH BARU)
              if (!isEditMode) ...[
                _buildField(
                  _passwordController,
                  "Password Sementara",
                  Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 8),
                Text(
                  "*Password wajib diisi untuk akun baru",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],

              const SizedBox(height: 40),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanGuru,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    isEditMode ? "Simpan Perubahan" : "Daftarkan Guru",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        bool enabled = true,
        bool isPassword = false,
        TextInputType? keyboardType,
      }) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
      ),
      // Validasi Aman (Cek Null)
      validator: (v) {
        if (v == null || v.isEmpty) {
          return "$label wajib diisi";
        }
        if (isPassword && v.length < 6) {
          return "Password minimal 6 karakter";
        }
        return null;
      },
    );
  }
}