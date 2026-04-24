// Lokasi: lib/features/akademik/kurikulum/screens/modul_form_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart' as csv_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/kurikulum_model.dart';
import '../providers/modul_provider.dart';
import 'package:tahfidz_core/features/program/providers/program_provider.dart';
import 'package:tahfidz_core/features/program/providers/agenda_provider.dart';
import 'package:tahfidz_core/features/akademik/kurikulum/providers/kurikulum_provider.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';
import 'components/modul_shared_widgets.dart';
import 'components/modul_policy_section.dart';
import 'components/modul_murojaah_section.dart';
import 'components/modul_pencapaian_section.dart';
import 'components/modul_cakupan_section.dart';
import 'components/modul_tasmi_setting_section.dart';

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
  late Map<String, dynamic> _tasmiSettings;

  // STATE KENAIKAN LEVEL
  late bool _isExamRequired;
  late String _examType;
  late double _examVolume;
  late String _examUnit;
  late bool _isCumulativeExam;
  late int _cumulativeRange;

  final List<String> _tipeOptions = ['ZIYADAH HAFALAN', 'ZIYADAH TILAWAH', 'MUROJAAH', 'TASMI\'', 'TAHSIN', 'DINIYAH'];
  final List<String> _metrikOptionsTahfidz = ['JUZ', 'SURAH', 'HALAMAN', 'AYAT'];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
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
    if (_selectedType == 'BELAJAR BACA') _selectedType = 'TAHSIN';

    _selectedMetrik = widget.modul?.jenisMetrik ?? 'HALAMAN';
    _selectedTargetUnit = widget.modul?.targetAmountUnit ?? 'HALAMAN';
    _isPlottingActive = widget.modul?.isPlottingActive ?? false;

    _silabusSource = widget.modul?.silabusSource ?? 'mushaf';
    _isStrict = widget.modul?.isStrict ?? false;
    _isAllowBelowTarget = widget.modul?.isAllowBelowTarget ?? true;
    _isAccumulated = widget.modul?.isAccumulated ?? false;
    _isSingleBurden = widget.modul?.isSingleBurden ?? true;
    _manzilType = widget.modul?.manzilType ?? 'fixed';

    _sabqiUnit = widget.modul?.sabqiUnit ?? 'HALAMAN';
    _showSabqiInMutabaah = widget.modul?.showSabqiInMutabaah ?? true;
    _showManzilInDashboard = widget.modul?.showManzilInDashboard ?? true;

    _kkmValue = widget.modul?.kkm ?? 80.0;
    _silabusItems = widget.modul?.silabusContent ?? [];

    // Inisialisasi Default 5 Kategori Penilaian Tasmi' (v2026 - Pinalti & Point-In)
    _tasmiSettings = widget.modul?.tasmiSettings ?? {
      'itqon': {'active': true, 'bobot': 40, 'pinalti_stt': 1.0, 'pinalti_t': 2.0, 'pinalti_p': 5.0},
      'makhraj': {'active': true, 'bobot': 15, 'pinalti_kurang': 0.5, 'pinalti_salah': 1.0},
      'tajwid': {'active': true, 'bobot': 15, 'pinalti_kurang': 0.5, 'pinalti_salah': 1.0},
      'adab': {'active': true, 'bobot': 15},
      'nada': {'active': true, 'bobot': 15},
    };

    // Inisialisasi Kenaikan Level
    _isExamRequired = widget.level.isExamRequired;
    _examType = widget.level.examConfig?.type ?? 'tasmi';
    _examVolume = widget.level.examConfig?.volume ?? 1.0;
    _examUnit = widget.level.examConfig?.unit ?? 'JUZ';
    _isCumulativeExam = widget.level.examConfig?.isCumulative ?? false;
    _cumulativeRange = widget.level.examConfig?.cumulativeRange ?? 5;

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
        _selectedTargetUnit = 'MATERI';
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
    final bool isTasmi = _selectedType == 'TASMI\'';
    final bool isZiyadah = _selectedType.contains('HAFALAN');
    final bool isTilawah = _selectedType.contains('TILAWAH');

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

                // Warning jika Murajaah Sabqi aktif tapi belum ada modul Murajaah
                if (isZiyadah && _showSabqiInMutabaah) _buildMurajaahWarning(),

                const SizedBox(height: 32),

                // TASMI: Sembunyikan Sumber Silabus, Metrik, Pencapaian, dan Estimasi
                if (!isTasmi) ...[
                  _buildSyllabusSourceSelector(),

                  if (_silabusSource == 'internal') _buildPlottingSection(),

                  const SizedBox(height: 32),
                  if (!isMurojaah) ...[
                    _buildStandardMetricSection(),
                    const SizedBox(height: 24),

                    _buildLabel("CAKUPAN MATERI (MULAI - AKHIR)"),
                    const SizedBox(height: 8),
                    ModulCakupanSection(
                      isPlottingActive: _isPlottingActive,
                      silabusItems: _silabusItems,
                      silabusSource: _silabusSource,
                      selectedMetrik: _selectedMetrik,
                      mulaiController: _mulaiController,
                      akhirController: _akhirController,
                      surahIdForAyat: _surahIdForAyat,
                      onSurahAyatChanged: (v) => setState(() {
                        _surahIdForAyat = v;
                        _mulaiController.clear();
                        _akhirController.clear();
                      }),
                      onRangeChanged: () => setState(() {}),
                    ),

                    const SizedBox(height: 32),
                    ModulPencapaianSection(
                      targetAmountController: _targetAmountController,
                      selectedTargetUnit: _selectedTargetUnit,
                      onUnitChanged: (v) => setState(() => _selectedTargetUnit = v),
                      onDecrement: () {
                        double v = double.tryParse(_targetAmountController.text) ?? 0;
                        if (v > 0) setState(() => _targetAmountController.text = (v - 1).toInt().toString());
                      },
                      onIncrement: () {
                        double v = double.tryParse(_targetAmountController.text) ?? 0;
                        setState(() => _targetAmountController.text = (v + 1).toInt().toString());
                      },
                    ),

                    _buildEstimationInfo(),
                  ] else
                    ModulMurojaahSection(
                      sabqiController: _sabqiController,
                      sabqiUnit: _sabqiUnit,
                      manzilType: _manzilType,
                      manzilAmountController: _manzilAmountController,
                      onSabqiUnitChanged: (v) => setState(() => _sabqiUnit = v),
                      onManzilTypeChanged: (v) => setState(() => _manzilType = v),
                    ),
                ],

                const SizedBox(height: 32),
                if (!isMurojaah) ...[
                  _buildLabel("KKM LULUS"),
                  Slider(
                    value: _kkmValue, min: 0, max: 100, divisions: 20,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) => setState(() => _kkmValue = v),
                  ),
                ],

                // TASMI: Pengaturan Gradasi Nilai Dinamis
                if (isTasmi) ...[
                  const SizedBox(height: 32),
                  _buildTasmiGradingHeader(),
                  const SizedBox(height: 16),
                  ModulTasmiSettingSection(
                    settings: _tasmiSettings,
                    onChanged: (v) => setState(() => _tasmiSettings = v),
                  ),
                ],

                // DISIPLIN: Wajib Target & Akumulasi (Sabqi/Manzil difilter di dalam)
                if (isZiyadah || isTilawah || isMurojaah) ...[
                  const SizedBox(height: 24),
                  _buildLabel("PENGATURAN KEDISIPLINAN"),
                  const SizedBox(height: 12),
                  _buildPolicySection(),
                ],

                // KENAIKAN LEVEL: Hanya tampil untuk modul utama (Bukan Murojaah/Tasmi)
                if (!isMurojaah && !isTasmi) _buildLevelExamSection(),

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

  // ===========================================================================
  // UI HELPERS & COMPONENTS
  // ===========================================================================

  Widget _buildTypeAndMeetingRow() {
    final bool isMurojaah = _selectedType == 'MUROJAAH';
    final bool isTasmi = _selectedType == 'TASMI\'';
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
                initialValue: _tipeOptions.contains(_selectedType) ? _selectedType : _tipeOptions.first,
                decoration: _inputStyle(""),
                items: _tipeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => setState(() {
                  _selectedType = v!;
                  if (v == 'MUROJAAH' || v == 'TASMI\'') _silabusSource = 'mushaf';
                }),
              ),
            ],
          ),
        ),
        if (!isMurojaah && !isTasmi) ...[
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

  Widget _buildMurajaahWarning() {
    bool hasMurojaah = widget.level.modul.any((m) => m.tipe == 'MUROJAAH');
    if (hasMurojaah) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber[200]!)),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Peringatan: Anda mengaktifkan Murajaah Sabqi, namun belum ada Modul Murajaah di level ini. Silakan buat modul Murajaah agar pencatatan sinkron.",
                style: TextStyle(fontSize: 10, color: Colors.brown, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasmiGradingHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Instruksi: Aktifkan aspek yang dinilai. Untuk Itqon/Makhraj/Tajwid pinalti dihitung sebagai pengurangan skor. Untuk Nada/Adab nilai diinput langsung oleh penguji.",
              style: TextStyle(fontSize: 11, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelExamSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        _buildLabel("PENGATURAN KENAIKAN LEVEL"),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Wajib Ujian Kenaikan Level",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("Santri harus lulus ujian untuk pindah ke level selanjutnya",
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isExamRequired,
                    activeThumbColor: const Color(0xFF10B981),
                    onChanged: (v) => setState(() => _isExamRequired = v),
                  ),
                ],
              ),
              if (_isExamRequired) ...[
                const Divider(height: 32),
                _buildLabel("TIPE UJIAN"),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _examType,
                  isExpanded: true,
                  decoration: _inputStyle(""),
                  items: const [
                    DropdownMenuItem(value: 'tasmi', child: Text("Tasmi' Sekali Duduk")),
                    DropdownMenuItem(value: 'checklist', child: Text("Mastery Checklist (Materi)")),
                  ],
                  onChanged: (v) => setState(() => _examType = v!),
                ),
                const SizedBox(height: 16),
                if (_examType == 'tasmi') ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("VOLUME UJIAN"),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _examVolume.toString(),
                              keyboardType: TextInputType.number,
                              decoration: _inputStyle("1.0"),
                              onChanged: (v) => _examVolume = double.tryParse(v) ?? 1.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("SATUAN"),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _examUnit,
                              decoration: _inputStyle(""),
                              items: const [
                                DropdownMenuItem(value: 'JUZ', child: Text("Juz")),
                                DropdownMenuItem(value: 'HALAMAN', child: Text("Halaman")),
                              ],
                              onChanged: (v) => setState(() => _examUnit = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tasmi' Bertingkat (Kumulatif)",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text("Wajib tasmi' gabungan per periode juz",
                                style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isCumulativeExam,
                        activeThumbColor: const Color(0xFF10B981),
                        onChanged: (v) => setState(() => _isCumulativeExam = v),
                      ),
                    ],
                  ),
                  if (_isCumulativeExam) ...[
                    const SizedBox(height: 8),
                    _buildLabel("KELIPATAN JUZ (MISAL: 5)"),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: _cumulativeRange.toString(),
                      keyboardType: TextInputType.number,
                      decoration: _inputStyle("5"),
                      onChanged: (v) => _cumulativeRange = int.tryParse(v) ?? 5,
                    ),
                  ],
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPolicySection() {
    final bool showMurojaahToggles = _selectedType == 'ZIYADAH HAFALAN' && _silabusSource == 'mushaf';

    return ModulPolicySection(
      isStrict: _isStrict,
      isAllowBelowTarget: _isAllowBelowTarget,
      isAccumulated: _isAccumulated,
      isSingleBurden: _isSingleBurden,
      showSabqiInMutabaah: showMurojaahToggles ? _showSabqiInMutabaah : false,
      showManzilInDashboard: showMurojaahToggles ? _showManzilInDashboard : false,
      hasMurojaahToggles: showMurojaahToggles,
      // Parameter ini akan disembunyikan visualnya di update file ModulPolicySection berikutnya
      onStrictSelected: () => setState(() { _isStrict = true; _isAllowBelowTarget = false; }),
      onToleransiSelected: () => setState(() { _isStrict = false; _isAllowBelowTarget = true; }),
      onAccumulatedSelected: () => setState(() { _isAccumulated = true; _isSingleBurden = false; }),
      onSingleBurdenSelected: () => setState(() { _isAccumulated = false; _isSingleBurden = true; }),
      onSabqiVisibilityChanged: (v) => setState(() => _showSabqiInMutabaah = v),
      onManzilVisibilityChanged: (v) => setState(() => _showManzilInDashboard = v),
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
                    activeThumbColor: const Color(0xFF10B981),
                    onChanged: (v) => setState(() {
                      _isPlottingActive = v;
                      if (v) _selectedTargetUnit = 'MATERI';
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
          initialValue: options.contains(_selectedMetrik) ? _selectedMetrik : options.first,
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

    final lembagaId = ref.watch(appContextProvider).lembaga?.id ?? '';
    final kurikulumAsync = ref.watch(kurikulumListProvider(lembagaId));

    if (kurikulumAsync.isLoading) return "Menghitung...";

    final kurikulumList = kurikulumAsync.value ?? [];
    String? targetProgramId;

    for (var k in kurikulumList) {
      bool foundInCurriculum = false;
      for (var j in k.jenjang) {
        if (j.level.any((l) => l.id == widget.level.id)) {
          targetProgramId = k.programId;
          foundInCurriculum = true;
          break;
        }
      }
      if (foundInCurriculum) break;
    }

    final String finalProgramId = targetProgramId ?? widget.level.programId ?? '';

    if (finalProgramId.isEmpty || finalProgramId == 'null') return "Jadwal Belum Diatur";

    final List<String> activeDaysStr = ref.watch(programHariEfektifProvider(finalProgramId));
    final agendas = ref.watch(agendaNotifierProvider(programId: finalProgramId)).value ?? [];

    final Map<String, int> dayMap = {
      'senin': 1, 'selasa': 2, 'rabu': 3, 'kamis': 4, 'jumat': 5, 'sabtu': 6, 'minggu': 7
    };
    final List<int> activeDays = activeDaysStr.map((d) => dayMap[d.toLowerCase()] ?? 0).where((d) => d != 0).toList();

    if (activeDays.isEmpty) return "Jadwal Belum Diatur";

    DateTime current = DateTime.now();
    int added = 0;
    int daysLimit = 0;

    while (added < meetingsNeeded && daysLimit < 1000) {
      current = current.add(const Duration(days: 1));
      final dateOnly = DateTime(current.year, current.month, current.day);
      bool isActiveDay = activeDays.contains(current.weekday);
      bool isHoliday = agendas.any((agenda) {
        if (agenda.statusHariBelajar != 'LIBUR') return false;
        final start = DateTime(agenda.tanggalMulai.year, agenda.tanggalMulai.month, agenda.tanggalMulai.day);
        final end = DateTime(agenda.tanggalBerakhir.year, agenda.tanggalBerakhir.month, agenda.tanggalBerakhir.day);
        return (dateOnly.isAtSameMomentAs(start) || dateOnly.isAtSameMomentAs(end)) ||
            (dateOnly.isAfter(start) && dateOnly.isBefore(end));
      });
      if (isActiveDay && !isHoliday) added++;
      daysLimit++;
    }

    return DateFormat('dd MMMM yyyy', 'id_ID').format(current);
  }

  // --- REUSED HELPERS ---
  Widget _buildLevelBadge() => ModulSharedWidgets.buildLevelBadge(widget.level.namaLevel);
  Widget _buildInstructionBox() => ModulSharedWidgets.buildInstructionBox();
  Widget _buildLabel(String text) => ModulSharedWidgets.buildLabel(text);
  InputDecoration _inputStyle(String hint) => ModulSharedWidgets.inputStyle(hint);

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

  Future<void> _saveModul() async {
    if (!_formKey.currentState!.validate()) return;

    // VALIDASI BOBOT TASMI 100%
    if (_selectedType == 'TASMI\'') {
      double totalBobot = 0;
      _tasmiSettings.forEach((key, value) {
        if (value['active'] == true) {
          totalBobot += (value['bobot'] as num?)?.toDouble() ?? 0.0;
        }
      });

      if (totalBobot != 100.0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menyimpan: Total bobot Tasmi' harus tepat 100% (Saat ini: ${totalBobot.toStringAsFixed(1)}%)"),
              backgroundColor: Colors.red[800],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    try {
      final bool showMurojaahToggles = _selectedType == 'ZIYADAH HAFALAN' && _silabusSource == 'mushaf';

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
        showSabqiInMutabaah: showMurojaahToggles ? _showSabqiInMutabaah : false,
        showManzilInDashboard: showMurojaahToggles ? _showManzilInDashboard : false,
        tasmiSettings: _selectedType == 'TASMI\'' ? _tasmiSettings : null,
      );

      // Catatan: Jika ada perubahan pada Level (Kenaikan Level), pastikan level juga disimpan.
      // Untuk sementara, kita fokus pada penyimpanan Modul.
      await ref.read(modulListProvider(widget.level.id!).notifier).saveModul(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unit Modul berhasil disimpan"), backgroundColor: Color(0xFF10B981)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan modul: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}