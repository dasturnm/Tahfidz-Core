import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahfidz_core/features/akademik/kurikulum/models/modul_model.dart';

class LayananStatusModul {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengecek apakah konten materi di dalam modul sudah habis dipelajari secara fisik
  Future<bool> isContentCompleted(String siswaId, ModulModel modul) async {
    try {
      // 1. Ambil setoran terakhir yang BUKAN status "ULANG" (-1)
      final lastRecord = await _supabase
          .from('mutabaah_records')
          .select()
          .eq('siswa_id', siswaId)
          .eq('modul_id', modul.id ?? '')
          .neq('status_keputusan', -1) // EXCLUDE REPEAT RECORDS
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (lastRecord == null) return false;

      if (modul.silabusSource == 'mushaf') {
        // PARSING COORDINATES (Contoh modul: "2:286")
        final targetParts = modul.akhirKoordinat!.split(':');
        final targetSurah = int.parse(targetParts[0]);
        final targetAyat = int.parse(targetParts[1]);

        final currentSurah = lastRecord['surah_id'] as int;
        final currentAyay = lastRecord['ayah_end'] as int;

        // VALIDASI KOORDINAT FISIK
        if (currentSurah > targetSurah) return true;
        return (currentSurah == targetSurah && currentAyay >= targetAyat);
      } else {
        // VALIDASI INTERNAL (Keputusan Lanjut + Mencapai Baris Terakhir)
        final totalCakupan = modul.silabusContent.length;
        return (lastRecord['internal_end'] >= totalCakupan && lastRecord['status_keputusan'] == 1);
      }
    } catch (_) {
      return false;
    }
  }

  /// Mengecek apakah siswa telah lulus ujian formal untuk modul terkait di tabel evaluasi nilai
  Future<bool> isExamPassed(String siswaId, String modulId) async {
    try {
      final response = await _supabase
          .from('siswa_evaluasi_nilai')
          .select()
          .eq('siswa_id', siswaId)
          .eq('modul_id', modulId)
          .eq('is_lulus', true)
          .maybeSingle();
      return response != null;
    } catch (_) {
      return false;
    }
  }

  /// Menentukan apakah modul benar-benar tuntas secara administratif and boleh ditinggalkan
  Future<bool> isFinalCompleted(String siswaId, ModulModel modul) async {
    final contentDone = await isContentCompleted(siswaId, modul);
    if (!contentDone) return false;

    // Jika modul mewajibkan ujian (UKL/Tasmi), harus lulus ujian terlebih dahulu
    if (modul.isExamRequired == true) {
      return await isExamPassed(siswaId, modul.id ?? '');
    }

    // Jika tidak wajib ujian, otomatis dianggap selesai final saat konten habis
    return true;
  }
}