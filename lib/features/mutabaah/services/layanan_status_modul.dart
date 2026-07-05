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
        int targetSurah = modul.surahId;
        int targetAyat = modul.ayahEnd;

        if (modul.akhirKoordinat != null && modul.akhirKoordinat!.contains(':')) {
          final targetParts = modul.akhirKoordinat!.split(':');
          if (targetParts.length >= 2) {
            targetSurah = int.tryParse(targetParts[0]) ?? targetSurah;
            targetAyat = int.tryParse(targetParts[1]) ?? targetAyat;
          }
        }

        final currentSurah = int.tryParse(lastRecord['surah_id']?.toString() ?? '0') ?? 0;
        final currentAyay = int.tryParse(lastRecord['ayah_end']?.toString() ?? '0') ?? 0;

        // VALIDASI KOORDINAT FISIK
        if (currentSurah > targetSurah) return true;
        return (currentSurah == targetSurah && currentAyay >= targetAyat);
      } else {
        // VALIDASI INTERNAL (Keputusan Lanjut + Mencapai Baris Terakhir)
        final int totalCakupan = modul.totalBaris > 0
            ? modul.totalBaris
            : (modul.silabusContent.isNotEmpty ? modul.silabusContent.length : modul.materiSilabus.length);

        final int currentInternalEnd = int.tryParse(lastRecord['internal_end']?.toString() ?? '0') ?? 0;

        return currentInternalEnd >= totalCakupan;
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