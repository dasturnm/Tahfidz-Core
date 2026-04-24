// Lokasi: lib/features/akademik/tasmi/models/tasmi_model.dart

// =============================================================================
// FILE: tasmi_model.dart
// Model untuk menampung skor mentah per kategori dan menghitung nilai akhir
// berdasarkan bobot kurikulum yang berlaku.
// =============================================================================

class TasmiScoreModel {
  final double itqon;
  final double makhraj;
  final double tajwid;
  final double adab;
  final double nada;
  final double penampilan;
  final double tebakSurah; // TAMBAHAN: Kategori ke-7

  TasmiScoreModel({
    this.itqon = 0,
    this.makhraj = 0,
    this.tajwid = 0,
    this.adab = 0,
    this.nada = 0,
    this.penampilan = 0,
    this.tebakSurah = 0,
  });

  /// Menghitung Nilai Akhir (0-100) menggunakan metode Weighted Average.
  /// Rumus: Σ(Skor_Kategori * Bobot_Kategori) / ΣTotal_Bobot
  ///
  /// Catatan:
  /// - Kategori Itqon, Makhraj, Tajwid biasanya menggunakan sistem pengurangan (Pinalti).
  /// - Kategori Adab, Nada biasanya menggunakan sistem penambahan (Point-In).
  double calculateFinalScore({
    required int bItqon,
    required int bMakhraj,
    required int bTajwid,
    required int bAdab,
    required int bNada,
    required int bPenampilan,
    required int bTebakSurah,
  }) {
    double weightedSum =
        (itqon * bItqon) +
            (makhraj * bMakhraj) +
            (tajwid * bTajwid) +
            (adab * bAdab) +
            (nada * bNada) +
            (penampilan * bPenampilan) +
            (tebakSurah * bTebakSurah);

    int totalWeight = bItqon + bMakhraj + bTajwid + bAdab + bNada + bPenampilan + bTebakSurah;

    // Jika tidak ada bobot yang diatur (0), return rata-rata sederhana dari seluruh parameter yang diisi
    if (totalWeight == 0) {
      return (itqon + makhraj + tajwid + adab + nada + penampilan + tebakSurah) / 7;
    }

    return weightedSum / totalWeight;
  }
}