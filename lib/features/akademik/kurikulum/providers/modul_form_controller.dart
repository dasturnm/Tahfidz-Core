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
    // KEMBALIKAN: Opsi target pencapaian harian tetap mendukung pilihan lengkap
    if (source == 'mushaf') return ['JUZ', 'HALAMAN', 'SURAH'];
    // FIX: Gunakan PERTEMUAN untuk silabus internal (Point Penyempurnaan)
    return ['PERTEMUAN', 'HALAMAN', 'NOMOR'];
  }

  // TAMBAHAN: Helper untuk batas ayat
  int getAyahCount(int surahId) {
    if (surahId < 1 || surahId > _surahAyahCounts.length) return 0;
    return _surahAyahCounts[surahId - 1];
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
      // KEMBALIKAN: Opsi target pencapaian harian tetap mendukung pilihan lengkap
      units = ['JUZ', 'HALAMAN', 'SURAH'];
    } else {
      // FIX: Internal selalu menampilkan pilihan lengkap berbasis PERTEMUAN (Point Penyempurnaan)
      units = ['PERTEMUAN', 'HALAMAN', 'NOMOR'];
    }

    state = state.copyWith(
      allowedUnits: units,
      modul: state.modul.copyWith(
        silabusSource: source,
        jenisMetrik: source == 'mushaf' ? 'SURAH' : units.first, // Cakupan materi dikunci ke SURAH, target pencapaian menggunakan allowedUnits
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
    int? surahIdStart,
    int? surahIdEnd,
    int? ayahStart,
    int? ayahEnd,
    int? mulaiHalaman,
    int? akhirHalaman,
    int? targetInternalAkhir,
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
    String? evaluationType,
    double? tasmiVolume,
    String? tasmiUnit,
    bool? isCumulativeTasmi,
    int? tasmiRange,
    bool? isManual,
    bool? useRatingScale,
    bool? isTasmiRequired,
    bool? isReverseOrder,
    double? kkm,
    List<ModulEvaluasiTemplateModel>? evaluasiTemplates,
    Map<String, dynamic>? sertifikasiSettings,
    bool? isMurojaah,
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
    bool newIsMurojaah = isMurojaah ?? state.modul.isMurojaah;

    if (targetTipe == "TASMI'") {
      computedExamRequired = false;
      computedRatingScale = false;
    }
    if (newIsMurojaah) {
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
        mulaiKoordinatJuz: (unit ?? state.modul.jenisMetrik) == 'JUZ' ? (mulai ?? state.modul.mulaiKoordinatJuz) : state.modul.mulaiKoordinatJuz,
        akhirKoordinatJuz: (unit ?? state.modul.jenisMetrik) == 'JUZ' ? (akhir ?? state.modul.akhirKoordinatJuz) : state.modul.akhirKoordinatJuz,
        ayahStart: ayahStart ?? state.modul.ayahStart,
        ayahEnd: ayahEnd ?? state.modul.ayahEnd,
        mulaiHalaman: (unit ?? state.modul.jenisMetrik) == 'HALAMAN' ? (int.tryParse(mulai ?? '') ?? state.modul.mulaiHalaman) : (mulaiHalaman ?? state.modul.mulaiHalaman),
        akhirHalaman: (unit ?? state.modul.jenisMetrik) == 'HALAMAN' ? (int.tryParse(akhir ?? '') ?? state.modul.akhirHalaman) : (akhirHalaman ?? state.modul.akhirHalaman),
        surahIdStart: (unit ?? state.modul.jenisMetrik) == 'SURAH' ? (int.tryParse(mulai ?? '') ?? surahIdStart ?? state.modul.surahIdStart) : (surahIdStart ?? state.modul.surahIdStart),
        surahIdEnd: (unit ?? state.modul.jenisMetrik) == 'SURAH' ? (int.tryParse(akhir ?? '') ?? surahIdEnd ?? state.modul.surahIdEnd) : (surahIdEnd ?? state.modul.surahIdEnd),
        targetInternalAkhir: targetInternalAkhir ?? state.modul.targetInternalAkhir,
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
        evaluationType: evaluationType ?? state.modul.evaluationType,
        tasmiVolume: tasmiVolume ?? state.modul.tasmiVolume,
        tasmiUnit: tasmiUnit ?? state.modul.tasmiUnit,
        isCumulativeTasmi: isCumulativeTasmi ?? state.modul.isCumulativeTasmi,
        tasmiRange: tasmiRange ?? state.modul.tasmiRange,
        useRatingScale: computedRatingScale,
        isTasmiRequired: isTasmiRequired ?? state.modul.isTasmiRequired,
        isReverseOrder: isReverseOrder ?? state.modul.isReverseOrder,
        kkm: kkm ?? state.modul.kkm,
        evaluasiTemplates: evaluasiTemplates ?? state.modul.evaluasiTemplates,
        isMurojaah: newIsMurojaah,
        sertifikasiSettings: sertifikasiSettings != null
            ? (() {
          final merged = {
            ...Map<String, dynamic>.from(state.modul.sertifikasiSettings ?? const {}),
            ...sertifikasiSettings,
          };
          // FIX: Bersihkan key secara permanen jika menerima sinyal null (Tombstone) dari UI
          merged.removeWhere((key, value) => value == null);
          return merged;
        })()
            : state.modul.sertifikasiSettings,
      ),
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
      int sSurah = m.surahIdStart;
      int eSurah = m.surahIdEnd;
      int sAyah = m.ayahStart;
      int eAyah = m.ayahEnd;
      int mHal = m.mulaiHalaman;
      int aHal = m.akhirHalaman;
      int calculatedMeetings = m.targetPertemuan;

      // FIX: Bedakan perhitungan antara Mushaf and Internal (Point Penyempurnaan)
      if (m.silabusSource == 'mushaf') {
        // 1. RESOLVE KOORDINAT KE SURAH/AYAH (Agar bisa diproses Engine)
        final rawMulai = m.jenisMetrik == 'HALAMAN' ? m.mulaiHalaman : (int.tryParse(m.mulaiKoordinatJuz ?? '1') ?? 1);
        final rawAkhir = m.jenisMetrik == 'HALAMAN' ? m.akhirHalaman : (int.tryParse(m.akhirKoordinatJuz ?? '1') ?? 1);

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
          juzAkhirRows.sort((a, b) => (int.tryParse(a['koordinat_baris']?.toString() ?? '') ?? 0).compareTo(int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0));

          sSurah = int.tryParse(juzMulaiRows.first['surah_number']?.toString() ?? '') ?? 1;
          sAyah = int.tryParse(juzMulaiRows.first['ayah_start']?.toString() ?? '') ?? 1;

          eSurah = int.tryParse(juzAkhirRows.last['surah_number']?.toString() ?? '') ?? 114;
          final int fallbackEAyah = (eSurah >= 1 && eSurah <= 114) ? _surahAyahCounts[eSurah - 1] : 6;
          eAyah = int.tryParse(juzAkhirRows.last['ayah_end']?.toString() ?? '') ?? fallbackEAyah;
        } else if (m.jenisMetrik == 'HALAMAN') {
          final halMulaiRows = localRows.where((r) => (int.tryParse(r['page_number']?.toString() ?? '') ?? 0) == mulaiVal).toList();
          halMulaiRows.sort((a, b) => (int.tryParse(a['koordinat_baris']?.toString() ?? '') ?? 0).compareTo(int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0));

          final halAkhirRows = localRows.where((r) => (int.tryParse(r['page_number']?.toString() ?? '') ?? 0) == akhirVal).toList();
          halAkhirRows.sort((a, b) => (int.tryParse(a['koordinat_baris']?.toString() ?? '') ?? 0).compareTo(int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0));

          mHal = mulaiVal;
          aHal = akhirVal;

          sSurah = int.tryParse(halMulaiRows.first['surah_number']?.toString() ?? '') ?? 1;
          sAyah = int.tryParse(halMulaiRows.first['ayah_start']?.toString() ?? '') ?? 1;

          eSurah = int.tryParse(halAkhirRows.last['surah_number']?.toString() ?? '') ?? 114;
          eAyah = int.tryParse(halAkhirRows.last['ayah_end']?.toString() ?? '') ?? 1;
        } else {
          // Metrik SURAH - Auto-Normalisasi (Start selalu <= End untuk Database)
          final s = m.surahIdStart > 0 ? m.surahIdStart : 1;
          final e = m.surahIdEnd > 0 ? m.surahIdEnd : 114;

          sSurah = s < e ? s : e;
          eSurah = s < e ? e : s;

          // Ayah mengikuti surah yang terpilih
          sAyah = (s < e) ? (m.ayahStart > 0 ? m.ayahStart : 1) : (m.ayahEnd > 0 ? m.ayahEnd : getAyahCount(eSurah));
          eAyah = (s < e) ? (m.ayahEnd > 0 ? m.ayahEnd : getAyahCount(eSurah)) : (m.ayahStart > 0 ? m.ayahStart : 1);
        }

        // 2. PANGGIL ENGINE UTAMA (MushafCalculator)
        final calculator = MushafCalculator();
        final engineRes = await calculator.calculateVolume(
          sSurah: sSurah, sAyah: sAyah,
          eSurah: eSurah, eAyah: eAyah,
          targetAmount: m.targetAmount,
          targetUnit: m.targetAmountUnit,
        );

        // PENTING: Hanya gunakan engineRes untuk ringkasan volume, JANGAN untuk baris
        summaryValueForMeetings = (engineRes['achieved_volume'] as num?)?.toDouble() ?? 0.0;
        computedHalaman = (engineRes['calculated_pages'] as num?)?.toDouble() ?? 0.0;
        computedJuz = (engineRes['calculated_juzs'] as num?)?.toDouble() ?? 0.0;
        computedSurah = (engineRes['calculated_surahs'] as num?)?.toInt() ?? 0;

        int finalStartSurah = engineRes['start_surah'] ?? sSurah;
        int finalEndSurah = engineRes['end_surah'] ?? eSurah;
        int finalStartAyah = engineRes['start_ayah'] ?? sAyah;
        int finalEndAyah = engineRes['end_ayah'] ?? eAyah;

        int startPageFromRows = mHal;
        int endPageFromRows = aHal;
        String startJuzFromRows = m.mulaiKoordinatJuz ?? '1';
        String endJuzFromRows = m.akhirKoordinatJuz ?? '1';

        if (localRows.isNotEmpty) {
          final sRow = localRows.firstWhere((r) => (int.tryParse(r['surah_number']?.toString() ?? '') ?? 0) == finalStartSurah && (int.tryParse(r['ayah_start']?.toString() ?? '') ?? 0) <= finalStartAyah && (int.tryParse(r['ayah_end']?.toString() ?? '') ?? 0) >= finalStartAyah, orElse: () => null);
          final eRow = localRows.firstWhere((r) => (int.tryParse(r['surah_number']?.toString() ?? '') ?? 0) == finalEndSurah && (int.tryParse(r['ayah_start']?.toString() ?? '') ?? 0) <= finalEndAyah && (int.tryParse(r['ayah_end']?.toString() ?? '') ?? 0) >= finalEndAyah, orElse: () => null);
          if (sRow != null) {
            startPageFromRows = int.tryParse(sRow['page_number']?.toString() ?? '') ?? mHal;
            startJuzFromRows = sRow['juz_number']?.toString() ?? startJuzFromRows;
          }
          if (eRow != null) {
            endPageFromRows = int.tryParse(eRow['page_number']?.toString() ?? '') ?? aHal;
            endJuzFromRows = eRow['juz_number']?.toString() ?? endJuzFromRows;
          }

          // FIX: Hitung Total Baris Murni secara Fisik (Hanya menghitung baris Ayat, mengabaikan header Surah/Basmalah)
          int lineCount = 0;
          for (var r in localRows) {
            final sNum = int.tryParse(r['surah_number']?.toString() ?? '') ?? 0;
            final aStart = int.tryParse(r['ayah_start']?.toString() ?? '') ?? 0;
            final aEnd = int.tryParse(r['ayah_end']?.toString() ?? '') ?? 0;

            // Abaikan metadata/header (basmalah/nama surah) yang tidak memiliki nomor ayat awal
            if (sNum == 0 || aStart == 0) continue;

            if (sNum > finalStartSurah && sNum < finalEndSurah) {
              lineCount++;
            } else if (finalStartSurah == finalEndSurah) {
              if (sNum == finalStartSurah && aEnd >= finalStartAyah && aStart <= finalEndAyah) {
                lineCount++;
              }
            } else {
              if (sNum == finalStartSurah && aEnd >= finalStartAyah) {
                lineCount++;
              }
              if (sNum == finalEndSurah && aStart <= finalEndAyah) {
                lineCount++;
              }
            }
          }
          // FORCE OVERRIDE: Pastikan total baris mutlak dari hasil filter fisik, abaikan engine
          calculatedWeight = lineCount.toDouble();
        } else {
          // Fallback jika json kosong
          calculatedWeight = 0.0;
        }

        // FIX: Tangkap nilai bersih di satu variabel
        final int finalTotalBaris = calculatedWeight.toInt();

        // Normalisasi Nilai Tampilan Ringkasan Juz & Halaman agar selalu bulat presisi (baik input normal maupun terbalik)
        if (m.jenisMetrik == 'JUZ') {
          final int juzMulai = int.tryParse(m.mulaiKoordinatJuz ?? '1') ?? 1;
          final int juzAkhir = int.tryParse(m.akhirKoordinatJuz ?? '1') ?? 1;
          computedJuz = ((juzAkhir - juzMulai).abs() + 1).toDouble();
          computedHalaman = computedJuz * 20.0; // Standard halaman per juz
        } else if (m.jenisMetrik == 'HALAMAN') {
          computedHalaman = ((aHal - mHal).abs() + 1).toDouble();
          computedJuz = computedHalaman / 20.0;
        } else if (m.jenisMetrik == 'SURAH') {
          // Jika metrik surah, bulatkan secara matematis mengikuti rentang sekuens fisik halaman koordinat
          computedHalaman = ((endPageFromRows - startPageFromRows).abs() + 1).toDouble();
          computedJuz = computedHalaman / 20.0;
        }

        if (summaryValueForMeetings > 0 && m.targetAmount > 0) {
          calculatedMeetings = (summaryValueForMeetings / m.targetAmount).ceil();
        }

        state = state.copyWith(
          weight: calculatedWeight,
          totalBaris: finalTotalBaris,
          totalHalaman: computedHalaman,
          totalJuz: computedJuz,
          totalSurah: computedSurah,
          surahIdForAyah: finalStartSurah > 0 ? finalStartSurah : state.surahIdForAyah,
          modul: state.modul.copyWith(
            targetPertemuan: calculatedMeetings,
            totalBaris: finalTotalBaris,
            // Auto-Normalisasi: Pastikan Database selalu menyimpan (Start <= End)
            surahIdStart: sSurah < eSurah ? sSurah : eSurah,
            surahIdEnd: sSurah < eSurah ? eSurah : sSurah,
            ayahStart: sSurah < eSurah ? sAyah : eAyah,
            ayahEnd: sSurah < eSurah ? eAyah : sAyah,
            mulaiHalaman: startPageFromRows < endPageFromRows ? startPageFromRows : endPageFromRows,
            akhirHalaman: startPageFromRows < endPageFromRows ? endPageFromRows : startPageFromRows,
            mulaiKoordinatJuz: (int.tryParse(startJuzFromRows) ?? 0) < (int.tryParse(endJuzFromRows) ?? 0) ? startJuzFromRows : endJuzFromRows,
            akhirKoordinatJuz: (int.tryParse(startJuzFromRows) ?? 0) < (int.tryParse(endJuzFromRows) ?? 0) ? endJuzFromRows : startJuzFromRows,
            totalSurah: computedSurah,
            totalHalaman: computedHalaman,
            totalJuz: computedJuz,
          ),
          isLoading: false,
        );
        return;
      } else {
        // LOGIKA INTERNAL
        if (m.silabusContent.isNotEmpty) {
          int startIndex = m.silabusContent.indexWhere((it) => "${m.silabusContent.indexOf(it) + 1}. ${it.materi}" == m.mulaiKoordinatJuz);
          int endIndex = m.silabusContent.indexWhere((it) => "${m.silabusContent.indexOf(it) + 1}. ${it.materi}" == m.akhirKoordinatJuz);
          summaryValueForMeetings = (startIndex != -1 && endIndex != -1) ? (endIndex - startIndex).abs() + 1.0 : m.silabusContent.length.toDouble();
        } else {
          int mulai = int.tryParse(m.mulaiKoordinatJuz ?? '1') ?? 1;
          int akhir = int.tryParse(m.akhirKoordinatJuz ?? '1') ?? 1;
          summaryValueForMeetings = ((akhir - mulai).abs() + 1).toDouble();
        }
        computedHalaman = summaryValueForMeetings;
      }

      // FIX: Rumus Ringkasan Akademik
      if (summaryValueForMeetings > 0 && m.targetAmount > 0) {
        calculatedMeetings = (summaryValueForMeetings / m.targetAmount).ceil();
      }

      // FIX: Tangkap nilai bersih di satu variabel
      final int finalTotalBaris = calculatedWeight.toInt();

      // OPTIMASI: Satukan pembaruan ke dalam satu pemanggilan penugasan tunggal (Atomic State Update)
      state = state.copyWith(
        weight: calculatedWeight,
        totalBaris: finalTotalBaris,
        totalHalaman: computedHalaman,
        totalJuz: computedJuz,
        totalSurah: computedSurah,
        modul: state.modul.copyWith(
          targetPertemuan: calculatedMeetings,
          totalBaris: finalTotalBaris,
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
        mulaiKoordinatJuz: items.isNotEmpty ? "Pertemuan 1" : "Pertemuan 1",
        akhirKoordinatJuz: items.isNotEmpty ? "Pertemuan ${items.length}" : "Pertemuan 1",
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
      // Selalu lakukan kalkulasi ulang tepat sebelum penyimpanan objek ke database untuk memastikan totalBaris and ringkasan valid
      await recalculate();
      await ref.read(modulListProvider(state.modul.levelId).notifier).saveModul(state.modul);
      return true;
    } catch (e) {
      debugPrint("Submit Error: $e");
      return false;
    }
  }

  void updateSurahForAyah(int surahId) {
    state = state.copyWith(surahIdForAyah: surahId);
    recalculate();
  }
}