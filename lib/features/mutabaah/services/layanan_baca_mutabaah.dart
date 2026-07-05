part of 'mutabaah_service.dart';

class LayananBacaMutabaah {
  final MutabaahTahfidzService _mainService;
  LayananBacaMutabaah(this._mainService);

  SupabaseClient get supabase => _mainService.supabase;

  Future<List<MutabaahRecord>> getHistory(String siswaId) async {
    try {
      PostgrestFilterBuilder query = supabase
          .from('mutabaah_records')
          .select('*, modul:modul_kurikulum(nama_modul)');

      final response = await (query as PostgrestFilterBuilder<PostgrestList>)
          .eq('siswa_id', siswaId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => MutabaahRecord.fromJson(json)).toList();
    } catch (e) {
      throw Exception(_mainService.handleError(e));
    }
  }

  Future<List<MutabaahRecord>> getAllHistory() async {
    try {
      PostgrestFilterBuilder query = supabase
          .from('mutabaah_records')
          .select('*, modul:modul_kurikulum(nama_modul)');

      final response = await (query as PostgrestFilterBuilder<PostgrestList>)
          .order('created_at', ascending: false);

      return (response as List).map((json) => MutabaahRecord.fromJson(json)).toList();
    } catch (e) {
      throw Exception(_mainService.handleError(e));
    }
  }

  Future<List<MutabaahRecord>> getHistoryByLembaga(Ref ref) async {
    try {
      final profile = ref.read(appContextProvider).profile;
      if (profile == null) return [];

      final response = await supabase
          .from('mutabaah_records')
          .select('*, modul:modul_kurikulum(nama_modul), siswa!inner(lembaga_id)')
          .eq('siswa.lembaga_id', profile.lembagaId ?? '')
          .order('created_at', ascending: false);

      return (response as List).map((json) => MutabaahRecord.fromJson(json)).toList();
    } catch (e) {
      throw Exception(_mainService.handleError(e));
    }
  }

  Future<DelegasiModel?> getActiveDelegation(String kelasId, String penerimaIzinId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await supabase
          .from('delegasi_tugas')
          .select()
          .match({
        'kelas_id': kelasId,
        'penerima_izin_id': penerimaIzinId,
        'is_active': true,
      })
          .gte('tanggal_izin', today)
          .order('tanggal_izin', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return DelegasiModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<ModulModel>> getActiveModuls(Ref ref, String siswaId) async {
    try {
      final siswaData = await supabase
          .from('siswa')
          .select('level_id')
          .eq('id', siswaId)
          .single();

      final levelId = siswaData['level_id'];
      if (levelId == null) {
        throw Exception("Siswa belum memiliki Level. Pastikan Level Kurikulum diisi pada profil siswa.");
      }

      final levelData = await supabase
          .from('kurikulum_level')
          .select('kurikulum_id')
          .eq('id', levelId)
          .single();

      final kurikulumId = levelData['kurikulum_id'];

      final kurikulumData = await supabase
          .from('kurikulum')
          .select('promotion_policy')
          .eq('id', kurikulumId)
          .maybeSingle();

      final String policy = kurikulumData?['promotion_policy'] ?? 'flexible';

      // Query modul yang belum 'Final Completed'
      // Modul yang materinya selesai (isContentCompleted) tapi belum lulus ujian (isExamPassed)
      // HARUS TETAP MUNCUL agar tidak terjadi layar kosong "Belum punya modul aktif"
      final allPossibleModuls = await supabase
          .from('modul_kurikulum')
          .select('*, level:level_id(*)')
          .eq('level_id', levelId)
          .order('urutan', ascending: true);

      List<ModulModel> activeList = [];
      for (var mJson in allPossibleModuls as List) {
        final m = ModulModel.fromJson(mJson);
        final isFinal = await LayananStatusModul().isFinalCompleted(siswaId, m);
        if (!isFinal) activeList.add(m);
      }

      if (activeList.isEmpty) return [];

      if (policy == 'flexible') {
        return activeList;
      } else {
        return [activeList.first];
      }
    } catch (e) {
      throw Exception(_mainService.handleError(e));
    }
  }

  Future<List<String>> getSiswaIdsSudahSetoranHariIni(DateTime tanggal) async {
    try {
      final startOfDay = DateTime(tanggal.year, tanggal.month, tanggal.day).toIso8601String();
      final endOfDay = DateTime(tanggal.year, tanggal.month, tanggal.day, 23, 59, 59, 999).toIso8601String();

      final response = await supabase
          .from('mutabaah_records')
          .select('siswa_id')
          .gte('created_at', startOfDay)
          .lte('created_at', endOfDay);

      return (response as List).map((e) => e['siswa_id'].toString()).toSet().toList();
    } catch (e) {
      throw Exception(_mainService.handleError(e));
    }
  }
}