import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import '../providers/kurikulum_provider.dart';

class ModulFormScreen extends ConsumerStatefulWidget {
  final LevelModel level; // Induknya adalah Level
  final ModulModel? modul; // Jika null = Tambah, Jika ada = Edit

  const ModulFormScreen({super.key, required this.level, this.modul});

  @override
  ConsumerState<ModulFormScreen> createState() => _ModulFormScreenState();
}

class _ModulFormScreenState extends ConsumerState<ModulFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _durasiController;
  late String _selectedType;

  final List<String> _tipeOptions = ['HAFALAN', 'TAHSIN', 'TEORI', 'UJIAN'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.modul?.namaModul ?? '');
    _durasiController = TextEditingController(text: widget.modul?.durasiHari.toString() ?? '30');
    _selectedType = widget.modul?.tipe ?? 'HAFALAN';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _durasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.modul != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Modul" : "Tambah Modul"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLevelBadge(),
              const SizedBox(height: 32),

              _buildLabel("NAMA MODUL"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: _inputStyle("Misal: Juz 30 (An-Naba s/d Al-Inshiqaq)"),
                validator: (v) => v!.isEmpty ? "Nama modul wajib diisi" : null,
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("TIPE MODUL"),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedType, // Perbaikan: menggunakan initialValue
                          decoration: _inputStyle(""),
                          items: _tipeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => _selectedType = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("DURASI (HARI)"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _durasiController,
                          keyboardType: TextInputType.number,
                          decoration: _inputStyle("30"),
                          validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveModul,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    isEdit ? "PERBARUI UNIT MODUL" : "SIMPAN UNIT MODUL",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.1)), // Perbaikan: .withValues
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_stories_outlined, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("LEVEL INDUK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                Text(widget.level.namaLevel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5));
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Future<void> _saveModul() async {
    if (!_formKey.currentState!.validate()) return;

    final data = ModulModel(
      id: widget.modul?.id,
      levelId: widget.level.id!,
      namaModul: _namaController.text.trim(),
      tipe: _selectedType,
      durasiHari: int.parse(_durasiController.text),
      targets: widget.modul?.targets ?? [],
    );

    // Memastikan pemanggilan provider yang sudah ter-generate dari build_runner
    await ref.read(modulListProvider(widget.level.id!).notifier).saveModul(data);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}