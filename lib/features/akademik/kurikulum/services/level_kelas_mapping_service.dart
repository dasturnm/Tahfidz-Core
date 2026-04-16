// Lokasi: lib/features/akademik/kurikulum/services/level_kelas_mapping_service.dart

import 'package:tahfidz_core/core/services/base_service.dart';

class LevelKelasMappingService extends BaseService {
  // --- MAPPING KELAS ---
  Future<List<Map<String, dynamic>>> fetchLevelKelasMapping(String levelId) async {
    try {
      final response = await supabase
          .from('kelas')
          .select('id, name, guru:profiles(nama_lengkap)')
          .eq('level_id', levelId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  Future<void> updateKelasLevel(String kelasId, String? levelId) async {
    try {
      await supabase.from('kelas').update({'level_id': levelId}).eq('id', kelasId);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}