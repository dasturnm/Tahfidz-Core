import 'dart:io'; // Ditambahkan untuk cek ukuran file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Wajib tambah ini di pubspec.yaml
import '../providers/app_context_provider.dart';
import '../models/lembaga_model.dart';

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
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
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

  // --- FUNGSI BARU: UPLOAD LOGO ---
  Future<void> _pickAndUploadLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image == null) return;

    // VALIDASI: Cek ukuran file maksimal 1MB
    final file = File(image.path);
    final fileSizeInBytes = file.lengthSync();
    if (fileSizeInBytes > 1 * 1024 * 1024) { // 1 MB
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ukuran foto maksimal 1MB. Silakan pilih foto lain."), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Panggil fungsi upload di notifier (kita akan buat ini di app_context_provider)
      await ref.read(appContextProvider.notifier).uploadLembagaLogo(image.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logo berhasil diperbarui!"), backgroundColor: Color(0xFF10B981)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload logo: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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

      if (!mounted) return;

      setState(() => _isEditMode = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil lembaga berhasil diperbarui!"),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memperbarui: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch memastikan UI reaktif terhadap perubahan data di provider
    final lembaga = ref.watch(appContextProvider).lembaga;

    return Scaffold(
      backgroundColor: Colors.white,
      // Tambahkan tombol edit di AppBar agar lebih intuitif
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => setState(() {
              if (_isEditMode) _initControllers();
              _isEditMode = !_isEditMode;
            }),
            icon: Icon(_isEditMode ? Icons.close : Icons.edit_note, color: const Color(0xFF10B981)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: lembaga?.logoUrl != null ? NetworkImage(lembaga!.logoUrl!) : null,
                          child: lembaga?.logoUrl == null
                              ? const Icon(Icons.mosque, size: 50, color: Color(0xFF10B981))
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF10B981),
                            child: _isSaving
                                ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : IconButton(
                              icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              onPressed: _pickAndUploadLogo,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // INSTRUKSI VISUAL
                    if (_isEditMode || lembaga?.logoUrl == null) ...[
                      const SizedBox(height: 12),
                      const Text(
                        "Format: JPG/PNG, Maksimal: 1MB",
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (!_isEditMode) _buildProfileView(lembaga),

              if (_isEditMode) ...[
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
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileView(LembagaModel? lembaga) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                lembaga?.namaLembaga ?? 'Nama Lembaga Belum Diatur',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "ID: ${lembaga?.id ?? '-'}",
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildInfoCard("KONTAK & ALAMAT", [
          _infoTile(Icons.email_outlined, "Email Resmi", lembaga?.emailOfficial ?? '-'),
          _infoTile(Icons.phone_android, "WhatsApp Official", lembaga?.kontak ?? '-'),
          _infoTile(Icons.map_outlined, "Alamat Pusat", lembaga?.alamat ?? '-'),
        ]),
        const SizedBox(height: 20),
        _buildInfoCard("FILOSOFI LEMBAGA", [
          _infoTile(Icons.auto_awesome_outlined, "Visi", lembaga?.visi ?? '-'),
          _infoTile(Icons.flag_outlined, "Misi", lembaga?.misi ?? '-'),
        ]),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF10B981)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
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