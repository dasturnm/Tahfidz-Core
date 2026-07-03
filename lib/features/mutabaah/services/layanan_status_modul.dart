import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahfidz_core/features/akademik/kurikulum/models/modul_model.dart';

class LayananStatusModul {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengecek apakah konten materi di dalam modul sudah habis dipelajari secara fisik
  Future<bool> isContentCompleted(String siswaId, ModulModel modul) async {
    try {
      // Ambil setoran mutabaah terakhir milik siswa untuk modul ini
      final lastRecordResponse = await _supabase
          .from('mutabaah_records')
          .select()
          .eq('siswa_id', siswaId)
          .eq('modul_id', modul.id ?? '')
          .neq('status_keputusan', -1) // Kecualikan status "ULANG"
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (lastRecordResponse == null) return false;

      // Skenario A: Modul berbasis Al-Quran / Alur Mushaf (Koordinat Surah & Ayat)
      final String tipeModul = modul.tipe.trim().toUpperCase();
      if (tipeModul != 'INTERNAL' && tipeModul != 'AKADEMIK') {
        int targetSurah = modul.surahId;
        int targetAyat = modul.ayahEnd;

        final currentSurah = int.tryParse(lastRecordResponse['materi_silabus_aktif']?.toString().split(':').first ?? '0') ?? 0;
        final currentAyat = int.tryParse(lastRecordResponse['materi_silabus_aktif']?.toString().split(':').last ?? '0') ?? 0;

        // Evaluasi berbasis batas fisik ayat dan surah akhir (mushaf alur maju)
        if (currentSurah > targetSurah) {
          return true;
        } else if (currentSurah == targetSurah) {
          return currentAyat >= targetAyat;
        }
        return false;
      }

      // Skenario B: Modul berbasis Kitab / Materi CSV Internal / Silabus Floating (Murni bersandarkan internal_end)
      final int titikAkhirTarget = modul.totalBaris > 0
          ? modul.totalBaris
          : (modul.silabusContent.isNotEmpty ? modul.silabusContent.length : modul.materiSilabus.length);

      // Ambil nilai internal_end tertinggi dari record yang BERSTATUS LANJUT (status_keputusan == 1)
      final maxInternalEndResponse = await _supabase
          .from('mutabaah_records')
          .select('internal_end')
          .match({'siswa_id': siswaId, 'modul_id': modul.id ?? ''})
          .eq('status_keputusan', 1) // Kunci: Hanya hitung yang LANJUT, status ULANG otomatis terabaikan
          .order('internal_end', ascending: false)
          .limit(1)
          .maybeSingle();

      if (maxInternalEndResponse == null || maxInternalEndResponse['internal_end'] == null) {
        return false;
      }

      final int maxCurrentEnd = int.tryParse(maxInternalEndResponse['internal_end'].toString()) ?? 0;

      // Modul dianggap tuntas konten jika titik internal_end tertinggi yang sah sudah mencapai atau melewati target materi
      return maxCurrentEnd >= titikAkhirTarget;
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

  /// Menentukan apakah modul benar-benar tuntas secara administratif dan boleh ditinggalkan
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