// Lokasi: lib/features/akademik/kurikulum/services/kurikulum_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahfidz_core/core/services/base_service.dart';
import 'package:tahfidz_core/features/akademik/kurikulum/models/kurikulum_model.dart';
// FIX: Import model pendukung dihapus karena semua model (Jenjang, Level, Modul)
// sudah disatukan di dalam kurikulum_model.dart

class KurikulumService extends BaseService {
  /// 🔍 FETCH KURIKULUM
  Future<List<KurikulumModel>> fetchKurikulum({
    required String lembagaId,
    String search = '',
    String status = 'Semua',
    String? programId,
    String? tahunAjaranId,
  }) async {
    try {
      // Menggunakan instance 'supabase' dari BaseService
      PostgrestFilterBuilder query = supabase
          .from('kurikulum')
          .select('*, jenjang:jenjang_kurikulum(*, level:kurikulum_level(*, modul:modul_kurikulum(*)))');

      // Filter Lembaga via Helper BaseService
      // FIX: Casting eksplisit ke PostgrestList untuk menghindari error invalid_assignment
      query = applyLembagaFilter(query: query, lembagaId: lembagaId) as PostgrestFilterBuilder<PostgrestList>;

      if (search.isNotEmpty) {
        query = query.ilike('nama_kurikulum', '%$search%');
      }

      if (status != 'Semua') {
        query = query.eq('status', status.toLowerCase());
      }

      if (programId != null && programId.isNotEmpty) {
        query = query.eq('program_id', programId);
      }

      if (tahunAjaranId != null && tahunAjaranId.isNotEmpty) {
        query = query.eq('tahun_ajaran_id', tahunAjaranId);
      }

      final response = await query.order('nama_kurikulum');
      return (response as List).map((e) => KurikulumModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 💾 SAVE KURIKULUM (Deep Upsert)
  Future<void> saveKurikulum(KurikulumModel kurikulum) async {
    try {
      // FIX: Menggunakan cleanData() untuk proteksi input
      final kurikulumData = cleanData(kurikulum.toJson())..remove('jenjang');
      String kurikulumId;

      if (kurikulum.id == null) {
        final res = await supabase.from('kurikulum').insert(kurikulumData..remove('id')).select().single();
        kurikulumId = res['id'];
      } else {
        await supabase.from('kurikulum').update(kurikulumData).eq('id', kurikulum.id!);
        kurikulumId = kurikulum.id!;
      }

      for (var jenjang in kurikulum.jenjang) {
        // FIX: Menggunakan cleanData()
        final jenjangData = cleanData(jenjang.toJson())
          ..remove('level')
          ..['kurikulum_id'] = kurikulumId;

        String jenjangId;
        if (jenjang.id == null) {
          final res = await supabase.from('jenjang_kurikulum').insert(jenjangData..remove('id')).select().single();
          jenjangId = res['id'];
        } else {
          await supabase.from('jenjang_kurikulum').update(jenjangData).eq('id', jenjang.id!);
          jenjangId = jenjang.id!;
        }

        for (var level in jenjang.level) {
          // FIX: Menggunakan cleanData()
          final levelData = cleanData(level.toJson())
            ..remove('modul')
            ..['jenjang_id'] = jenjangId
            ..['kurikulum_id'] = kurikulumId;

          String levelId;
          if (level.id == null) {
            final res = await supabase.from('kurikulum_level').insert(levelData..remove('id')).select().single();
            levelId = res['id'];
          } else {
            await supabase.from('kurikulum_level').update(levelData).eq('id', level.id!);
            levelId = level.id!;
          }

          for (var modul in level.modul) {
            // FIX: Menggunakan cleanData()
            final modulData = cleanData(modul.toJson())..['level_id'] = levelId;
            if (modul.id == null) {
              await supabase.from('modul_kurikulum').insert(modulData..remove('id'));
            } else {
              await supabase.from('modul_kurikulum').update(modulData).eq('id', modul.id!);
            }
          }
        }
      }
    } catch (e) {
      throw Exception(handleError(e));
    }
  }

  /// 🗑️ DELETE KURIKULUM
  Future<void> deleteKurikulum(String id) async {
    try {
      await supabase.from('kurikulum').delete().eq('id', id);
    } catch (e) {
      throw Exception(handleError(e));
    }
  }
}