import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import '../providers/kurikulum_provider.dart';

class LevelFormScreen extends ConsumerStatefulWidget {
  final String kurikulumId;
  final LevelModel? level; // Jika null, berarti mode "Tambah"

  const LevelFormScreen({super.key, required this.kurikulumId, this.level});

  @override
  ConsumerState<LevelFormScreen> createState() => _LevelFormScreenState();
}

class _LevelFormScreenState extends ConsumerState<LevelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _targetController;
  late TextEditingController _urutanController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.level?.namaLevel);
    _targetController = TextEditingController(text: widget.level?.targetHafalan);
    _urutanController = TextEditingController(text: widget.level?.urutan.toString() ?? '1');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _targetController.dispose();
    _urutanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.level != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Level" : "Tambah Level"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Informasi Dasar"),
              const SizedBox(height: 16),

              // Input Urutan (Penting untuk alur kurikulum)
              TextFormField(
                controller: _urutanController,
                decoration: _inputDecoration("Urutan Level", Icons.format_list_numbered),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 20),

              // Input Nama Level
              TextFormField(
                controller: _namaController,
                decoration: _inputDecoration("Nama Level (Misal: Juz 30 / Dasar)", Icons.stairs),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Target Akademik"),
              const SizedBox(height: 16),

              // Input Target Hafalan
              TextFormField(
                controller: _targetController,
                maxLines: 3,
                decoration: _inputDecoration("Deskripsi Target (Misal: An-Naba s/d An-Nas)", Icons.track_changes),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),

              const SizedBox(height: 40),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "SIMPAN KONFIGURASI LEVEL",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final newLevel = LevelModel(
      id: widget.level?.id,
      kurikulumId: widget.kurikulumId,
      namaLevel: _namaController.text.trim(),
      urutan: int.parse(_urutanController.text),
      targetHafalan: _targetController.text.trim(),
    );

    await ref.read(levelListProvider(widget.kurikulumId).notifier).saveLevel(newLevel);

    // SAFE UPDATE: Menggunakan blok if, bukan return
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Level?"),
        content: const Text("Tindakan ini akan menghapus target pencapaian untuk level ini."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              await ref.read(levelListProvider(widget.kurikulumId).notifier).deleteLevel(widget.level!.id!);

              // SAFE UPDATE: Menggunakan blok if
              if (context.mounted) {
                Navigator.pop(ctx); // Tutup dialog
                Navigator.pop(context); // Balik ke list
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
    );
  }
}