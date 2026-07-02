// Lokasi: lib/features/akademik/kurikulum/providers/modul_form_state.dart

import '../models/kurikulum_model.dart';

class ModulFormState {
  final ModulModel modul;
  final bool isLoading;
  final bool isManual;
  final List<String> allowedUnits;
  final List<dynamic> surahList;
  final List<int> juzList;
  final List<int> halamanList;
  final int? surahIdForAyah;
  final double weight; // Total volume dalam satuan baris
  final double totalJuz;
  final double totalHalaman;
  final int totalSurah;
  final int totalBaris;
  final DateTime? estimatedEndDate;

  ModulFormState({
    required this.modul,
    this.isLoading = false,
    this.isManual = false,
    this.allowedUnits = const ['JUZ', 'SURAH', 'HALAMAN', 'AYAT'],
    this.surahList = const [],
    this.juzList = const [],
    this.halamanList = const [],
    this.surahIdForAyah,
    this.weight = 0.0,
    this.totalJuz = 0.0,
    this.totalHalaman = 0.0,
    this.totalSurah = 0,
    this.totalBaris = 0,
    this.estimatedEndDate,
  });

  ModulFormState copyWith({
    ModulModel? modul,
    bool? isLoading,
    bool? isManual,
    List<String>? allowedUnits,
    List<dynamic>? surahList,
    List<int>? juzList,
    List<int>? halamanList,
    int? surahIdForAyah,
    double? weight,
    double? totalJuz,
    double? totalHalaman,
    int? totalSurah,
    int? totalBaris,
    DateTime? estimatedEndDate,
  }) {
    return ModulFormState(
      modul: modul ?? this.modul,
      isLoading: isLoading ?? this.isLoading,
      isManual: isManual ?? this.isManual,
      allowedUnits: allowedUnits ?? this.allowedUnits,
      surahList: surahList ?? this.surahList,
      juzList: juzList ?? this.juzList,
      halamanList: halamanList ?? this.halamanList,
      surahIdForAyah: surahIdForAyah ?? this.surahIdForAyah,
      weight: weight ?? this.weight,
      totalJuz: totalJuz ?? this.totalJuz,
      totalHalaman: totalHalaman ?? this.totalHalaman,
      totalSurah: totalSurah ?? this.totalSurah,
      totalBaris: totalBaris ?? this.totalBaris,
      estimatedEndDate: estimatedEndDate ?? this.estimatedEndDate,
    );
  }
}