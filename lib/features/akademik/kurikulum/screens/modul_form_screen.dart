// Lokasi: lib/features/akademik/kurikulum/screens/modul_form_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart' as csv_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/kurikulum_model.dart';
import '../providers/modul_form_controller.dart';
import '../providers/modul_form_state.dart';
import 'components/modul_shared_widgets.dart';
import 'components/modul_policy_section.dart';
import 'components/modul_murojaah_section.dart';
import 'components/modul_pencapaian_section.dart';
import 'components/modul_cakupan_section.dart';
import 'components/modul_tasmi_setting_section.dart';
import 'components/modul_exam_section.dart';
import 'components/modul_estimation_card.dart';

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
  final TextEditingController _mulaiAyatController = TextEditingController(text: '1'); // Inisialisasi instan tanpa kata kunci late
  final TextEditingController _akhirAyatController = TextEditingController(text: '1'); // Inisialisasi instan tanpa kata kunci late
  late TextEditingController _sabqiController;
  late TextEditingController _manzilAmountController;
  late TextEditingController _urutanController;

  final List<String> _tipeOptions = ['ZIYADAH HAFALAN', 'ZIYADAH TILAWAH', 'MUROJAAH', 'TAHSIN', 'DINIYAH'];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);

    final m = widget.modul;
    // Set teks pengontrol ayat secara defensif setelah objek terbuat sempurna
    if (m != null) {
      if (m.ayahStart != null) _mulaiAyatController.text = m.ayahStart.toString();
      if (m.ayahEnd != null) _akhirAyatController.text = m.ayahEnd.toString();
    }

    _namaController = TextEditingController(text: m?.namaModul ?? '');
    _targetPertemuanController = TextEditingController(text: (m?.targetPertemuan ?? 30).toString());
    _targetAmountController = TextEditingController(text: (m?.targetAmount ?? 0.0).toInt().toString());
    _silabusController = TextEditingController(text: m?.silabus ?? '');
    _mulaiController = TextEditingController(text: m?.mulaiKoordinatJuz ?? '');
    _akhirController = TextEditingController(text: m?.akhirKoordinatJuz ?? '');
    _sabqiController = TextEditingController(text: (m?.sabqiAmount ?? 0).toString());
    _manzilAmountController = TextEditingController(text: (m?.manzilAmount ?? 0.0).toString());
    _urutanController = TextEditingController(text: (m?.urutan ?? 0).toString());

    _mulaiController.addListener(_updateControllerFields);
    _akhirController.addListener(_updateControllerFields);
    _targetAmountController.addListener(_updateControllerFields);
    _mulaiAyatController.addListener(_updateControllerFields); // Sinkronisasi reaktif data ayat mulai
    _akhirAyatController.addListener(_updateControllerFields); // Sinkronisasi reaktif data ayat akhir

    if (m != null) {
      Future.microtask(() => ref.read(modulFormControllerProvider(widget.level, widget.modul).notifier).recalculate());
    }
  }

  void _updateControllerFields() {
    ref.read(modulFormControllerProvider(widget.level, widget.modul).notifier).updateField(
      nama: _namaController.text,
      mulai: _mulaiController.text,
      akhir: _akhirController.text,
      ayahStart: int.tryParse(_mulaiAyatController.text), // Pengiriman data ayat terpisah dari teks koordinat surah/juz
      ayahEnd: int.tryParse(_akhirAyatController.text),   // Pengiriman data ayat terpisah dari teks koordinat surah/juz
      targetAmount: double.tryParse(_targetAmountController.text),
      urutan: int.tryParse(_urutanController.text),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _targetPertemuanController.dispose();
    _targetAmountController.dispose();
    _silabusController.dispose();
    _mulaiController.dispose();
    _akhirController.dispose();
    _mulaiAyatController.dispose(); // Cegah kebocoran memori kontroler baru
    _akhirAyatController.dispose(); // Cegah kebocoran memori kontroler baru
    _sabqiController.dispose();
    _manzilAmountController.dispose();
    _urutanController.dispose();
    super.dispose();
  }

  Future<void> _downloadTemplate() async {
    List<List<String>> csvData = [["pertemuan", "materi", "keterangan"], ["1", "Materi", "Deskripsi"]];
    String csvContent = csv_pkg.CsvCodec().encoder.convert(csvData);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/template_silabus.csv');
    await file.writeAsString(csvContent);
    if (mounted) await Share.shareXFiles([XFile(file.path)], subject: 'Template Silabus CSV');
  }

  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv'], withData: true);
    if (result != null) {
      final input = utf8.decode(result.files.single.bytes!);
      List<List<dynamic>> rows = csv_pkg.CsvCodec().decoder.convert(input);
      List<SilabusItemModel> newItems = [];
      for (var i = 1; i < rows.length; i++) {
        if (rows[i].isNotEmpty && rows[i].length >= 2) {
          newItems.add(SilabusItemModel(pertemuan: int.tryParse(rows[i][0].toString()) ?? i, materi: rows[i][1].toString(), keterangan: rows[i].length > 2 ? rows[i][2].toString() : null));
        }
      }
      ref.read(modulFormControllerProvider(widget.level, widget.modul).notifier).processCsvImport(newItems);

      if (newItems.isNotEmpty) {
        _mulaiController.text = "1. ${newItems.first.materi}";
        _akhirController.text = "${newItems.length}. ${newItems.last.materi}";
      }
      _targetAmountController.text = "1";
    }
  }

  Future<void> _downloadEvaluasiTemplate() async {
    List<List<String>> csvData = [["aspek", "indikator_kelulusan"], ["Makhraj", "Santri lancar mengucapkan huruf tanpa terbata-bata"]];
    String csvContent = csv_pkg.CsvCodec().encoder.convert(csvData);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/template_evaluasi.csv');
    await file.writeAsString(csvContent);
    if (mounted) await Share.shareXFiles([XFile(file.path)], subject: 'Template Lembar Evaluasi CSV');
  }

  Future<void> _importEvaluasiCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv'], withData: true);
    if (result != null) {
      final input = utf8.decode(result.files.single.bytes!);
      List<List<dynamic>> rows = csv_pkg.CsvCodec().decoder.convert(input);
      List<ModulEvaluasiTemplateModel> newTemplates = [];
      final currentModul = ref.read(modulFormControllerProvider(widget.level, widget.modul)).modul;

      for (var i = 1; i < rows.length; i++) {
        if (rows[i].isNotEmpty && rows[i].length >= 2) {
          newTemplates.add(ModulEvaluasiTemplateModel(
            modulId: currentModul.id ?? '',
            lembagaId: '',
            namaMateri: rows[i][0].toString(),
            indikatorKelulusan: rows[i][1].toString(),
          ));
        }
      }
      ref.read(modulFormControllerProvider(widget.level, widget.modul).notifier).processEvaluasiCsvImport(newTemplates);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(modulFormControllerProvider(widget.level, widget.modul));
    final notifier = ref.read(modulFormControllerProvider(widget.level, widget.modul).notifier);

    final bool isEdit = widget.modul != null;
    final m = state.modul;

    final bool isMurojaah = m.tipe == 'MUROJAAH';
    final bool isTasmi = m.tipe == 'TASMI\'';
    final bool isZiyadah = m.tipe.contains('HAFALAN');
    final bool isTilawah = m.tipe.contains('TILAWAH');

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
                ModulSharedWidgets.buildLevelBadge(widget.level.namaLevel),
                const SizedBox(height: 24),
                ModulSharedWidgets.buildInstructionBox(),
                const SizedBox(height: 32),

                ModulSharedWidgets.buildLabel("URUTAN / SEQUENCE MODUL"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _urutanController,
                  keyboardType: TextInputType.number,
                  decoration: ModulSharedWidgets.inputStyle("Misal: 1"),
                  onChanged: (_) => _updateControllerFields(),
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 24),

                ModulSharedWidgets.buildLabel("NAMA MODUL"),
                const SizedBox(height: 8),
                TextFormField(controller: _namaController, decoration: ModulSharedWidgets.inputStyle("Misal: Juz 30"), validator: (v) => v!.isEmpty ? "Wajib diisi" : null),

                const SizedBox(height: 24),
                _buildTypeRow(m, notifier, isZiyadah, isTasmi),

                const SizedBox(height: 32),
                if (!isTasmi) ...[
                  _buildSyllabusSourceSelector(m, notifier),
                  if (m.silabusSource == 'internal')...[
                    _buildPlottingSection(m, notifier),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 32),
                  if (!isMurojaah) ...[
                    if (m.silabusSource == 'mushaf' && state.isLoading && state.surahList.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32), child: CircularProgressIndicator(color: Color(0xFF10B981))))
                    else ...[
                      _buildStandardMetricSection(m, state, notifier),
                      const SizedBox(height: 24),
                      ModulSharedWidgets.buildLabel("CAKUPAN MATERI (MULAI - AKHIR)"),
                      const SizedBox(height: 8),
                      ModulCakupanSection(
                        isPlottingActive: m.isPlottingActive,
                        silabusItems: m.silabusContent,
                        silabusSource: m.silabusSource,
                        selectedMetrik: m.jenisMetrik,
                        mulaiController: _mulaiController,
                        akhirController: _akhirController,
                        mulaiAyatController: _mulaiAyatController, // Menyuntikkan pemisahan kontroler ayat ke UI
                        akhirAyatController: _akhirAyatController, // Menyuntikkan pemisahan kontroler ayat ke UI
                        surahIdForAyah: state.surahIdForAyah,
                        surahList: state.surahList,
                        juzList: state.juzList,
                        halamanList: state.halamanList,
                        onSurahChanged: (v) {
                          _mulaiController.clear();
                          _akhirController.clear();
                          notifier.updateSurahForAyah(v);
                          notifier.updateField(surahIdStart: v, mulai: '', akhir: ''); // Izinkan surahIdEnd dikelola secara mandiri oleh ModulCakupanSection
                        },
                        onRangeChanged: () => notifier.recalculate(),
                      ),
                      _buildMaterialSummary(state, notifier),
                      const SizedBox(height: 32),
                      ModulPencapaianSection(
                        targetAmountController: _targetAmountController,
                        selectedTargetUnit: m.targetAmountUnit,
                        allowedUnits: m.silabusSource == 'mushaf'
                            ? (state.allowedUnits.contains('BARIS') ? state.allowedUnits : [...state.allowedUnits, 'BARIS'])
                            : state.allowedUnits,
                        onUnitChanged: (v) => notifier.updateField(targetUnit: v),
                        onDecrement: () {
                          double v = double.tryParse(_targetAmountController.text) ?? 0;
                          if (v > 0) _targetAmountController.text = (v - 1).toInt().toString();
                        },
                        onIncrement: () {
                          double v = double.tryParse(_targetAmountController.text) ?? 0;
                          _targetAmountController.text = (v + 1).toInt().toString();
                        },
                      ),
                      ModulEstimationCard(
                        levelId: widget.level.id!,
                        programIdFromLevel: widget.level.programId ?? '',
                        targetPertemuan: m.targetPertemuan.toString(),
                        onRefresh: () => notifier.recalculate(),
                      ),
                    ],
                  ] else
                    ModulMurojaahSection(
                      sabqiController: _sabqiController,
                      sabqiUnit: m.sabqiAmountUnit,
                      manzilType: m.manzilType,
                      manzilAmountController: _manzilAmountController,
                      onSabqiUnitChanged: (v) => notifier.updateField(unit: v),
                      onManzilTypeChanged: (v) => notifier.updateField(unit: v),
                    ),
                ],

                const SizedBox(height: 32),
                if (!isMurojaah) ...[
                  ModulSharedWidgets.buildLabel("KKM LULUS"),
                  Theme(
                    data: Theme.of(context).copyWith(
                      sliderTheme: const SliderThemeData(
                        valueIndicatorColor: Color(0xFF10B981),
                        valueIndicatorTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    child: Slider(
                        value: m.kkm, min: 0, max: 100, divisions: 20,
                        label: m.kkm.round().toString(),
                        activeColor: const Color(0xFF10B981),
                        onChanged: (v) => notifier.updateField(kkm: v)
                    ),
                  ),
                ],

                if (m.tipe != 'TASMI\'' && m.tipe != 'MUROJAAH') ...[
                  SwitchListTile(
                    title: const Text("Gunakan Skala Penilaian 1-4", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Mengganti parameter input angka nilai setoran harian menjadi standar kompetensi deskriptif pada rekam mutabaah harian santri.", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    value: m.useRatingScale,
                    activeThumbColor: const Color(0xFF10B981),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => notifier.updateField(useRatingScale: v),
                  ),
                ],

                if (isZiyadah || isTilawah || isMurojaah) ...[
                  const SizedBox(height: 24),
                  ModulSharedWidgets.buildLabel("PENGATURAN KEDISPLINAN"),
                  const SizedBox(height: 12),
                  _buildPolicySection(m, notifier),
                ],

                if (m.tipe != 'MUROJAAH') ...[
                  const SizedBox(height: 24),
                  EvaluationUnifiedSection(
                    m: m,
                    notifier: notifier,
                    onDownloadTemplate: _downloadEvaluasiTemplate,
                    onUploadCSV: _importEvaluasiCSV,
                  ),
                ],

                const SizedBox(height: 40),
                if (state.isLoading)
                  const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32), child: CircularProgressIndicator(color: Color(0xFF10B981))))
                else
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      onPressed: _saveModul,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                      ),
                      child: Text(
                          isEdit ? "PERBARUI UNIT MODUL" : "SIMPAN UNIT MODUL",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
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

  Widget _buildTypeRow(ModulModel m, ModulFormController notifier, bool isZiyadah, bool isTasmi) {
    bool hasTasmiInLevel = widget.level.modul.any((mod) => mod.tipe == "TASMI'") || m.tipe == "TASMI'";

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ModulSharedWidgets.buildLabel("TIPE MODUL"),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: _tipeOptions.contains(m.tipe) ? m.tipe : _tipeOptions.first,
        decoration: ModulSharedWidgets.inputStyle(""),
        items: _tipeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
        onChanged: (v) => Future.microtask(() => notifier.updateField(tipe: v)),
      ),
      if (isZiyadah && m.showSabqiInMutabaah) _buildMurajaahWarning(),
      if (hasTasmiInLevel) _buildTasmiWarning(),
    ]);
  }

  Widget _buildMurajaahWarning() {
    bool hasMurojaah = widget.level.modul.any((m) => m.tipe == 'MUROJAAH');
    if (hasMurojaah) return const SizedBox.shrink();
    return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber[200]!)),
            child: const Row(children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text("Peringatan: Anda mengaktifkan Murajaah Sabqi, namun belum ada Modul Murajaah di level ini.", style: TextStyle(fontSize: 10, color: Colors.brown, fontWeight: FontWeight.w500)))
            ])
        )
    );
  }

  Widget _buildTasmiWarning() {
    return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue[200]!)),
            child: const Row(children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text("Peringatan: Anda mengaktifkan Tasmi Sekali Duduk, pastikan target volume sudah disetting dengan benar di bawah.", style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w500)))
            ])
        )
    );
  }

  Widget _buildPolicySection(ModulModel m, ModulFormController notifier) {
    final bool showMurojaahToggles = (m.tipe == 'ZIYADAH HAFALAN' || m.tipe == 'MUROJAAH') && m.silabusSource == 'mushaf';
    return Column(
      children: [
        ModulPolicySection(
            isStrict: m.isStrict,
            isAllowBelowTarget: m.isAllowBelowTarget,
            isAccumulated: m.isAccumulated,
            isSingleBurden: m.isSingleBurden,
            showSabqiInMutabaah: m.showSabqiInMutabaah,
            showManzilInDashboard: m.showManzilInDashboard,
            hasMurojaahToggles: showMurojaahToggles,
            onStrictSelected: () => notifier.updateField(isStrict: !m.isStrict),
            onToleransiSelected: () => notifier.updateField(isAllowBelowTarget: !m.isAllowBelowTarget),
            onAccumulatedSelected: () => notifier.updateField(isAccumulated: !m.isAccumulated),
            onSingleBurdenSelected: () => notifier.updateField(isSingleBurden: !m.isSingleBurden),
            onInfoAccumulated: () => _showInfoDialog(context, "Akumulasi", "Sisa target akan dibebankan pada pertemuan selanjutnya."),
            onInfoSingleBurden: () => _showInfoDialog(context, "Beban Tunggal", "Sisa target tidak dibebankan pada pertemuan selanjutnya."),
            onSabqiVisibilityChanged: (v) => notifier.updateField(showSabqiInMutabaah: v),
            onManzilVisibilityChanged: (v) => notifier.updateField(showManzilInDashboard: v)
        ),
      ],
    );
  }

  Widget _buildPlottingSection(ModulModel m, ModulFormController notifier) {
    if (m.tipe == 'MUROJAAH') return const SizedBox.shrink();

    return Column(children: [
      const SizedBox(height: 24),
      Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Aktifkan Plotting Materi Harian", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("Buat silabus untuk menentukan materi per pertemuan", style: TextStyle(fontSize: 11, color: Colors.grey))
              ])),
              Switch(
                  value: m.isPlottingActive,
                  activeThumbColor: const Color(0xFF10B981),
                  onChanged: (v) => notifier.updateField(isPlottingActive: v)
              )
            ]),
            if (m.isPlottingActive) ...[
              const Divider(height: 32),
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: _importCSV, icon: const Icon(Icons.upload_file), label: const Text("IMPORT CSV"))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(onPressed: _downloadTemplate, icon: const Icon(Icons.download), label: const Text("TEMPLATE")))
              ])
            ]
          ])
      )
    ]);
  }

  Widget _buildStandardMetricSection(ModulModel m, ModulFormState state, ModulFormController notifier) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ModulSharedWidgets.buildLabel("STANDAR METRIK MODUL"),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showInfoDialog(context, "Standar Metrik", m.jenisMetrik == 'JUZ' ? "Estimasi dihitung berdasarkan koordinat baris ayat pertama pada Juz awal hingga ayat terakhir pada Juz akhir." : "Estimasi dihitung berdasarkan letak baris fisik ayat di halaman tersebut."),
          child: const Icon(Icons.info_outline, size: 16, color: Colors.grey),
        ),
      ]),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: state.allowedUnits.contains(m.jenisMetrik) ? m.jenisMetrik : state.allowedUnits.first,
        decoration: ModulSharedWidgets.inputStyle("Pilih Satuan"),
        items: state.allowedUnits.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
        onChanged: (v) => notifier.updateField(unit: v),
      )
    ]);
  }

  Widget _buildSyllabusSourceSelector(ModulModel m, ModulFormController notifier) {
    final bool isMurojaah = m.tipe == 'MUROJAAH';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ModulSharedWidgets.buildLabel("SUMBER SILABUS"),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _sourceButton("Mushaf", 'mushaf', Icons.menu_book_rounded, m.silabusSource == 'mushaf', notifier)),
        if (!isMurojaah) ...[
          const SizedBox(width: 12),
          Expanded(child: _sourceButton("Internal", 'internal', Icons.assignment_rounded, m.silabusSource == 'internal', notifier))
        ]
      ])
    ]);
  }

  Widget _sourceButton(String label, String value, IconData icon, bool isSelected, ModulFormController notifier) {
    return InkWell(
        onTap: () => notifier.updateSource(value),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey[300]!)
            ),
            child: Column(children: [
              Icon(icon, color: isSelected ? const Color(0xFF10B981) : Colors.grey),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF10B981) : Colors.grey))
            ])
        )
    );
  }

  Widget _buildMaterialSummary(ModulFormState state, ModulFormController notifier) {
    final bool isInternal = state.modul.silabusSource == 'internal';
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blueGrey[100]!)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("RINGKASAN MATERI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
              IconButton(padding: EdgeInsets.zero, constraints: const BoxConstraints(), icon: const Icon(Icons.refresh, size: 18, color: Colors.blueGrey), onPressed: () => notifier.recalculate()),
            ],
          ),
          const Divider(),
          if (isInternal)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem("Total Materi/Halaman", state.totalHalaman.toStringAsFixed(0)),
                _summaryItem("Estimasi Pertemuan", state.modul.targetPertemuan.toString()),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem("Juz", state.totalJuz.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")),
                _summaryItem("Hal", state.totalHalaman.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "")),
                _summaryItem("Surah", state.totalSurah.toString(), tooltip: "Setiap bagian surah yang ada di dalam Juz/Halaman yang dipilih dihitung sebagai 1 surah."),
                _summaryItem("Baris", state.totalBaris.toString(), tooltip: "Nama Surah dan Basmalah tidak dihitung sebagai total baris"),
              ],
            ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, {String? tooltip}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF10B981))),
            if (tooltip != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showInfoDialog(context, "Informasi $label", tooltip),
                child: const Icon(Icons.info_outline, size: 12, color: Colors.blueGrey),
              ),
            ],
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(fontSize: 13)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("MENGERTI", style: TextStyle(color: Color(0xFF10B981)))),
        ],
      ),
    );
  }

  Future<void> _saveModul() async {
    _updateControllerFields();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(modulFormControllerProvider(widget.level, widget.modul).notifier).submit();
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unit Modul berhasil disimpan"), backgroundColor: Color(0xFF10B981)));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan modul"), backgroundColor: Colors.red));
      }
    }
  }
}

