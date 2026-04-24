// Lokasi: lib/features/akademik/kurikulum/services/modul_service.dart

import 'package:tahfidz_core/core/services/base_service.dart';
// Menggunakan kurikulum_model.dart karena class ModulModel ada di sana
import 'package:tahfidz_core/features/akademik/kurikulum/models/kurikulum_model.dart';

class ModulService extends BaseService {
  // --- MODUL ---
  Future<List<ModulModel>> fetchModul(String levelId) async {
    try {
      final response = await supabase
          .from('modul_kurikulum')
          .select('*')
          .eq('level_id', levelId);
      return (response as List).map((e) => ModulModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  Future<void> saveModul(ModulModel modul) async {
    try {
      final data = cleanData(modul.toJson());
      // Perbaikan: Menangani ID null atau string kosong ("") agar benar-benar menjalankan INSERT
      if (modul.id == null || modul.id!.isEmpty) {
        await supabase.from('modul_kurikulum').insert(data..remove('id'));
      } else {
        await supabase.from('modul_kurikulum').update(data).eq('id', modul.id!);
      }
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  Future<void> deleteModul(String id) async {
    try {
      await supabase.from('modul_kurikulum').delete().eq('id', id);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}