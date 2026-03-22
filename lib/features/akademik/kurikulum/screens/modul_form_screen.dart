// Lokasi: lib/features/akademik/kurikulum/screens/modul_form_screen.dart

import 'dart:convert';
import 'dart:io'; // TAMBAHAN
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart' as csv_pkg;
import 'package:path_provider/path_provider.dart'; // TAMBAHAN
import 'package:share_plus/share_plus.dart'; // TAMBAHAN
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

  bool _isSilabusActive = false;
  List<SilabusItemModel> _silabusItems = [];

  final List<String> _tipeOptions = ['BELAJAR BACA', 'TAJWID', 'TAHSIN', 'TAHFIDZ', 'MATAN', 'HADITS', 'ADAB'];
  final List<String> _metrikOptions = ['JUZ', 'SURAH', 'HALAMAN', 'AYAT', 'BARIS', 'NOMOR'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.modul?.namaModul ?? '');
    _targetPertemuanController = TextEditingController(text: (widget.modul?.targetPertemuan ?? 30).toString());
    _silabusController = TextEditingController(text: widget.modul?.silabus ?? '');
    _mulaiController = TextEditingController(text: widget.modul?.mulaiKoordinat ?? '');
    _akhirController = TextEditingController(text: widget.modul?.akhirKoordinat ?? '');

    final String initialType = widget.modul?.tipe ?? 'BELAJAR BACA';
    _selectedType = (initialType == 'HAFALAN') ? 'TAHFIDZ' : initialType;

    _selectedMetrik = widget.modul?.jenisMetrik ?? 'HALAMAN';
    _kkmValue = widget.modul?.kkm ?? 80.0;

    _silabusItems = widget.modul?.silabusContent ?? [];
    _isSilabusActive = _silabusItems.isNotEmpty;
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

  // FUNGSI BARU: Download Template (Poin 2)
  Future<void> _downloadTemplate() async {
    List<List<String>> csvData = [
      ["pertemuan", "materi", "keterangan"],
      ["1", "Materi Contoh 1", "Deskripsi materi"],
      ["2", "Materi Contoh 2", "Deskripsi materi"],
    ];

    String csvContent = csv_pkg.CsvCodec().encoder.convert(csvData);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/template_silabus.csv');

    await file.writeAsString(csvContent);

    if (mounted) {
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], text: 'Template Silabus CSV');
    }
  }

  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result != null) {
      final input = utf8.decode(result.files.single.bytes!);
      List<List<dynamic>> rows = csv_pkg.CsvCodec().decoder.convert(input);

      List<SilabusItemModel> newItems = [];
      for (var i = 1; i < rows.length; i++) {
        if (rows[i].isNotEmpty && rows[i].length >= 2) {
          newItems.add(SilabusItemModel(
            pertemuan: int.tryParse(rows[i][0].toString()) ?? i,
            materi: rows[i][1].toString(),
            keterangan: rows[i].length > 2 ? rows[i][2].toString() : null,
          ));
        }
      }

      setState(() {
        _silabusItems = newItems;
        if (_selectedMetrik == 'NOMOR') {
          _mulaiController.text = "1";
          _akhirController.text = _silabusItems.length.toString();
          _targetPertemuanController.text = _silabusItems.length.toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.modul != null;
    final bool isTahfidz = _selectedType == 'TAHFIDZ';
    final bool isNomor = _selectedMetrik == 'NOMOR';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Modul" : "Tambah Modul"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLevelBadge(),
                const SizedBox(height: 24),
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
                            isExpanded: true,
                            initialValue: _tipeOptions.contains(_selectedType) ? _selectedType : _tipeOptions.first,
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
                            enabled: !isNomor,
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
                  isExpanded: true,
                  initialValue: _metrikOptions.contains(_selectedMetrik) ? _selectedMetrik : _metrikOptions.first,
                  decoration: _inputStyle(""),
                  items: _metrikOptions.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedMetrik = v!;
                      if (_selectedMetrik == 'NOMOR' && _silabusItems.isNotEmpty) {
                        _mulaiController.text = "1";
                        _akhirController.text = _silabusItems.length.toString();
                        _targetPertemuanController.text = _silabusItems.length.toString();
                      }
                    });
                  },
                ),

                const SizedBox(height: 24),
                _buildLabel("CAKUPAN MATERI (MULAI - AKHIR)"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _mulaiController,
                        enabled: !isTahfidz && !isNomor,
                        decoration: _inputStyle(isTahfidz || isNomor ? "Otomatis" : "Mulai"),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 20),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _akhirController,
                        enabled: !isTahfidz && !isNomor,
                        decoration: _inputStyle(isTahfidz || isNomor ? "Otomatis" : "Akhir"),
                      ),
                    ),
                  ],
                ),

                if (isTahfidz)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Material(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
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
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.menu_book_rounded, size: 18, color: Color(0xFF10B981)),
                              SizedBox(width: 8),
                              Text("Pilih dari Data Mushaf", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
                _buildSilabusSection(),

                const SizedBox(height: 32),
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
      ),
    );
  }

  Widget _buildSilabusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel("SILABUS PEMBELAJARAN"),
            Switch(
              value: _isSilabusActive,
              activeThumbColor: const Color(0xFF10B981),
              onChanged: (v) => setState(() => _isSilabusActive = v),
            ),
          ],
        ),
        if (_isSilabusActive) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _importCSV,
                        icon: const Icon(Icons.upload_file_rounded, size: 18),
                        label: const Text("IMPORT CSV"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _downloadTemplate,
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text("TEMPLATE"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_silabusItems.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                    title: Text("${_silabusItems.length} Materi Berhasil Dimuat", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text("Klik 'Simpan' untuk memproses data.", style: TextStyle(fontSize: 11)),
                  ),
                ],
              ],
            ),
          ),
        ] else
          const Text("Gunakan silabus jika Anda ingin mengatur materi per pertemuan secara spesifik.",
              style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.1)),
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
      silabusContent: _silabusItems,
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