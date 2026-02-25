import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahfidz_core/services/auth_service.dart';
import 'package:tahfidz_core/features/management_lembaga/providers/app_context_provider.dart'; // Tambahkan ini
import 'package:tahfidz_core/features/management_lembaga/providers/lembaga_provider.dart';
import 'package:tahfidz_core/features/guru_staff/providers/penugasan_staf_provider.dart';
import 'package:tahfidz_core/features/guru_staff/providers/staff_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? staff; // Jika null = Tambah, Jika ada = Edit
  const StaffFormScreen({super.key, this.staff}); // Perbaikan sintaks constructor

  @override
  ConsumerState<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends ConsumerState<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _tglBergabungController = TextEditingController(); // FIX: Controller Kalender
  final _passwordController = TextEditingController(); // Controller Password Utama

  // State untuk Dropdown
  String? _selectedCabangId;
  String? _selectedJabatanId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // DEFENSIVE CODING: Mencegah error 'Null is not subtype of String' saat Edit
    if (widget.staff != null) {
      _namaController.text = widget.staff!['nama_lengkap'] ?? '';
      _emailController.text = widget.staff!['email'] ?? '';
      _noHpController.text = widget.staff!['no_hp'] ?? '';
      _tglBergabungController.text = widget.staff!['tanggal_bergabung'] ?? ''; // Ambil data lama jika ada
      // Password tidak diisi saat edit
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _tglBergabungController.dispose(); // Dispose controller baru
    _passwordController.dispose();
    super.dispose();
  }

  void _simpanStaff() async {
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

    // FIX: Tambahkan pengecekan manual untuk Jabatan guna menghindari Null Check Operator Crash
    if (widget.staff == null && _selectedJabatanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Silakan pilih jabatan terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.staff == null) {
        // --- PROSES TAMBAH STAFF BARU (Create User Auth) ---
        final String? targetUserId = await ref.read(authServiceProvider).registerGuru(
          nama: _namaController.text,
          email: _emailController.text,
          noHp: _noHpController.text,
          password: _passwordController.text,
          lembagaId: lembagaId,
        );

        // --- PROSES PENUGASAN (Link ke Cabang & Jabatan) ---
        if (targetUserId != null) {
          // Menggunakan variabel lokal untuk memastikan safety dari Null Check Operator
          final String? finalCabangId = (_selectedCabangId == null || _selectedCabangId!.isEmpty) ? null : _selectedCabangId;
          final String finalJabatanId = _selectedJabatanId!;

          await ref.read(penugasanStafProvider.notifier).tambahPenugasan(
            stafId: targetUserId,
            cabangId: finalCabangId,
            jabatanId: finalJabatanId,
          );

          // FIX: Update profile tambahan (untuk data seperti tanggal bergabung)
          await Supabase.instance.client.from('profiles').update({
            'tanggal_bergabung': _tglBergabungController.text.isEmpty ? null : _tglBergabungController.text,
            'nama_lengkap': _namaController.text,
            'no_hp': _noHpController.text,
          }).eq('id', targetUserId);

          // Refresh list agar staff baru muncul
          ref.invalidate(staffListProvider);
          // Beri jeda sedikit agar provider menyelesaikan sinkronisasi
          await Future.delayed(const Duration(milliseconds: 500));
        }

        if (!mounted) return;
        _showSuccessDialog();
      } else {
        // --- PROSES EDIT (Update Profile Database Saja) ---
        await Supabase.instance.client.from('profiles').update({
          'nama_lengkap': _namaController.text,
          'no_hp': _noHpController.text,
          'tanggal_bergabung': _tglBergabungController.text.isEmpty ? null : _tglBergabungController.text,
        }).eq('id', widget.staff!['id']);

        // Refresh list agar perubahan muncul
        ref.invalidate(staffListProvider);

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data staff berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // FIX: Ubah SnackBar menjadi Dialog Pop-up agar error selalu terlihat jelas
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text("Gagal Menyimpan", style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            )
          ],
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
          "Staff baru berhasil didaftarkan.\n\n"
              "Email: ${_emailController.text}\n"
              "Password: ${_passwordController.text}\n\n"
              "Silakan berikan data ini ke staff terkait.",
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke list
            },
            child: const Text("Selesai", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.staff != null;

    return AbsorbPointer(
      absorbing: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(isEditMode ? "Edit Staff" : "Tambah Staff"),
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
                if (isEditMode) ...[
                  Center(
                    child: Hero(
                      tag: 'profile_${widget.staff!['id']}',
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            (() {
                              final initials = _namaController.text.trim().split(' ').where((n) => n.isNotEmpty).map((n) => n[0]).join('');
                              return initials.toUpperCase().substring(0, initials.length >= 2 ? 2 : initials.length);
                            })(),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                _buildField(_namaController, "Nama Lengkap", Icons.person),
                const SizedBox(height: 16),

                _buildField(
                  _emailController,
                  "Email Staff",
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

                // FIX: Field Kalender (Read Only + Tap Picker)
                TextFormField(
                  controller: _tglBergabungController,
                  readOnly: true,
                  decoration: _inputDecoration("Tanggal Bergabung", Icons.calendar_month),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _tglBergabungController.text = picked.toIso8601String().split('T')[0]);
                    }
                  },
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
                    onPressed: _isLoading ? null : _simpanStaff,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      isEditMode ? "Simpan Perubahan" : "Daftarkan Staff",
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

    return DropdownButtonFormField<String?>( // FIX: String?
      decoration: _inputDecoration("Pilih Cabang / Lokasi Tugas", Icons.business),
      initialValue: _selectedCabangId,
      // FIX: Memberikan opsi Kantor Pusat secara eksplisit di posisi paling atas
      items: [
        const DropdownMenuItem<String?>( // FIX: String?
          value: null,
          child: Text("Kantor Pusat (Pusat Lembaga)"),
        ),
        ...cabangs.map((c) => DropdownMenuItem<String?>( // FIX: String?
          value: c.id.toString(),
          child: Text(c.namaCabang),
        )),
      ],
      onChanged: (val) => setState(() => _selectedCabangId = val),
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
      initialValue: _selectedJabatanId, // FIX: Menggunakan initialValue
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