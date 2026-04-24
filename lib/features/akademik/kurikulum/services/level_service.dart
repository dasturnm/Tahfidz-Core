// Lokasi: lib/features/akademik/kurikulum/services/level_service.dart

import 'package:tahfidz_core/core/services/base_service.dart';
// Gunakan kurikulum_model.dart karena class LevelModel sekarang digabung di sana
import 'package:tahfidz_core/features/akademik/kurikulum/models/kurikulum_model.dart';

class LevelService extends BaseService {
  // --- LEVEL ---
  Future<List<LevelModel>> fetchLevel(String jenjangId) async {
    try {
      final response = await supabase
          .from('kurikulum_level')
          .select('*, modul:modul_kurikulum(*)')
          .eq('jenjang_id', jenjangId)
          .order('id', ascending: true);
      return (response as List).map((e) => LevelModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  Future<void> saveLevel(LevelModel level) async {
    try {
      final data = cleanData(level.toJson())..remove('modul');
      // Perbaikan: Menangani ID null atau string kosong ("") agar benar-benar menjalankan INSERT
      if (level.id == null || level.id!.isEmpty) {
        await supabase.from('kurikulum_level').insert(data..remove('id'));
      } else {
        await supabase.from('kurikulum_level').update(data).eq('id', level.id!);
      }
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  Future<void> deleteLevel(String id) async {
    try {
      await supabase.from('kurikulum_level').delete().eq('id', id);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}