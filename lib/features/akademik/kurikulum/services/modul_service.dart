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
          .select('*, modul_evaluasi_template(*)')
          .eq('level_id', levelId)
          .order('urutan', ascending: true); // FIX: Diurutkan berdasarkan kolom urutan
      return (response as List).map((e) => ModulModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  Future<void> saveModul(ModulModel modul) async {
    try {
      // FIX: Jangan gunakan cleanData() yang agresif menghapus string kosong "".
      // Kita hapus secara manual hanya key yang nilainya benar-benar null.
      final data = modul.toJson();
      data.removeWhere((key, value) => value == null);

      data.remove('modul_evaluasi_template');
      data.remove('lembaga_id'); // FIX: Hapus field lembaga_id dari tabel modul_kurikulum

      // FIX: Ambil lembaga_id dari profile agar template evaluasi bisa menembus RLS
      String? activeLembagaId;
      final user = supabase.auth.currentUser;
      if (user != null) {
        final profileRes = await supabase
            .from('profiles')
            .select('lembaga_id')
            .eq('id', user.id)
            .maybeSingle();
        if (profileRes != null && profileRes['lembaga_id'] != null) {
          activeLembagaId = profileRes['lembaga_id'].toString();
        }
      }

      String modulId;
      // Perbaikan: Menangani ID null atau string kosong ("") agar benar-benar menjalankan INSERT
      if (modul.id == null || modul.id!.isEmpty) {
        final res = await supabase.from('modul_kurikulum').insert(data..remove('id')).select().single();
        modulId = res['id'];
      } else {
        await supabase.from('modul_kurikulum').update(data).eq('id', modul.id!);
        modulId = modul.id!;
      }

      // SIMPAN: Template Evaluasi Silabus Internal (TAMBAHAN)
      for (var template in modul.evaluasiTemplates) {
        final tData = template.toJson()..['modul_id'] = modulId;
        if (activeLembagaId != null) {
          tData['lembaga_id'] = activeLembagaId;
        }
        tData.removeWhere((key, value) => value == null);
        if (template.id == null || template.id!.isEmpty) {
          await supabase.from('modul_evaluasi_template').insert(tData..remove('id'));
        } else {
          await supabase.from('modul_evaluasi_template').update(tData).eq('id', template.id!);
        }
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