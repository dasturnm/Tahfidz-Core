import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahfidz_core/services/auth_service.dart';
import 'package:tahfidz_core/features/management_lembaga/providers/app_context_provider.dart'; // Tambahkan ini
import 'package:tahfidz_core/features/management_lembaga/providers/lembaga_provider.dart';
import 'package:tahfidz_core/features/guru_staff/providers/penugasan_staf_provider.dart';
import 'package:tahfidz_core/features/guru_staff/providers/guru_provider.dart';
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

  // State untuk Dropdown
  String? _selectedCabangId;
  String? _selectedJabatanId;

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
    if (_isLoading) return; // FIX: Mencegah error 'Future already completed'
    if (!_formKey.currentState!.validate()) return;

    // 1. Ambil ID Lembaga dari App Context (yang sudah terbukti muncul di profil)
    final lembagaId = ref.read(appContextProvider).lembaga?.id;

    if (lembagaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: ID Lembaga tidak ditemukan. Pastikan profil lembaga sudah dimuat.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.guru == null) {
        // --- PROSES TAMBAH GURU (Create User Auth) ---
        final String? newUserId = await ref.read(authServiceProvider).registerGuru(
          nama: _namaController.text,
          email: _emailController.text,
          noHp: _noHpController.text,
          password: _passwordController.text,
          lembagaId: lembagaId,
        );

        // --- PROSES PENUGASAN (Link ke Cabang & Jabatan) ---
        if (newUserId != null) {
          await ref.read(penugasanStafProvider.notifier).tambahPenugasan(
            stafId: newUserId,
            cabangId: _selectedCabangId ?? '', // Menangani jika tidak ada cabang
            jabatanId: _selectedJabatanId!,
          );

          // Refresh list agar guru baru muncul
          ref.invalidate(guruListProvider);
        }

        if (!mounted) return;
        _showSuccessDialog();
      } else {
        // --- PROSES EDIT (Update Profile Database Saja) ---
        await Supabase.instance.client.from('profiles').update({
          'nama_lengkap': _namaController.text,
          'no_hp': _noHpController.text,
        }).eq('id', widget.guru!['id']);

        // Refresh list agar perubahan muncul
        ref.invalidate(guruListProvider);

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
              _buildField(_namaController, "Nama Lengkap", Icons.person),
              const SizedBox(height: 16),

              _buildField(
                _emailController,
                "Email Guru",
                Icons.email,
                enabled: !isEditMode,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildField(
                _noHpController,
                "Nomor HP",
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              if (!isEditMode) ...[
                _buildDropdownCabang(),
                const SizedBox(height: 16),
                _buildDropdownJabatan(),
                const SizedBox(height: 16),
              ],

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

  Widget _buildDropdownCabang() {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;

    if (lembagaId == null || lembagaId.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text("Memuat data lembaga...", style: TextStyle(color: Colors.grey, fontSize: 12)),
      );
    }

    final cabangs = ref.watch(cabangListProvider(lembagaId)).value ?? [];

    // Auto-select jika hanya ada 1 cabang (Pusat)
    if (cabangs.length == 1 && _selectedCabangId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedCabangId = cabangs.first.id);
      });
    }

    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(
          cabangs.isEmpty ? "Pusat (Tanpa Cabang)" : "Pilih Cabang",
          Icons.business
      ),
      initialValue: _selectedCabangId,
      items: cabangs.map((c) {
        return DropdownMenuItem(value: c.id.toString(), child: Text(c.namaCabang));
      }).toList(),
      onChanged: cabangs.isEmpty ? null : (val) => setState(() => _selectedCabangId = val),
      validator: (v) => (cabangs.isNotEmpty && v == null) ? "Cabang wajib dipilih" : null,
    );
  }

  Widget _buildDropdownJabatan() {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;

    if (lembagaId == null || lembagaId.isEmpty) {
      return const SizedBox.shrink();
    }

    final jabatans = ref.watch(jabatanListProvider(lembagaId)).value ?? [];
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration("Pilih Jabatan", Icons.work),
      initialValue: _selectedJabatanId,
      items: jabatans.map((j) {
        return DropdownMenuItem(value: j.id.toString(), child: Text(j.namaJabatan));
      }).toList(),
      onChanged: (val) => setState(() => _selectedJabatanId = val),
      validator: (v) => v == null ? "Jabatan wajib dipilih" : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
    );
  }
}