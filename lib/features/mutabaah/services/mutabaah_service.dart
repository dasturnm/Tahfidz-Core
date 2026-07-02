// Lokasi: lib/features/mutabaah/services/mutabaah_service.dart

import '../../../core/services/base_service.dart';
import '../models/mutabaah_model.dart';
import '../models/mutabaah_projection_model.dart'; // TAMBAHAN: Import Model Proyeksi
import '../models/delegasi_model.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart'; // TAMBAHAN
import '../../mushaf/services/mushaf_calculator.dart'; // JOIN: Engine Utama
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // TAMBAHAN
import '../../../core/providers/app_context_provider.dart'; // TAMBAHAN
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

part 'layanan_baca_mutabaah.dart';
part 'layanan_simpan_mutabaah.dart';
part 'layanan_kecerdasan_akademik.dart';
part 'layanan_pemetaan_mushaf.dart';

class MutabaahTahfidzService extends BaseService {
  late final LayananBacaMutabaah _baca = LayananBacaMutabaah(this);
  late final LayananSimpanMutabaah _simpan = LayananSimpanMutabaah(this);
  late final LayananKecerdasanAkademik _kecerdasanAkademik = LayananKecerdasanAkademik(this);
  late final LayananPemetaanMushaf _pemetaanMushaf = LayananPemetaanMushaf(this);

  /// 1. LOGIKA KALKULASI HALAMAN & BARIS (Smart Calculation)
  Future<Map<String, dynamic>> calculateTahfidzPayload({
    required int surahMulai,
    required int ayahMulai,
    required int surahAkhir,
    required int ayahAkhir,
    double? targetAmount,
    double previousDebt = 0.0,
    String? targetUnit,
  }) => _pemetaanMushaf.calculateTahfidzPayload(
    surahMulai: surahMulai,
    ayahMulai: ayahMulai,
    surahAkhir: surahAkhir,
    ayahAkhir: ayahAkhir,
    targetAmount: targetAmount,
    previousDebt: previousDebt,
    targetUnit: targetUnit,
  );

  /// 2. READ: Mengambil riwayat mutabaah per siswa
  Future<List<MutabaahRecord>> getHistory(String siswaId) => _baca.getHistory(siswaId);

  /// 3. READ: Mengambil seluruh riwayat (Mutabaah Hub)
  Future<List<MutabaahRecord>> getAllHistory() => _baca.getAllHistory();

  /// 3b. READ: Mengambil riwayat mutabaah berdasarkan lembaga (Mutabaah Hub)
  Future<List<MutabaahRecord>> getHistoryByLembaga(Ref ref) => _baca.getHistoryByLembaga(ref);

  /// 4. CREATE: Menyimpan record mutabaah baru
  Future<void> submitRecord(MutabaahRecord record) => _simpan.submitRecord(record);

  /// TAMBAHAN OPSI B: Pemicu Otomatisasi Jalur Masuk Daftar Kesiapan Ujian
  Future<void> _evaluateExamReadiness(String siswaId, String? modulId) => _kecerdasanAkademik._evaluateExamReadiness(siswaId, modulId);

  /// TAMBAHAN: Mesin Auto-Promotion (Mengecek sisa modul & menaikkan level siswa)
  Future<void> _evaluateStudentPromotion(String siswaId) => _kecerdasanAkademik._evaluateStudentPromotion(siswaId);

  /// TAMBAHAN: Logika Auto-Next (Mendapatkan titik mulai cerdas berdasarkan setoran terakhir)
  Future<Map<String, dynamic>> getNextCoordinate(String siswaId, {ModulModel? modul}) => _pemetaanMushaf.getNextCoordinate(siswaId, modul: modul);

  /// TAMBAHAN: Konversi Baris Absolut menjadi format Manusiawi (Halaman & Baris)
  String convertLinesToHumanReadable(int totalLines) => _pemetaanMushaf.convertLinesToHumanReadable(totalLines);

  /// 5. READ: Mengambil saldo hutang terakhir (carry-over debt) untuk modul tertentu
  Future<double> getLatestDebt(String siswaId, String modulId) => _pemetaanMushaf.getLatestDebt(siswaId, modulId);

  /// 6. KALKULASI: Menghitung skor akhir Ujian Tasmi' berdasarkan setting gradasi dinamis
  double calculateTasmiScore(Map<String, dynamic> tasmiSettings, Map<String, dynamic> penaltyCounts, Map<String, double> directScores) => _kecerdasanAkademik.calculateTasmiScore(tasmiSettings, penaltyCounts, directScores);

  /// 7. READ: Mendapatkan status delegasi aktif untuk guru pengganti di kelas tertentu
  Future<DelegasiModel?> getActiveDelegation(String kelasId, String penerimaIzinId) => _baca.getActiveDelegation(kelasId, penerimaIzinId);

  /// 8. READ: Mengambil daftar Modul Aktif berdasarkan Kebijakan Kurikulum (Akses Bebas vs Sekuensial)
  Future<List<ModulModel>> getActiveModuls(Ref ref, String siswaId) => _baca.getActiveModuls(ref, siswaId);

  /// 9. READ: Mengambil daftar surah dari data_mushaf (Centralized & Fixed)
  Future<List<Map<String, dynamic>>> getSurahList() => _pemetaanMushaf.getSurahList();

  /// 10. READ / CALCULATE: Memproyeksikan estimasi kelulusan modul berdasarkan data historis
  Future<MutabaahProjectionModel> getModuleProjection(String siswaId, ModulModel modul) => _kecerdasanAkademik.getModuleProjection(siswaId, modul);

  /// 11. TAMBAHAN (Fase 2): Filter Materi Internal (Smart Hide)
  Future<List<String>> getRemainingMateri(String siswaId, ModulModel modul) => _pemetaanMushaf.getRemainingMateri(siswaId, modul);

  /// 12. PENDETEKSI SANTRI "GHAIB" (Belum Setoran Hari Ini)
  Future<List<String>> getSiswaIdsSudahSetoranHariIni(DateTime tanggal) => _baca.getSiswaIdsSudahSetoranHariIni(tanggal);
}