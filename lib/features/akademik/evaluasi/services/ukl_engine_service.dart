// Lokasi: lib/features/akademik/evaluasi/services/ukl_engine_service.dart

import '../../../../core/services/base_service.dart';

class UklEngineService extends BaseService {

  /// 1. EVALUASI KELAYAKAN: Mengecek apakah siswa sudah menyelesaikan seluruh modul
  /// prasyarat di levelnya dan berhak mengikuti Ujian Kenaikan Level (UKL).
  Future<bool> checkUklEligibility(String siswaId) async {
    try {
      // Ambil level siswa saat ini
      final siswaData = await supabase.from('siswa').select('level_id').eq('id', siswaId).single();
      final currentLevelId = siswaData['level_id'];
      if (currentLevelId == null) return false;

      // Ambil seluruh modul di level tersebut
      final modulsInLevel = await supabase.from('modul_kurikulum').select('id').eq('level_id', currentLevelId);
      if (modulsInLevel.isEmpty) return false;

      final modulIds = (modulsInLevel as List).map((m) => m['id'].toString()).toList();

      // Cek kelulusan di mutabaah harian untuk modul-modul tersebut
      final passedRecords = await supabase
          .from('mutabaah_records')
          .select('modul_id')
          .match({'siswa_id': siswaId, 'is_passed_target': true});

      final passedModulIds = (passedRecords as List).map((m) => m['modul_id'].toString()).toSet();

      // Validasi apakah seluruh modul di level ini ada di dalam daftar modul yang sudah lulus
      bool isEligible = true;
      for (var id in modulIds) {
        if (!passedModulIds.contains(id)) {
          isEligible = false;
          break;
        }
      }

      return isEligible;
    } catch (e) {
      print("Error Check Eligibility: $e");
      return false; // Fail-safe
    }
  }

  /// 2. PROSES KENAIKAN LEVEL: Memindahkan siswa ke level berikutnya
  /// Akan dipanggil otomatis oleh EvaluasiService / Controller setelah UKL dinyatakan 'Lulus'.
  Future<void> processPromotion(String siswaId) async {
    try {
      // Ambil data level saat ini
      final siswaData = await supabase.from('siswa').select('level_id').eq('id', siswaId).single();
      final currentLevelId = siswaData['level_id'];
      if (currentLevelId == null) return;

      // Ambil kurikulum_id dan urutan saat ini
      final currentLevelData = await supabase
          .from('kurikulum_level')
          .select('kurikulum_id, urutan')
          .eq('id', currentLevelId)
          .single();

      final kurikulumId = currentLevelData['kurikulum_id'];
      final currentUrutan = currentLevelData['urutan'];

      // Cari level berikutnya (berdasarkan urutan yang lebih besar)
      final nextLevelData = await supabase
          .from('kurikulum_level')
          .select('id')
          .eq('kurikulum_id', kurikulumId)
          .gt('urutan', currentUrutan)
          .order('urutan', ascending: true)
          .limit(1)
          .maybeSingle();

      // Jika ada level berikutnya, lakukan update profil siswa
      if (nextLevelData != null) {
        final nextLevelId = nextLevelData['id'];

        await supabase.from('siswa').update({
          'level_id': nextLevelId,
          'current_level_id': nextLevelId, // Menyesuaikan dengan schema db
        }).eq('id', siswaId);
      }
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}