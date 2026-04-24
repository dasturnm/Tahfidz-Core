// Lokasi: lib/features/akademik/tasmi/providers/tasmi_provider.dart

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tasmi_model.dart';
import '../../kurikulum/models/kurikulum_model.dart';

part 'tasmi_provider.g.dart';

@riverpod
class TasmiNotifier extends _$TasmiNotifier {
  final _supabase = Supabase.instance.client;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Fungsi untuk menyimpan hasil ujian Tasmi'
  Future<void> simpanHasilTasmi({
    required String siswaId,
    required ModulModel modul,
    required TasmiScoreModel skor,
    String? catatan,
  }) async {
    state = const AsyncValue.loading();

    try {
      final String guruId = _supabase.auth.currentUser!.id;

      // 1. Hitung Nilai Akhir secara resmi
      final double nilaiAkhir = skor.calculateFinalScore(
        bItqon: modul.bobotItqon,
        bMakhraj: modul.bobotMakhraj,
        bTajwid: modul.bobotTajwid,
        bAdab: modul.bobotAdab,
        bNada: modul.bobotNada,
        bPenampilan: modul.bobotPenampilan,
        bTebakSurah: modul.bobotTebakSurah, // FIX ERROR: Menambahkan parameter yang wajib ada
      );

      final bool isLulus = nilaiAkhir >= modul.kkm;

      // 2. Susun Payload JSON untuk kolom data_payload
      final Map<String, dynamic> payload = {
        'jenis_record': 'TASMI',
        'nama_modul': modul.namaModul,
        'skor_detail': {
          'itqon': skor.itqon,
          'makhraj': skor.makhraj,
          'tajwid': skor.tajwid,
          'adab': skor.adab,
          'nada': skor.nada,
          'penampilan': skor.penampilan,
          'tebak_surah': skor.tebakSurah, // PENYEMPURNAAN: Detail skor lengkap
        },
        'bobot_app': {
          'itqon': modul.bobotItqon,
          'makhraj': modul.bobotMakhraj,
          'tajwid': modul.bobotTajwid,
          'adab': modul.bobotAdab,
          'nada': modul.bobotNada, // PENYEMPURNAAN: Metadata bobot lengkap
          'penampilan': modul.bobotPenampilan,
          'tebak_surah': modul.bobotTebakSurah,
        },
        'nilai_akhir': nilaiAkhir,
        'kkm_saat_ujian': modul.kkm,
        'status_lulus': isLulus,
        'tanggal_ujian': DateTime.now().toIso8601String(),
        // Nomor Sertifikat (Logika Sederhana: TSM-ID_SISWA-TIMESTAMP)
        'nomor_sertifikat': 'TSM-${DateTime.now().millisecondsSinceEpoch}',
      };

      // 3. Simpan ke Tabel mutabaah_records
      await _supabase.from('mutabaah_records').insert({
        'siswa_id': siswaId,
        'guru_id': guruId,
        'modul_id': modul.id,
        'tipe_modul': 'TASMI',
        'data_payload': payload,
        'catatan': catatan ?? (isLulus ? "Lulus Ujian Tasmi'" : "Belum Lulus Tasmi'"),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint("Error simpanHasilTasmi: $e");
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}