class EvaluationUnifiedSection extends StatelessWidget {
  final ModulModel m;
  final ModulFormController notifier;
  final VoidCallback onDownloadTemplate;
  final VoidCallback onUploadCSV;

  const EvaluationUnifiedSection({
    super.key,
    required this.m,
    required this.notifier,
    required this.onDownloadTemplate,
    required this.onUploadCSV,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTasmiTypeSelected = m.examType.trim().toLowerCase() == 'tasmi';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("PENGATURAN EVALUASI & UKL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10B981))),
              Switch(
                value: m.isExamRequired,
                activeThumbColor: const Color(0xFF10B981),
                onChanged: (v) => notifier.updateField(isExamRequired: v),
              ),
            ],
          ),
          const Divider(height: 24),

          ModulExamSection(
            silabusSource: m.silabusSource,
            isExamRequired: m.isExamRequired,
            examType: m.examType,
            examVolume: m.examVolume,
            examUnit: m.examUnit,
            isCumulativeExam: m.isCumulativeExam,
            cumulativeRange: m.cumulativeRange,
            onRequiredChanged: (v) => notifier.updateField(isExamRequired: v),
            onTypeChanged: (v) => Future.microtask(() => notifier.updateField(examType: v)),
            onVolumeChanged: (v) => notifier.updateField(examVolume: double.tryParse(v)),
            onUnitChanged: (v) => notifier.updateField(examUnit: v),
            onCumulativeChanged: (v) => notifier.updateField(isCumulativeExam: v),
            onRangeChanged: (v) => notifier.updateField(cumulativeRange: int.tryParse(v)),
            evaluationTemplates: m.evaluasiTemplates,
            formNotifier: notifier,
          ),

          if (m.isExamRequired && isTasmiTypeSelected) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Instruksi: Atur bobot proporsional aspek penilaian Ujian Tasmi' terintegrasi di bawah ini.",
                      style: TextStyle(fontSize: 11, color: Colors.blue),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            ModulTasmiSettingSection(
              settings: {
                ...Map<String, dynamic>.from(m.tasmiSettings ?? {}),
                'silabus_source': m.silabusSource,
              },
              onChanged: (v) => notifier.updateField(tasmiSettings: v),
            ),
          ],

          if (m.isExamRequired && (m.examType.trim().toUpperCase() == 'CHECKLIST' || m.examType == 'LEMBARAN_EVALUASI')) ...[
            const SizedBox(height: 16),
            if (m.evaluasiTemplates.isEmpty) ...[
              Column(
                children: [
                  const Text("Belum ada kriteria evaluasi", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: onDownloadTemplate, child: const Text("Download Template"))),
                      const SizedBox(width: 8),
                      Expanded(child: ElevatedButton(onPressed: onUploadCSV, child: const Text("Upload CSV"))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(onPressed: () => notifier.addEvaluasiTemplate(''), child: const Text("Input Manual")),
                  ),
                ],
              )
            ],
          ],
        ],
      ),
    );
  }
}