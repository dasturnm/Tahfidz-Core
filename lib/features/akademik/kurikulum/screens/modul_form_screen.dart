// Lokasi: lib/features/akademik/kurikulum/screens/modul_form_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart' as csv_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart'; // TAMBAHAN: Untuk format tanggal
import '../models/kurikulum_model.dart';
import '../providers/modul_provider.dart';
import '../../../../features/mushaf/providers/mushaf_provider.dart';
// FIX: Menggunakan package import untuk memastikan provider ditemukan oleh ref.watch
import 'package:tahfidz_core/features/program/providers/program_provider.dart';

class ModulFormScreen extends ConsumerStatefulWidget {
  final LevelModel level;
  final ModulModel? modul;

  const ModulFormScreen({super.key, required this.level, this.modul});

  @override
  ConsumerState<ModulFormScreen> createState() => _ModulFormScreenState();
}

class _ModulFormScreenState extends ConsumerState<ModulFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _targetPertemuanController;
  late TextEditingController _targetAmountController;
  late TextEditingController _silabusController;
  late TextEditingController _mulaiController;
  late TextEditingController _akhirController;

  // Controller Murojaah & Policy
  late TextEditingController _sabqiController;
  late TextEditingController _manzilAmountController;

  late String _selectedType;
  late String _selectedMetrik;
  late String _silabusSource;
  late bool _isStrict;
  late bool _isAllowBelowTarget;
  late bool _isAccumulated;
  late bool _isSingleBurden;
  late String _manzilType;

  // TAMBAHAN LOGIKA BARU
  late String _selectedTargetUnit;
  late bool _isPlottingActive;
  int? _surahIdForAyat;

  // Pilar Murojaah & Kedisiplinan (v2026.04.17)
  late String _sabqiUnit;
  late bool _showSabqiInMutabaah;
  late bool _showManzilInDashboard;

  late double _kkmValue;
  List<SilabusItemModel> _silabusItems = [];

  final List<String> _tipeOptions = ['ZIYADAH HAFALAN', 'ZIYADAH TILAWAH', 'MUROJAAH', 'TASMI\'', 'TAHSIN', 'DINIYAH'];
  // FIX: Hapus BARIS dari opsi metrik standar
  final List<String> _metrikOptionsTahfidz = ['JUZ', 'SURAH', 'HALAMAN', 'AYAT'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.modul?.namaModul ?? '');
    _targetPertemuanController = TextEditingController(text: (widget.modul?.targetPertemuan ?? 30).toString());
    _targetAmountController = TextEditingController(text: (widget.modul?.targetAmount ?? 0.0).toInt().toString());
    _silabusController = TextEditingController(text: widget.modul?.silabus ?? '');
    _mulaiController = TextEditingController(text: widget.modul?.mulaiKoordinat ?? '');
    _akhirController = TextEditingController(text: widget.modul?.akhirKoordinat ?? '');

    _sabqiController = TextEditingController(text: (widget.modul?.sabqiAmount ?? 0).toString());
    _manzilAmountController = TextEditingController(text: (widget.modul?.manzilAmount ?? 0.0).toString());

    _selectedType = widget.modul?.tipe ?? 'ZIYADAH HAFALAN';
    if (_selectedType == 'HAFALAN') _selectedType = 'ZIYADAH HAFALAN';
    if (_selectedType == 'BELAJAR BACA') _selectedType = 'TAHSIN'; // FIX: Legacy Mapping

    _selectedMetrik = widget.modul?.jenisMetrik ?? 'HALAMAN';
    _selectedTargetUnit = widget.modul?.targetAmountUnit ?? 'HALAMAN';
    _isPlottingActive = widget.modul?.isPlottingActive ?? false;

    _silabusSource = widget.modul?.silabusSource ?? 'mushaf';
    _isStrict = widget.modul?.isStrict ?? false;
    _isAllowBelowTarget = widget.modul?.isAllowBelowTarget ?? true;
    _isAccumulated = widget.modul?.isAccumulated ?? false;
    _isSingleBurden = widget.modul?.isSingleBurden ?? true;
    _manzilType = widget.modul?.manzilType ?? 'fixed';

    // Inisialisasi Field Baru Murojaah & Kedisiplinan
    _sabqiUnit = widget.modul?.sabqiUnit ?? 'HALAMAN';
    _showSabqiInMutabaah = widget.modul?.showSabqiInMutabaah ?? true;
    _showManzilInDashboard = widget.modul?.showManzilInDashboard ?? true;

    _kkmValue = widget.modul?.kkm ?? 80.0;
    _silabusItems = widget.modul?.silabusContent ?? [];

    // FIX: Listener agar UI (termasuk estimasi) terupdate secara real-time saat angka diketik
    _targetPertemuanController.addListener(() => setState(() {}));
    _targetAmountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _namaController.dispose();
    _targetPertemuanController.dispose();
    _targetAmountController.dispose();
    _silabusController.dispose();
    _mulaiController.dispose();
    _akhirController.dispose();
    _sabqiController.dispose();
    _manzilAmountController.dispose();
    super.dispose();
  }

  Future<void> _downloadTemplate() async {
    List<List<String>> csvData = [
      ["pertemuan", "materi", "keterangan"],
      ["1", "Materi Contoh 1", "Deskripsi"],
    ];
    // FIX: Menghapus const karena CsvCodec bukan const constructor
    String csvContent = csv_pkg.CsvCodec().encoder.convert(csvData);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/template_silabus.csv');
    await file.writeAsString(csvContent);
    if (mounted) {
      await Share.shareXFiles([XFile(file.path)], text: 'Template Silabus CSV');
    }
  }

  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['csv'], withData: true,
    );
    if (result != null) {
      final input = utf8.decode(result.files.single.bytes!);
      // FIX: Menghapus const karena CsvCodec bukan const constructor
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
        _selectedMetrik = 'NOMOR';
        _selectedTargetUnit = 'NOMOR';
        _isPlottingActive = true;
        _mulaiController.text = "1";
        _akhirController.text = _silabusItems.length.toString();
        _targetAmountController.text = "1";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.modul != null;
    final bool isMurojaah = _selectedType == 'MUROJAAH';

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
                _buildTypeAndMeetingRow(),

                const SizedBox(height: 32),
                _buildSyllabusSourceSelector(),

                // POIN 2: PLOTTING MATERI (INTERNAL ONLY)
                if (_silabusSource == 'internal') _buildPlottingSection(),

                const SizedBox(height: 32),
                if (!isMurojaah) ...[
                  // POIN 3: METRIK STANDAR
                  _buildStandardMetricSection(),
                  const SizedBox(height: 24),

                  // POIN 3: CAKUPAN MATERI
                  _buildLabel("CAKUPAN MATERI (MULAI - AKHIR)"),
                  const SizedBox(height: 8),
                  _buildCakupanInputs(),

                  const SizedBox(height: 32),
                  // POIN 4: PENCAPAIAN PER PERTEMUAN
                  _buildPencapaianSection(),

                  // POIN 5: ESTIMASI SELESAI
                  _buildEstimationInfo(),
                ] else
                  _buildMurojaahPillarsSection(),

                const SizedBox(height: 32),
                if (!isMurojaah) ...[
                  _buildLabel("KKM LULUS"),
                  Slider(
                    value: _kkmValue, min: 0, max: 100, divisions: 20,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) => setState(() => _kkmValue = v),
                  ),
                ],

                if (_selectedType.contains('HAFALAN') || isMurojaah) ...[
                  const SizedBox(height: 24),
                  _buildLabel("PENGATURAN KEDISIPLINAN"),
                  const SizedBox(height: 12),
                  _buildPolicySection(),
                ],

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _saveModul,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(isEdit ? "PERBARUI UNIT MODUL" : "SIMPAN UNIT MODUL", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeAndMeetingRow() {
    final bool isMurojaah = _selectedType == 'MUROJAAH';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("TIPE MODUL"),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _tipeOptions.contains(_selectedType) ? _selectedType : _tipeOptions.first,
                decoration: _inputStyle(""),
                items: _tipeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => setState(() {
                  _selectedType = v!;
                  // Lock source mushaf if Murojaah
                  if (v == 'MUROJAAH') _silabusSource = 'mushaf';
                }),
              ),
            ],
          ),
        ),
        if (!isMurojaah) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("TOTAL PERTEMUAN"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetPertemuanController,
                  keyboardType: TextInputType.number,
                  decoration: _inputStyle("30"),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlottingSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Aktifkan Plotting Materi Harian", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("Buat silabus untuk menentukan materi per pertemuan", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPlottingActive,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) => setState(() {
                      _isPlottingActive = v;
                      if (v) _selectedTargetUnit = 'NOMOR';
                    }),
                  ),
                ],
              ),
              if (_isPlottingActive) ...[
                const Divider(height: 32),
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(onPressed: _importCSV, icon: const Icon(Icons.upload_file), label: const Text("IMPORT CSV"))),
                    const SizedBox(width: 12),
                    Expanded(child: OutlinedButton.icon(onPressed: _downloadTemplate, icon: const Icon(Icons.download), label: const Text("TEMPLATE"))),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStandardMetricSection() {
    List<String> options = _silabusSource == 'mushaf' ? _metrikOptionsTahfidz : ['HALAMAN', 'NOMOR'];
    if (_silabusSource == 'internal' && _isPlottingActive) options = ['NOMOR'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("STANDAR METRIK MODUL"),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: options.contains(_selectedMetrik) ? _selectedMetrik : options.first,
          decoration: _inputStyle("Pilih Satuan"),
          items: options.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (v) => setState(() {
            _selectedMetrik = v!;
            if (v == 'NOMOR') _selectedTargetUnit = 'NOMOR';
          }),
        ),
      ],
    );
  }

  Widget _buildCakupanInputs() {
    // FIX: Jika Plotting Aktif & Silabus ada, tampilkan silabus di dropdown
    if (_isPlottingActive && _silabusItems.isNotEmpty) {
      return _buildSyllabusDropdownRange();
    }

    if (_silabusSource == 'mushaf') {
      if (_selectedMetrik == 'AYAT') return _buildAyatScopeSelector();
      if (_selectedMetrik == 'JUZ') return _buildDropdownRange(List.generate(30, (i) => (i + 1).toString()));
      if (_selectedMetrik == 'HALAMAN') return _buildDropdownRange(List.generate(604, (i) => (i + 1).toString()));
      if (_selectedMetrik == 'SURAH') {
        final surahAsync = ref.watch(surahListProvider);
        return surahAsync.maybeWhen(
          data: (list) => _buildDropdownRange(list.map((s) => s['surah_name'].toString()).toList()),
          orElse: () => _buildTextRange(false),
        );
      }
    }
    return _buildTextRange(_silabusSource == 'internal' && _isPlottingActive);
  }

  Widget _buildSyllabusDropdownRange() {
    List<String> options = _silabusItems.map((e) => "${e.pertemuan}. ${e.materi}").toList();
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: options.any((o) => o.startsWith("${_mulaiController.text}. ")) ? options.firstWhere((o) => o.startsWith("${_mulaiController.text}. ")) : null,
            decoration: _inputStyle("Mulai"),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) => setState(() => _mulaiController.text = v!.split('.').first),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, color: Colors.grey, size: 16)),
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: options.any((o) => o.startsWith("${_akhirController.text}. ")) ? options.firstWhere((o) => o.startsWith("${_akhirController.text}. ")) : null,
            decoration: _inputStyle("Akhir"),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) => setState(() => _akhirController.text = v!.split('.').first),
          ),
        ),
      ],
    );
  }

  Widget _buildAyatScopeSelector() {
    final surahAsync = ref.watch(surahListProvider);
    return surahAsync.maybeWhen(
      data: (list) => Column(
        children: [
          DropdownButtonFormField<int>(
            isExpanded: true,
            value: _surahIdForAyat,
            decoration: _inputStyle("Pilih Surah Terlebih Dahulu"),
            items: list.map((s) => DropdownMenuItem<int>(value: (s['surah_number'] as num?)?.toInt() ?? 0, child: Text("${s['surah_number']}. ${s['surah_name']}"))).toList(),
            onChanged: (v) => setState(() {
              _surahIdForAyat = v;
              _mulaiController.clear();
              _akhirController.clear();
            }),
          ),
          const SizedBox(height: 12),
          if (_surahIdForAyat != null)
            _buildAyatRangeDropdowns(list),
        ],
      ),
      orElse: () => const Text("Memuat Surah..."),
    );
  }

  Widget _buildAyatRangeDropdowns(List<dynamic> surahList) {
    final surah = surahList.firstWhere(
          (e) => (e['surah_number'] as num?)?.toInt() == _surahIdForAyat,
      orElse: () => <String, dynamic>{},
    );

    if (surah.isEmpty) return const SizedBox();

    // FIX: Safety cast num to int untuk cegah Null TypeError
    int totalAyah = (surah['total_ayah'] as num?)?.toInt() ?? 0;
    if (totalAyah == 0) return const Text("Data ayat tidak ditemukan (NULL)", style: TextStyle(color: Colors.red, fontSize: 10));

    List<String> ayahs = List.generate(totalAyah, (i) => (i + 1).toString());

    return _buildDropdownRange(ayahs);
  }

  Widget _buildDropdownRange(List<String> options) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: options.contains(_mulaiController.text) ? _mulaiController.text : null,
            decoration: _inputStyle("Mulai"),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) => setState(() => _mulaiController.text = v!),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.arrow_forward, color: Colors.grey, size: 16)),
        Expanded(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: options.contains(_akhirController.text) ? _akhirController.text : null,
            decoration: _inputStyle("Akhir"),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) => setState(() => _akhirController.text = v!),
          ),
        ),
      ],
    );
  }

  Widget _buildPencapaianSection() {
    // FIX: Menghapus duplikasi AYAT
    List<String> unitOptions = ['JUZ', 'SURAH', 'HALAMAN', 'AYAT', 'NOMOR'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pencapaian per Pertemuan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("TARGET"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          double v = double.tryParse(_targetAmountController.text) ?? 0;
                          if (v > 0) setState(() => _targetAmountController.text = (v - 1).toInt().toString());
                        },
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _targetAmountController,
                          keyboardType: TextInputType.number,
                          decoration: _inputStyle("Angka"),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          double v = double.tryParse(_targetAmountController.text) ?? 0;
                          setState(() => _targetAmountController.text = (v + 1).toInt().toString());
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("TIPE TARGET"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: unitOptions.contains(_selectedTargetUnit) ? _selectedTargetUnit : unitOptions.first,
                    decoration: _inputStyle("Satuan"),
                    items: unitOptions.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (v) => setState(() => _selectedTargetUnit = v!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstimationInfo() {
    String estimatedDate = _calculateEstimatedEndDate();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.blue, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "💡 Estimasi Lulus: $estimatedDate",
                style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.blue),
              tooltip: "Hitung Ulang Estimasi",
            ),
          ],
        ),
      ),
    );
  }

  String _calculateEstimatedEndDate() {
    int meetingsNeeded = int.tryParse(_targetPertemuanController.text) ?? 0;
    if (meetingsNeeded <= 0) return "-";

    final List<String> effectiveDaysStr = ref.watch(programHariEfektifProvider(widget.level.programId ?? ''));

    final Map<String, int> dayMap = {
      'senin': 1, 'selasa': 2, 'rabu': 3, 'kamis': 4, 'jumat': 5, 'sabtu': 6, 'minggu': 7
    };
    final List<int> effectiveDays = effectiveDaysStr.map((d) => dayMap[d.toLowerCase()] ?? 0).where((d) => d != 0).toList();

    if (effectiveDays.isEmpty) return "Jadwal Belum Diatur";

    DateTime current = DateTime.now();
    int added = 0;
    int daysLimit = 0;

    while (added < meetingsNeeded && daysLimit < 1000) {
      current = current.add(const Duration(days: 1));
      if (effectiveDays.contains(current.weekday)) {
        added++;
      }
      daysLimit++;
    }

    return DateFormat('dd MMMM yyyy', 'id_ID').format(current);
  }

  // --- REUSED HELPERS ---
  Widget _buildLevelBadge() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(16)), child: Row(children: [const Icon(Icons.auto_stories_outlined, color: Colors.blueGrey), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("LEVEL INDUK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)), Text(widget.level.namaLevel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]))]));
  Widget _buildInstructionBox() => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.info_outline, color: Color(0xFF10B981), size: 20), SizedBox(width: 12), Expanded(child: Text("Sistem menghitung estimasi tanggal lulus berdasarkan hari efektif di program.", style: TextStyle(fontSize: 11, color: Color(0xFF065F46))))]));
  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5));
  InputDecoration _inputStyle(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey[50], contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none));

  Widget _buildSyllabusSourceSelector() {
    final bool isMurojaah = _selectedType == 'MUROJAAH';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("SUMBER SILABUS"),
        const SizedBox(height: 8),
        Row(
          children: [
            _sourceButton("Silabus Berbasis Mushaf", 'mushaf', Icons.menu_book_rounded),
            if (!isMurojaah) ...[
              const SizedBox(width: 12),
              _sourceButton("Kurikulum Internal", 'internal', Icons.assignment_rounded),
            ],
          ],
        ),
      ],
    );
  }

  Widget _sourceButton(String label, String value, IconData icon) {
    bool isSelected = _silabusSource == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _silabusSource = value;
          if (value == 'internal') _selectedMetrik = 'NOMOR';
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF10B981) : Colors.grey),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF10B981) : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextRange(bool isNomor) {
    return Row(children: [
      Expanded(child: TextFormField(controller: _mulaiController, enabled: !isNomor, decoration: _inputStyle(isNomor ? "Auto" : "Mulai"))),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.arrow_forward, color: Colors.grey)),
      Expanded(child: TextFormField(controller: _akhirController, enabled: !isNomor, decoration: _inputStyle(isNomor ? "Auto" : "Akhir"))),
    ]);
  }

  Widget _buildMurojaahPillarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("PILAR MURAJAAH (STANDARDIZED)"),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              const ListTile(leading: Icon(Icons.star, color: Colors.orange), title: Text("SABAQ", style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("Hafalan baru (Merujuk pada modul Ziyadah)", style: TextStyle(fontSize: 11))),
              const Divider(),
              _buildMurojaahSabqiRow(),
              const Divider(),
              _buildMurojaahManzilRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMurojaahSabqiRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SABQI (Hafalan Kemarin)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _sabqiController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: _inputStyle("Angka"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                value: _sabqiUnit,
                decoration: _inputStyle("Satuan"),
                items: ['JUZ', 'HALAMAN', 'BARIS'].map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => setState(() => _sabqiUnit = v!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMurojaahManzilRow() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("MANZIL (Hafalan Lama)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            IconButton(
              onPressed: () => _showManzilInfo(),
              icon: const Icon(Icons.info_outline, size: 18, color: Colors.blue),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: _manzilType,
              items: const [DropdownMenuItem(value: 'fixed', child: Text("Angka")), DropdownMenuItem(value: 'percentage', child: Text("Persen"))],
              onChanged: (v) => setState(() => _manzilType = v!),
            ),
          ],
        ),
        TextFormField(controller: _manzilAmountController, textAlign: TextAlign.right, decoration: InputDecoration(hintText: _manzilType == 'fixed' ? "Juz / Halaman" : "Contoh: 10 (%)")),
      ],
    );
  }

  void _showManzilInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("💡 Info Manzil"),
        content: const Text("Penelitian menunjukkan bahwa hafalan yang baik itu bisa mutar dalam jangka waktu 30 hari - 40 hari. Disarankan memilih persentase 4% agar siklus murojaah terjaga dengan baik."),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("MENGERTI"))],
      ),
    );
  }

  Widget _buildPolicySection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              _policyBtn("Wajib Target", Icons.gavel, _isStrict, () => setState(() { _isStrict = true; _isAllowBelowTarget = false; })),
              const SizedBox(width: 8),
              _policyBtn("Toleransi", Icons.fact_check, _isAllowBelowTarget, () => setState(() { _isStrict = false; _isAllowBelowTarget = true; })),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _policyBtn("Akumulasi", Icons.history_edu, _isAccumulated, () => setState(() { _isAccumulated = true; _isSingleBurden = false; })),
              const SizedBox(width: 8),
              _policyBtn("Beban Tunggal", Icons.event_available, _isSingleBurden, () => setState(() { _isAccumulated = false; _isSingleBurden = true; })),
            ],
          ),
          const Divider(height: 24),
          _buildTogglePolicy("Aktifkan Murajaah Sabqi (Guru)", _showSabqiInMutabaah, (v) => setState(() => _showSabqiInMutabaah = v)),
          const SizedBox(height: 8),
          _buildTogglePolicy("Ceklist Murojaah Manzil (Siswa)", _showManzilInDashboard, (v) => setState(() => _showManzilInDashboard = v)),
        ],
      ),
    );
  }

  Widget _buildTogglePolicy(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        Switch(
          value: value,
          activeColor: const Color(0xFF10B981),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _policyBtn(String label, IconData icon, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF10B981) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? const Color(0xFF10B981) : Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: active ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: active ? Colors.white : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveModul() async {
    if (!_formKey.currentState!.validate()) return;
    final data = ModulModel(
      id: widget.modul?.id, levelId: widget.level.id!, namaModul: _namaController.text.trim(),
      tipe: _selectedType, targetPertemuan: int.tryParse(_targetPertemuanController.text) ?? 30,
      targetAmount: double.tryParse(_targetAmountController.text) ?? 0.0,
      silabus: _silabusController.text.trim(), silabusContent: _silabusItems,
      isSystemGenerated: _selectedType.contains('HAFALAN'), jenisMetrik: _selectedMetrik,
      mulaiKoordinat: _mulaiController.text.trim(), akhirKoordinat: _akhirController.text.trim(),
      kkm: _kkmValue, silabusSource: _silabusSource, isStrict: _isStrict,
      isAllowBelowTarget: _isAllowBelowTarget, isAccumulated: _isAccumulated,
      isSingleBurden: _isSingleBurden, sabqiAmount: int.tryParse(_sabqiController.text) ?? 0,
      sabqiUnit: _sabqiUnit, manzilType: _manzilType, manzilAmount: double.tryParse(_manzilAmountController.text) ?? 0.0,
      targetAmountUnit: _selectedTargetUnit, isPlottingActive: _isPlottingActive,
      showSabqiInMutabaah: _showSabqiInMutabaah, showManzilInDashboard: _showManzilInDashboard,
    );
    await ref.read(modulListProvider(widget.level.id!).notifier).saveModul(data);
    if (mounted) Navigator.pop(context);
  }
}