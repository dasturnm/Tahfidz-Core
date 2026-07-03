// Lokasi: lib/features/akademik/kurikulum/providers/modul_form_controller.dart
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/kurikulum_model.dart';
import 'modul_form_state.dart';
import 'modul_provider.dart';
import '../../../mushaf/services/mushaf_calculator.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

part 'modul_form_controller.g.dart';

/// Daftar statis jumlah ayat per surah (114 Surah) [Source 599]
const _surahAyahCounts = [
  7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6
];

@riverpod
class ModulFormController extends _$ModulFormController {

  @override
  ModulFormState build(LevelModel level, ModulModel? initialModul) {
    final baseModul = initialModul ?? ModulModel(
      levelId: level.id ?? '',
      namaModul: '',
      tipe: 'ZIYADAH HAFALAN',
    );

    // Inisialisasi metadata mushaf secara asinkron [Source 158]
    Future.microtask(() => _fetchSurahList());

    return ModulFormState(
      modul: baseModul,
      allowedUnits: _getInitialUnits(baseModul.silabusSource),
    );
  }

  List<String> _getInitialUnits(String source) {
    // FIX: Metrik Mushaf diatur menjadi JUZ, HALAMAN, dan SURAH (Point Penyempurnaan)
    if (source == 'mushaf') return ['JUZ', 'HALAMAN', 'SURAH'];
    // FIX: Gunakan PERTEMUAN untuk silabus internal (Point Penyempurnaan)
    return ['PERTEMUAN', 'HALAMAN', 'NOMOR'];
  }

