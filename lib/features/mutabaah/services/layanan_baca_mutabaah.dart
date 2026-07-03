// Lokasi: lib/features/mutabaah/services/layanan_baca_mutabaah.dart
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
          .select('level_id, is_ready_for_exam, ready_modul_id')
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

      final allModulsResponse = await supabase
          .from('modul_kurikulum')
          .select('*, level:level_id(kurikulum_id, urutan)')
          .eq('level_id', levelId)
          .order('urutan', ascending: true);

      List<ModulModel> allModuls = (allModulsResponse as List)
          .map((m) => ModulModel.fromJson(m))
          .toList();

      debugPrint("DEBUG [Audit]: Ditemukan ${allModuls.length} modul di Level $levelId");
      for (var m in allModuls) {
        debugPrint(" -> Modul: ${m.namaModul} | Tipe: ${m.tipe} | ID: ${m.id}");
      }

      List<ModulModel> dailyModuls = allModuls.where((m) => m.tipe.trim().toUpperCase() != 'TASMI\'').toList();

      List<ModulModel> unpassedModuls = dailyModuls.isEmpty ? allModuls : dailyModuls;
      debugPrint("DEBUG [Audit]: Modul aktif sebelum filter kelulusan: ${unpassedModuls.length}");

      final bool isReadyForExam = siswaData['is_ready_for_exam'] == true;
      final String? readyModulId = siswaData['ready_modul_id']?.toString();

      if (isReadyForExam && readyModulId != null) {
        final readyModul = unpassedModuls.where((m) => m.id == readyModulId).toList();
        if (readyModul.isNotEmpty) return readyModul;
      }

      final Set<String> passedIds = {};

      for (var modul in unpassedModuls) {
        if (modul.isExamRequired) {
          final evaluasiLulus = await supabase
              .from('siswa_evaluasi_nilai')
              .select('id')
              .match({'siswa_id': siswaId, 'modul_id': modul.id!, 'is_lulus': true})
              .limit(1)
              .maybeSingle();

          if (evaluasiLulus != null) {
            passedIds.add(modul.id!);
          }
        } else {
          final projection = await _mainService._kecerdasanAkademik.getModuleProjection(siswaId, modul);
          if (projection.isCompleted) {
            passedIds.add(modul.id!);
          }
        }
      }

      unpassedModuls = unpassedModuls.where((m) => !passedIds.contains(m.id)).toList();

      if (unpassedModuls.isEmpty) return [];

      if (policy == 'flexible') {
        return unpassedModuls;
      } else {
        int currentActiveUrutan = unpassedModuls.first.urutan;
        return unpassedModuls.where((m) => m.urutan == currentActiveUrutan).toList();
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