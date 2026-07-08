// Lokasi: lib/features/mutabaah/services/layanan_status_modul.dart
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
        // PARSING COORDINATES
        int targetSurah = 0;
        int targetAyat = 0;

        if (modul.akhirKoordinat != null && modul.akhirKoordinat!.contains(':')) {
          final targetParts = modul.akhirKoordinat!.split(':');
          if (targetParts.length >= 2) {
            targetSurah = int.tryParse(targetParts[0]) ?? 0;
            targetAyat = int.tryParse(targetParts[1]) ?? 0;
          }
        }
        // Jika tidak ada di akhirKoordinat, coba ambil dari surahId/ayahEnd (hanya jika > 0)
        if (targetSurah == 0) {
          int tempSurah = modul.surahId;
          int tempAyah = modul.ayahEnd;
          if (tempSurah > 0 && tempAyah > 0) {
            targetSurah = tempSurah;
            targetAyat = tempAyah;
          } else {
            // Target tidak terdefinisi secara valid.
            // Anggap modul selesai agar tidak looping di daftar modul aktif.
            return true;
          }
        }

        // FIX: Menggunakan end_surah_id sebagai titik acuan akhir setoran
        final int endSurahFromDb = int.tryParse(lastRecord['end_surah_id']?.toString() ?? '0') ?? 0;
        final currentSurah = endSurahFromDb > 0 ? endSurahFromDb : (int.tryParse(lastRecord['surah_id']?.toString() ?? '0') ?? 0);
        final currentAyay = int.tryParse(lastRecord['ayah_end']?.toString() ?? '0') ?? 0;

        // VALIDASI KOORDINAT FISIK
        if (currentSurah > targetSurah) return true;
        return (currentSurah == targetSurah && currentAyay >= targetAyat);
      } else {
        // VALIDASI INTERNAL
        if (modul.isPlottingActive) {
          // Floating: bandingkan nomor urut materi dengan total materi
          final int totalMateri = modul.extractedMateriList.length;
          if (totalMateri == 0) return false;
          final int currentIndex = int.tryParse(lastRecord['nomor_urut_materi']?.toString() ?? '0') ?? 0;
          // Indeks berbasis 0, jadi max index = totalMateri - 1
          // Tambahkan pengecekan apakah record terakhir memiliki status LANJUT (status_keputusan == 1)
          final int statusKeputusan = int.tryParse(lastRecord['status_keputusan']?.toString() ?? '0') ?? 0;
          // Hanya dianggap selesai jika statusnya LANJUT dan indeks sudah di akhir
          return statusKeputusan == 1 && currentIndex >= totalMateri - 1;
        } else {
          // Non-floating: bandingkan internal_end dengan total cakupan (target pertemuan atau total baris)
          final int totalCakupan = modul.targetPertemuan > 0
              ? modul.targetPertemuan
              : (modul.totalBaris > 0 ? modul.totalBaris : 100);

          final int currentInternalEnd = int.tryParse(lastRecord['internal_end']?.toString() ?? '0') ?? 0;
          // Tambahkan pengecekan status LANJUT
          final int statusKeputusan = int.tryParse(lastRecord['status_keputusan']?.toString() ?? '0') ?? 0;
          return statusKeputusan == 1 && currentInternalEnd >= totalCakupan;
        }
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