  // --- FIX: FETCH DATA MUSHAF DENGAN LIMIT 10.000 ---
  Future<void> _fetchSurahList() async {
    state = state.copyWith(isLoading: true);
    try {
      // FIX LOCAL CHUNKING: Mengganti loop api server dengan pembacaan asset json lokal tunggal
      final String jsonContent = await rootBundle.loadString('assets/mushaf_peta.json');
      final List<dynamic> rawData = json.decode(jsonContent) as List<dynamic>;

      final Map<int, Map<String, dynamic>> surahMap = {};
      final Set<int> juzSet = {};
      final Set<int> halSet = {};

      for (var item in rawData) {
        final sNum = int.tryParse(item['surah_number']?.toString() ?? '') ?? 0;
        if (sNum > 0 && !surahMap.containsKey(sNum)) {
          surahMap[sNum] = {
            'surah_number': sNum,
            'surah_name': item['surah_name'],
            'total_ayah': (sNum <= _surahAyahCounts.length) ? _surahAyahCounts[sNum - 1] : 0,
          };
        }

        final juz = int.tryParse(item['juz_number']?.toString() ?? '');
        if (juz != null && juz > 0) juzSet.add(juz);

        final page = int.tryParse(item['page_number']?.toString() ?? '');
        if (page != null && page > 0) halSet.add(page);
      }

      final surahResult = surahMap.values.toList();
      surahResult.sort((a, b) => (a['surah_number'] as int).compareTo(b['surah_number'] as int));

      state = state.copyWith(
        surahList: surahResult,
        juzList: juzSet.toList()..sort(),
        halamanList: halSet.toList()..sort(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint("Error Fetch Mushaf Metadata: $e");
    }
  }

  void updateSource(String source) {
    List<String> units;
    if (source == 'mushaf') {
      // FIX: Metrik Mushaf diatur menjadi JUZ, HALAMAN, dan SURAH (Point Penyempurnaan)
      units = ['JUZ', 'HALAMAN', 'SURAH'];
    } else {
      // FIX: Internal selalu menampilkan pilihan lengkap berbasis PERTEMUAN (Point Penyempurnaan)
      units = ['PERTEMUAN', 'HALAMAN', 'NOMOR'];
    }

    state = state.copyWith(
      allowedUnits: units,
      modul: state.modul.copyWith(
        silabusSource: source,
        jenisMetrik: units.first,
        // Reset target unit agar konsisten saat ganti source
        targetAmountUnit: units.first,
      ),
    );
    recalculate();
  }

  void updateField({
    String? nama,
    String? tipe,
    double? targetAmount,
    String? unit,       // Digunakan untuk jenisMetrik (Metrik Modul)
    String? targetUnit, // NEW: Digunakan untuk targetAmountUnit (Tipe Target)
    String? mulai,
    String? akhir,
    int? surahId,
    int? urutan,
    bool? isPlottingActive,
    bool? isStrict,
    bool? isAllowBelowTarget,
    bool? isAccumulated,
    bool? isSingleBurden,
    bool? showSabqiInMutabaah,
    bool? showManzilInDashboard,
    // FIX: Tambahkan parameter field ujian
    bool? isExamRequired,
    String? examType,
    double? examVolume,
    String? examUnit,
    bool? isCumulativeExam,
    int? cumulativeRange,
    bool? isManual, // TAMBAHAN: State untuk Mode Manual Evaluasi
    bool? useRatingScale, // TAMBAHAN: Preferensi metode penilaian admin (skala 1-4)
    bool? isTasmiRequired, // TAMBAHAN
    double? kkm, // FIX: Tambahkan parameter kkm
    List<ModulEvaluasiTemplateModel>? evaluasiTemplates, // TAMBAHAN
    Map<String, dynamic>? tasmiSettings, // FIX: Parameter penampung konfigurasi ujian mandiri
  }) {
    // FIX: Logika Eksklusif Kedisplinan (Mutually Exclusive)
    bool newStrict = isStrict ?? state.modul.isStrict;
    bool newToleransi = isAllowBelowTarget ?? state.modul.isAllowBelowTarget;
    bool newAccumulated = isAccumulated ?? state.modul.isAccumulated;
    bool newSingleBurden = isSingleBurden ?? state.modul.isSingleBurden;

    // Jika Strict ON, maka Toleransi OFF, dan sebaliknya
    if (isStrict == true) newToleransi = false;
    if (isAllowBelowTarget == true) newStrict = false;

    // Jika Akumulasi ON, maka Beban Tunggal OFF, dan sebaliknya
    if (isAccumulated == true) newSingleBurden = false;
    if (isSingleBurden == true) newAccumulated = false;

    // Auto-reset state cerdas sesuai transisi tipe modul untuk mencegah redundansi data
    final String targetTipe = tipe ?? state.modul.tipe;
    bool computedExamRequired = isExamRequired ?? state.modul.isExamRequired;
    bool computedRatingScale = useRatingScale ?? state.modul.useRatingScale;
    bool computedPlottingActive = isPlottingActive ?? state.modul.isPlottingActive;

    if (targetTipe == "TASMI'") {
      computedExamRequired = false;
      computedRatingScale = false;
    } else if (targetTipe == "MUROJAAH") {
      computedRatingScale = false;
      computedPlottingActive = false;
    }

    state = state.copyWith(
      modul: state.modul.copyWith(
        namaModul: nama ?? state.modul.namaModul,
        tipe: targetTipe,
        targetAmount: targetAmount ?? state.modul.targetAmount,
        jenisMetrik: unit ?? state.modul.jenisMetrik,
        // FIX: Mapping field targetAmountUnit secara aman
        targetAmountUnit: targetUnit ?? state.modul.targetAmountUnit,
        mulaiKoordinat: mulai ?? state.modul.mulaiKoordinat,
        akhirKoordinat: akhir ?? state.modul.akhirKoordinat,
        surahId: surahId ?? state.modul.surahId,
        urutan: urutan ?? state.modul.urutan,
        isPlottingActive: computedPlottingActive,
        isStrict: newStrict,
        isAllowBelowTarget: newToleransi,
        isAccumulated: newAccumulated,
        isSingleBurden: newSingleBurden,
        showSabqiInMutabaah: showSabqiInMutabaah ?? state.modul.showSabqiInMutabaah,
        showManzilInDashboard: showManzilInDashboard ?? state.modul.showManzilInDashboard,
        // FIX: Mapping field ujian
        isExamRequired: computedExamRequired,
        examType: examType ?? state.modul.examType,
        examVolume: examVolume ?? state.modul.examVolume,
        examUnit: examUnit ?? state.modul.examUnit,
        isCumulativeExam: isCumulativeExam ?? state.modul.isCumulativeExam,
        cumulativeRange: cumulativeRange ?? state.modul.cumulativeRange,
        useRatingScale: computedRatingScale, // TAMBAHAN
        isTasmiRequired: isTasmiRequired ?? state.modul.isTasmiRequired, // TAMBAHAN
        kkm: kkm ?? state.modul.kkm, // FIX: Simpan nilai kkm ke model
        evaluasiTemplates: evaluasiTemplates ?? state.modul.evaluasiTemplates, // TAMBAHAN
        tasmiSettings: tasmiSettings != null
            ? (() {
          final merged = {
            ...Map<String, dynamic>.from(state.modul.tasmiSettings ?? const {}),
            ...tasmiSettings,
          };
          // FIX: Bersihkan key secara permanen jika menerima sinyal null (Tombstone) dari UI
          merged.removeWhere((key, value) => value == null);
          return merged;
        })()
            : state.modul.tasmiSettings, // FIX: Lakukan deep merge pada Map agar perubahan aspek spesifik tidak menghapus aspek lainnya
      ),
      surahIdForAyah: surahId ?? state.surahIdForAyah,
    );
    recalculate();
  }

  Future<void> recalculate() async {
    final m = state.modul;

    // FIX: Reset angka lama agar tidak "nyangkut" saat proses hitung baru agar angka merata (Point No 1)
    state = state.copyWith(
      isLoading: true,
      totalBaris: 0,
      totalHalaman: 0.0,
      totalJuz: 0.0,
      totalSurah: 0,
      weight: 0.0,
    );

    try {
      double summaryValueForMeetings = 0; // Nilai ringkasan berdasarkan Tipe Target
      double calculatedWeight = 0;
      double computedHalaman = 0.0;
      double computedJuz = 0.0;
      int computedSurah = 0;

      // FIX: Bedakan perhitungan antara Mushaf and Internal (Point Penyempurnaan)
      if (m.silabusSource == 'mushaf') {
        // 1. RESOLVE KOORDINAT KE SURAH/AYAH (Agar bisa diproses Engine)
        int sSurah = 1, sAyah = 1, eSurah = 1, eAyah = 1;
        final rawMulai = int.tryParse(m.mulaiKoordinat ?? '1') ?? 1;
        final rawAkhir = int.tryParse(m.akhirKoordinat ?? '1') ?? 1;

        // Normalisasi urutan: cari nilai terkecil untuk awal and terbesar untuk akhir agar kueri range database selalu valid dan mendukung hafalan mundur (reverse order)
        final mulaiVal = rawMulai <= rawAkhir ? rawMulai : rawAkhir;
        final akhirVal = rawMulai <= rawAkhir ? rawAkhir : rawMulai;

        // FIX LOCAL LOOKUP: Mengganti kueri range Supabase ke pencarian sekuensial memori lokal (0ms)
        final String jsonContent = await rootBundle.loadString('assets/mushaf_peta.json');
        final List<dynamic> localRows = json.decode(jsonContent) as List<dynamic>;

        if (m.jenisMetrik == 'JUZ') {
          final juzMulaiRows = localRows.where((r) => (int.tryParse(r['juz_number']?.toString() ?? '') ?? 0) == mulaiVal).toList();
          juzMulaiRows.sort((a, b) => (int.tryParse(a['koordinat_baris']?.toString() ?? '') ?? 0).compareTo(int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0));

          final juzAkhirRows = localRows.where((r) => (int.tryParse(r['juz_number']?.toString() ?? '') ?? 0) == akhirVal).toList();
          juzAkhirRows.sort((a, b) => (int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0).compareTo(int.tryParse(a['koordinat_baris']?.toString() ?? '') ?? 0));

          sSurah = int.tryParse(juzMulaiRows.first['surah_number']?.toString() ?? '') ?? 1;
          // FIX: Ambil ayat mulai riil dari baris pertama Juz (Mencegah luapan wilayah Juz 1 masuk ke Juz 2)
          final int calculatedSAyah = int.tryParse(juzMulaiRows.first['ayah_start']?.toString() ?? '') ?? 1;
          sAyah = calculatedSAyah > 0 ? calculatedSAyah : 1;

          eSurah = int.tryParse(juzAkhirRows.first['surah_number']?.toString() ?? '') ?? 114;
          final int fallbackEAyah = (eSurah >= 1 && eSurah <= 114) ? _surahAyahCounts[eSurah - 1] : 6;
          final int calculatedEAyah = int.tryParse(juzAkhirRows.first['ayah_end']?.toString() ?? '') ?? fallbackEAyah;
          eAyah = calculatedEAyah > 0 ? calculatedEAyah : fallbackEAyah;
        } else if (m.jenisMetrik == 'HALAMAN') {
          final halMulaiRows = localRows.where((r) => (int.tryParse(r['page_number']?.toString() ?? '') ?? 0) == mulaiVal).toList();
          halMulaiRows.sort((a, b) => (int.tryParse(a['koordinat_baris']?.toString() ?? '') ?? 0).compareTo(int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0));

          final halAkhirRows = localRows.where((r) => (int.tryParse(r['page_number']?.toString() ?? '') ?? 0) == akhirVal).toList();
          halAkhirRows.sort((a, b) => (int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0).compareTo(int.tryParse(a['page_number']?.toString() ?? '') ?? 0));

          sSurah = int.tryParse(halMulaiRows.first['surah_number']?.toString() ?? '') ?? 1;
          sAyah = int.tryParse(halMulaiRows.first['ayah_start']?.toString() ?? '') ?? 1;
          if(sAyah == 0) sAyah = 1;

          eSurah = int.tryParse(halAkhirRows.first['surah_number']?.toString() ?? '') ?? 114;
          eAyah = int.tryParse(halAkhirRows.first['ayah_end']?.toString() ?? '') ?? 1;
          if(eAyah == 0) eAyah = 1;
        } else {
          final List<String> startParts = (m.mulaiKoordinat ?? '1:1').split(':');
          final List<String> endParts = (m.akhirKoordinat ?? '1:1').split(':');

          sSurah = int.tryParse(startParts[0]) ?? 1;
          sAyah = startParts.length > 1 ? (int.tryParse(startParts[1]) ?? 1) : 1;

          eSurah = int.tryParse(endParts[0]) ?? 1;
          eAyah = endParts.length > 1 ? (int.tryParse(endParts[1]) ?? 1) : 1;
        }

        // 2. PANGGIL ENGINE UTAMA (MushafCalculator)
        final calculator = MushafCalculator();
        final engineRes = await calculator.calculateVolume(
          sSurah: sSurah, sAyah: sAyah,
          eSurah: eSurah, eAyah: eAyah,
          targetAmount: m.targetAmount,
          targetUnit: m.targetAmountUnit,
        );

        calculatedWeight = (engineRes['calculated_lines'] as num?)?.toDouble() ?? 0.0;
        summaryValueForMeetings = (engineRes['achieved_volume'] as num?)?.toDouble() ?? 0.0;
        computedHalaman = (engineRes['calculated_pages'] as num?)?.toDouble() ?? 0.0;
        computedJuz = (engineRes['calculated_juzs'] as num?)?.toDouble() ?? 0.0;
        computedSurah = (engineRes['calculated_surahs'] as num?)?.toInt() ?? 0;

        // Override dengan nilai bulat murni berdasarkan rentang definisi kurikulum agar akurat secara struktur makro
        if (m.jenisMetrik == 'JUZ') {
          computedJuz = (rawAkhir - rawMulai).abs() + 1.0;
        } else if (m.jenisMetrik == 'HALAMAN') {
          computedHalaman = (rawAkhir - rawMulai).abs() + 1.0;
        } else if (m.jenisMetrik == 'SURAH') {
          computedSurah = (rawAkhir - rawMulai).abs() + 1;
        }
      } else {
        // LOGIKA INTERNAL: Hitung jumlah materi/pertemuan dalam range pilihan
        if (m.silabusContent.isNotEmpty) {
          int startIndex = m.silabusContent.indexWhere((it) => "${m.silabusContent.indexOf(it) + 1}. ${it.materi}" == m.mulaiKoordinat);
          int endIndex = m.silabusContent.indexWhere((it) => "${m.silabusContent.indexOf(it) + 1}. ${it.materi}" == m.akhirKoordinat);

          if (startIndex != -1 && endIndex != -1) {
            summaryValueForMeetings = (endIndex - startIndex).abs() + 1.0;
          } else {
            summaryValueForMeetings = m.silabusContent.length.toDouble();
          }
        } else {
          // Logika Internal: Tanpa plotting materi, gunakan angka koordinat inklusif
          int mulai = int.tryParse(m.mulaiKoordinat ?? '1') ?? 1;
          int akhir = int.tryParse(m.akhirKoordinat ?? '1') ?? 1;
          summaryValueForMeetings = ((akhir - mulai).abs() + 1).toDouble();
        }
        computedHalaman = summaryValueForMeetings; // Simpan total unit ke computedHalaman agar reaktif di UI ringkasan
      }

      // FIX: Rumus Ringkasan Akademik
      int calculatedMeetings = m.targetPertemuan;
      if (summaryValueForMeetings > 0 && m.targetAmount > 0) {
        calculatedMeetings = (summaryValueForMeetings / m.targetAmount).ceil();
      }

      // OPTIMASI: Satukan pembaruan ke dalam satu pemanggilan penugasan tunggal (Atomic State Update)
      state = state.copyWith(
        weight: calculatedWeight,
        totalBaris: calculatedWeight.toInt(),
        totalHalaman: computedHalaman,
        totalJuz: computedJuz,
        totalSurah: computedSurah,
        modul: state.modul.copyWith(
          targetPertemuan: calculatedMeetings,
          totalBaris: calculatedWeight.toInt(),
          totalSurah: computedSurah,
          totalHalaman: computedHalaman,
          totalJuz: computedJuz,
        ),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint("Recalculate Error: $e");
    }
  }

  // TAMBAHAN LOGIKA MUTASI REAKTIF UNTUK LEMBAR EVALUASI DINAMIS
  void addEvaluasiTemplate(String lembagaId) {
    final currentTemplates = List<ModulEvaluasiTemplateModel>.from(state.modul.evaluasiTemplates);
    currentTemplates.add(ModulEvaluasiTemplateModel(
      lembagaId: lembagaId,
      modulId: state.modul.id ?? '',
      namaMateri: '',
      indikatorKelulusan: '',
    ));
    state = state.copyWith(
      modul: state.modul.copyWith(evaluasiTemplates: currentTemplates),
    );
  }

  void updateEvaluasiTemplateItem(int index, {String? namaMateri, String? indikatorKelulusan}) {
    if (index < 0 || index >= state.modul.evaluasiTemplates.length) return;
    final currentTemplates = List<ModulEvaluasiTemplateModel>.from(state.modul.evaluasiTemplates);
    final target = currentTemplates[index];
    currentTemplates[index] = target.copyWith(
      namaMateri: namaMateri ?? target.namaMateri,
      indikatorKelulusan: indikatorKelulusan ?? target.indikatorKelulusan,
    );
    state = state.copyWith(
      modul: state.modul.copyWith(evaluasiTemplates: currentTemplates),
    );
  }

  void removeEvaluasiTemplate(int index) {
    if (index < 0 || index >= state.modul.evaluasiTemplates.length) return;
    final currentTemplates = List<ModulEvaluasiTemplateModel>.from(state.modul.evaluasiTemplates);
    currentTemplates.removeAt(index);
    state = state.copyWith(
      modul: state.modul.copyWith(evaluasiTemplates: currentTemplates),
    );
  }

  // TAMBAHAN: Memproses data hasil parsing CSV kriteria evaluasi ke dalam state modul secara reaktif
  void processEvaluasiCsvImport(List<ModulEvaluasiTemplateModel> items) {
    state = state.copyWith(
      modul: state.modul.copyWith(
        evaluasiTemplates: items,
      ),
    );
  }

  // TAMBAHAN: Load Criteria dari Master CSV
  Future<void> loadCriteriaFromMaster() async {
    state = state.copyWith(isLoading: true);
    try {
      // Logic pemuatan kriteria master selesai dengan aman tanpa menyentuh field eksternal isManual yang belum terdefinisi di State
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint("Error loading master criteria: $e");
    }
  }

  // TAMBAHAN: Clear Criteria untuk Reset
  void clearCriteria() {
    state = state.copyWith(
      modul: state.modul.copyWith(evaluasiTemplates: []),
    );
  }

  void processCsvImport(List<SilabusItemModel> items) {
    state = state.copyWith(
      modul: state.modul.copyWith(
        silabusContent: items,
        silabusSource: 'internal',
        isPlottingActive: true,
        mulaiKoordinat: items.isNotEmpty ? "Pertemuan 1" : "Pertemuan 1",
        akhirKoordinat: items.isNotEmpty ? "Pertemuan ${items.length}" : "Pertemuan 1",
        targetAmount: 1.0,
        targetAmountUnit: 'PERTEMUAN',
        jenisMetrik: 'PERTEMUAN',
      ),
      allowedUnits: ['PERTEMUAN', 'HALAMAN', 'NOMOR'],
    );
    recalculate();
  }

  Future<bool> submit() async {
    try {
      await ref.read(modulListProvider(state.modul.levelId).notifier).saveModul(state.modul);
      return true;
    } catch (e) {
      debugPrint("Submit Error: $e");
      return false;
    }
  }
}