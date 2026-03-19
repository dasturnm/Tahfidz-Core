import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import '../providers/kurikulum_provider.dart';
import '../widgets/mushaf_picker_dialog.dart';

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
  late TextEditingController _targetPertemuanController;
  late TextEditingController _silabusController;
  late TextEditingController _mulaiController;
  late TextEditingController _akhirController;

  late String _selectedType;
  late String _selectedMetrik;
  late double _kkmValue;

  // PERBAIKAN POIN 1: Urutan Tipe Modul Sesuai Permintaan
  final List<String> _tipeOptions = ['BELAJAR BACA', 'TAJWID', 'TAHSIN', 'TAHFIDZ', 'MATAN', 'HADITS', 'ADAB'];
  final List<String> _metrikOptions = ['HALAMAN', 'BARIS', 'AYAT', 'SURAH', 'JUZ'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.modul?.namaModul ?? '');
    _targetPertemuanController = TextEditingController(text: (widget.modul?.targetPertemuan ?? 30).toString());
    _silabusController = TextEditingController(text: widget.modul?.silabus ?? '');
    _mulaiController = TextEditingController(text: widget.modul?.mulaiKoordinat ?? '');
    _akhirController = TextEditingController(text: widget.modul?.akhirKoordinat ?? '');

    // Migrasi data lama 'HAFALAN' ke 'TAHFIDZ' agar tidak crash
    final String initialType = widget.modul?.tipe ?? 'BELAJAR BACA';
    _selectedType = (initialType == 'HAFALAN') ? 'TAHFIDZ' : initialType;

    _selectedMetrik = widget.modul?.jenisMetrik ?? 'HALAMAN';
    _kkmValue = widget.modul?.kkm ?? 80.0;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _targetPertemuanController.dispose();
    _silabusController.dispose();
    _mulaiController.dispose();
    _akhirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.modul != null;
    final bool isTahfidz = _selectedType == 'TAHFIDZ';

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
              const SizedBox(height: 24),
              // PERBAIKAN POIN 5: Menambahkan Instruksi Onboarding
              _buildInstructionBox(),
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
                          isExpanded: true, // PERBAIKAN: Mencegah overflow
                          value: _tipeOptions.contains(_selectedType) ? _selectedType : _tipeOptions.first,
                          decoration: _inputStyle(""),
                          items: _tipeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() {
                            _selectedType = v!;
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("TARGET PERTEMUAN"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _targetPertemuanController,
                          keyboardType: TextInputType.number,
                          decoration: _inputStyle("30"),
                          validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildLabel("STANDAR METRIK"),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true, // PERBAIKAN: Konsistensi UI dan mencegah overflow
                value: _metrikOptions.contains(_selectedMetrik) ? _selectedMetrik : _metrikOptions.first,
                decoration: _inputStyle(""),
                items: _metrikOptions.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _selectedMetrik = v!),
              ),

              const SizedBox(height: 24),
              _buildLabel("CAKUPAN MATERI (MULAI - AKHIR)"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mulaiController,
                      enabled: !isTahfidz,
                      decoration: _inputStyle(isTahfidz ? "Otomatis" : "Mulai"),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 20),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _akhirController,
                      enabled: !isTahfidz,
                      decoration: _inputStyle(isTahfidz ? "Otomatis" : "Akhir"),
                    ),
                  ),
                ],
              ),
              if (isTahfidz)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: () async {
                      final result = await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const MushafPickerDialog(),
                      );

                      if (result != null) {
                        setState(() {
                          if (_namaController.text.isEmpty) {
                            _namaController.text = result['nama'];
                          }
                          _mulaiController.text = result['mulai'];
                          _akhirController.text = result['akhir'];
                        });
                      }
                    },
                    icon: const Icon(Icons.menu_book_rounded, size: 16),
                    label: const Text("Pilih dari Data Mushaf", style: TextStyle(fontSize: 12)),
                  ),
                ),

              const SizedBox(height: 24),
              _buildLabel("JUDUL SILABUS (OPSIONAL)"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _silabusController,
                maxLines: 2,
                decoration: _inputStyle("Rangkuman materi atau catatan tambahan..."),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel("KKM LULUS"),
                  Text("${_kkmValue.toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                ],
              ),
              Slider(
                value: _kkmValue,
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: const Color(0xFF10B981),
                onChanged: (v) => setState(() => _kkmValue = v),
              ),

              const SizedBox(height: 40),
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
        border: Border.all(color: Colors.blueGrey.withOpacity(0.1)),
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

  // PERBAIKAN POIN 5: Widget Instruksi Baru
  Widget _buildInstructionBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF10B981), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Tentukan unit pembelajaran. Pilih tipe 'TAHFIDZ' untuk menghubungkan modul dengan data Mushaf secara otomatis.",
              style: TextStyle(fontSize: 12, color: Color(0xFF065F46), height: 1.4),
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
      targetPertemuan: int.tryParse(_targetPertemuanController.text) ?? 30,
      silabus: _silabusController.text.trim(),
      isSystemGenerated: _selectedType == 'TAHFIDZ',
      jenisMetrik: _selectedMetrik,
      mulaiKoordinat: _mulaiController.text.trim(),
      akhirKoordinat: _akhirController.text.trim(),
      kkm: _kkmValue,
    );

    await ref.read(modulListProvider(widget.level.id!).notifier).saveModul(data);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}