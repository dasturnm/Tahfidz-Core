import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_context_provider.dart';

class LembagaProfileScreen extends ConsumerStatefulWidget {
  const LembagaProfileScreen({super.key});

  @override
  ConsumerState<LembagaProfileScreen> createState() => _LembagaProfileScreenState();
}

class _LembagaProfileScreenState extends ConsumerState<LembagaProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _kontakController;
  late TextEditingController _emailController;
  late TextEditingController _visiController;
  late TextEditingController _misiController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Ambil data lembaga saat ini dari provider
    final lembaga = ref.read(appContextProvider).lembaga;

    _namaController = TextEditingController(text: lembaga?.namaLembaga ?? '');
    _alamatController = TextEditingController(text: lembaga?.alamat ?? '');
    _kontakController = TextEditingController(text: lembaga?.kontak ?? '');
    _emailController = TextEditingController(text: lembaga?.emailOfficial ?? '');
    _visiController = TextEditingController(text: lembaga?.visi ?? '');
    _misiController = TextEditingController(text: lembaga?.misi ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _kontakController.dispose();
    _emailController.dispose();
    _visiController.dispose();
    _misiController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(appContextProvider.notifier).updateLembaga(
        nama: _namaController.text.trim(),
        alamat: _alamatController.text.trim(),
        kontak: _kontakController.text.trim(),
        emailOfficial: _emailController.text.trim(),
        visi: _visiController.text.trim(),
        misi: _misiController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil lembaga berhasil diperbarui!"),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memperbarui: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEKSI VISUAL (LOGO PLACEHOLDER) ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[100],
                      child: const Icon(Icons.mosque, size: 50, color: Color(0xFF10B981)),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF10B981),
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                          onPressed: () {
                            // Logic upload logo akan kita buat nanti
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- FORM INPUT ---
              _buildLabel("Nama Lembaga"),
              TextFormField(
                controller: _namaController,
                decoration: _inputDecor("Masukkan nama lembaga", Icons.business),
                validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 20),

              _buildLabel("Email Resmi"),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecor("email@lembaga.com", Icons.email),
              ),
              const SizedBox(height: 20),

              _buildLabel("Kontak / WhatsApp"),
              TextFormField(
                controller: _kontakController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecor("Nomor telepon aktif", Icons.phone),
              ),
              const SizedBox(height: 20),

              _buildLabel("Alamat Pusat"),
              TextFormField(
                controller: _alamatController,
                maxLines: 2,
                decoration: _inputDecor("Alamat lengkap lembaga", Icons.location_on),
              ),
              const SizedBox(height: 20),

              _buildLabel("Visi"),
              TextFormField(
                controller: _visiController,
                maxLines: 2,
                decoration: _inputDecor("Visi lembaga", Icons.lightbulb_outline),
              ),
              const SizedBox(height: 20),

              _buildLabel("Misi"),
              TextFormField(
                controller: _misiController,
                maxLines: 4,
                decoration: _inputDecor("Misi lembaga", Icons.flag_outlined),
              ),
              const SizedBox(height: 40),

              // --- TOMBOL SIMPAN ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Simpan Perubahan",
                    style: TextStyle(
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

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  );

  InputDecoration _inputDecor(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: Colors.grey),
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
    ),
  );
}