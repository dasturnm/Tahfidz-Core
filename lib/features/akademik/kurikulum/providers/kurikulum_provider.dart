import 'package:flutter/foundation.dart'; // PERBAIKAN: Import yang dibutuhkan untuk debugPrint
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kurikulum_model.dart';

part 'kurikulum_provider.g.dart';

@riverpod
class KurikulumList extends _$KurikulumList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<KurikulumModel>> build(
      String lembagaId, {
        String search = '',
        String status = 'Semua',
      }) async {
    try {
      debugPrint("DEBUG: Memuat Kurikulum (Search: $search, Status: $status)");

      var query = _supabase
          .from('kurikulum')
      // PERBAIKAN POIN 3: Deep Select hingga ke level modul & target untuk statistik
          .select('*, jenjangs:jenjang_kurikulum(*, levels:kurikulum_level(*, modules:modul_kurikulum(*, targets:target_metrik_kurikulum(*)), classes(id, name)))')
          .eq('lembaga_id', lembagaId);

      // PERBAIKAN POIN 3: Implementasi Pencarian & Filter di Sisi Database
      if (search.isNotEmpty) {
        query = query.ilike('nama_kurikulum', '%$search%');
      }

      if (status != 'Semua') {
        query = query.eq('status', status.toLowerCase());
      }

      final response = await query.order('nama_kurikulum');

      return (response as List).map((e) => KurikulumModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error build KurikulumList: $e");
      return [];
    }
  }

  Future<void> addKurikulum(KurikulumModel kurikulum) async {
    // Diarahkan ke saveKurikulum untuk mendukung penyimpanan hierarki penuh
    await saveKurikulum(kurikulum);
  }

  Future<void> saveKurikulum(KurikulumModel kurikulum) async {
    try {
      final kurikulumData = kurikulum.toJson()..remove('jenjangs');
      String kurikulumId;

      // 1. Upsert Kurikulum utama
      if (kurikulum.id == null) {
        final res = await _supabase.from('kurikulum').insert(kurikulumData).select().single();
        kurikulumId = res['id'];
      } else {
        await _supabase.from('kurikulum').update(kurikulumData).eq('id', kurikulum.id!);
        kurikulumId = kurikulum.id!;
      }

      // 2. Iterasi Jenjang
      for (var jenjang in kurikulum.jenjangs) {
        final jenjangData = jenjang.toJson()
          ..remove('levels')
          ..['kurikulum_id'] = kurikulumId;

        String jenjangId;
        if (jenjang.id == null) {
          final res = await _supabase.from('jenjang_kurikulum').insert(jenjangData).select().single();
          jenjangId = res['id'];
        } else {
          await _supabase.from('jenjang_kurikulum').update(jenjangData).eq('id', jenjang.id!);
          jenjangId = jenjang.id!;
        }

        // 3. Iterasi Level
        for (var level in jenjang.levels) {
          final levelData = level.toJson()
            ..remove('modules')
            ..['jenjang_id'] = jenjangId
            ..['kurikulum_id'] = kurikulumId;

          String levelId;
          if (level.id == null) {
            final res = await _supabase.from('kurikulum_level').insert(levelData).select().single();
            levelId = res['id'];
          } else {
            await _supabase.from('kurikulum_level').update(levelData).eq('id', level.id!);
            levelId = level.id!;
          }

          // 4. Iterasi Modul
          for (var modul in level.modules) {
            final modulData = modul.toJson()
              ..remove('targets')
              ..['level_id'] = levelId;

            String modulId;
            if (modul.id == null) {
              final res = await _supabase.from('modul_kurikulum').insert(modulData).select().single();
              modulId = res['id'];
            } else {
              await _supabase.from('modul_kurikulum').update(modulData).eq('id', modul.id!);
              modulId = modul.id!;
            }

            // 5. Iterasi Target Metrik
            for (var target in modul.targets) {
              // PERBAIKAN: Membersihkan field tambahan agar tidak error saat simpan ke DB standar
              final targetData = target.toJson()
                ..['modul_id'] = modulId
                ..remove('input_type')
                ..remove('options')
                ..remove('is_primary')
                ..remove('has_target')
                ..remove('weight');

              if (target.id == null) {
                await _supabase.from('target_metrik_kurikulum').insert(targetData);
              } else {
                await _supabase.from('target_metrik_kurikulum').update(targetData).eq('id', target.id!);
              }
            }
          }
        }
      }

      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error saveKurikulum (Deep Upsert): $e"); // PERBAIKAN: Gunakan debugPrint
    }
  }

  Future<void> deleteKurikulum(String id) async {
    try {
      await _supabase.from('kurikulum').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error deleteKurikulum: $e"); // PERBAIKAN: Gunakan debugPrint
    }
  }
}

@riverpod
class JenjangList extends _$JenjangList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<JenjangModel>> build(String kurikulumId) async {
    try {
      debugPrint("DEBUG: Memuat Jenjang untuk kurikulumId: $kurikulumId"); // PERBAIKAN: Gunakan debugPrint
      final response = await _supabase
          .from('jenjang_kurikulum')
      // PERBAIKAN: Deep select hingga modul & target
          .select('*, levels:kurikulum_level(*, modules:modul_kurikulum(*, targets:target_metrik_kurikulum(*)), classes(id, name))')
          .eq('kurikulum_id', kurikulumId)
          .order('id');

      return (response as List).map((e) => JenjangModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error build JenjangList: $e"); // PERBAIKAN: Gunakan debugPrint
      return [];
    }
  }

  Future<void> saveJenjang(JenjangModel jenjang) async {
    try {
      final Map<String, dynamic> data = jenjang.toJson()..remove('levels');
      if (jenjang.id == null) {
        await _supabase.from('jenjang_kurikulum').insert(data);
      } else {
        await _supabase.from('jenjang_kurikulum').update(data).eq('id', jenjang.id!);
      }
      ref.invalidateSelf();
    } catch (e) {
      // SAFE CODE: Menangani error database (seperti FK constraint kurikulum_id)
      debugPrint('Error saveJenjang: $e'); // PERBAIKAN: Gunakan debugPrint
    }
  }

  Future<void> deleteJenjang(String id) async {
    try {
      await _supabase.from('jenjang_kurikulum').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error deleteJenjang: $e"); // PERBAIKAN: Gunakan debugPrint
    }
  }
}

@riverpod
class LevelList extends _$LevelList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<LevelModel>> build(String jenjangId) async {
    try {
      // DEBUG LOG: Sangat penting untuk cek ID yang dikirim UI
      debugPrint("DEBUG: Memuat Level untuk jenjang_id: $jenjangId"); // PERBAIKAN: Gunakan debugPrint

      final response = await _supabase
          .from('kurikulum_level')
      // PERBAIKAN: Deep select termasuk target di dalam modul
          .select('*, modules:modul_kurikulum(*, targets:target_metrik_kurikulum(*)), classes(id, name)')
          .eq('jenjang_id', jenjangId)
          .order('id', ascending: true);

      return (response as List).map((e) => LevelModel.fromJson(e)).toList();
    } catch (e) {
      // SAFE CODE: Menangani error database
      debugPrint("Error build LevelList: $e"); // PERBAIKAN: Gunakan debugPrint
      return [];
    }
  }

  Future<void> addLevel(LevelModel level) async {
    try {
      await _supabase.from('kurikulum_level').insert(level.toJson()..remove('modules'));
      ref.invalidateSelf();
    } catch (e) {
      // SAFE CODE: Menangani error database
      debugPrint('Error addLevel: $e'); // PERBAIKAN: Gunakan debugPrint
    }
  }

  Future<void> saveLevel(LevelModel level) async {
    try {
      final Map<String, dynamic> data = level.toJson()..remove('modules');
      if (level.id == null) {
        await _supabase.from('kurikulum_level').insert(data);
      } else {
        await _supabase.from('kurikulum_level').update(data).eq('id', level.id!);
      }
      ref.invalidateSelf();
    } catch (e) {
      // SAFE CODE: Menangani error database
      debugPrint('Error saveLevel: $e'); // PERBAIKAN: Gunakan debugPrint
    }
  }

  Future<void> deleteLevel(String id) async {
    try {
      await _supabase.from('kurikulum_level').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error deleteLevel: $e"); // PERBAIKAN: Gunakan debugPrint
    }
  }
}

@riverpod
class ModulList extends _$ModulList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<ModulModel>> build(String levelId) async {
    try {
      debugPrint("DEBUG: Memuat Modul untuk levelId: $levelId"); // PERBAIKAN: Gunakan debugPrint
      final response = await _supabase
          .from('modul_kurikulum')
          .select('*, targets:target_metrik_kurikulum(*)') // PERBAIKAN: Deep select target
          .eq('level_id', levelId);

      return (response as List).map((e) => ModulModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error build ModulList: $e"); // PERBAIKAN: Gunakan debugPrint
      return [];
    }
  }

  Future<void> saveModul(ModulModel modul) async {
    try {
      final Map<String, dynamic> data = modul.toJson()..remove('targets');
      if (modul.id == null) {
        await _supabase.from('modul_kurikulum').insert(data);
      } else {
        await _supabase.from('modul_kurikulum').update(data).eq('id', modul.id!);
      }
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error saveModul: $e"); // PERBAIKAN: Gunakan debugPrint
    }
  }

  Future<void> deleteModul(String id) async {
    try {
      await _supabase.from('modul_kurikulum').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error deleteModul: $e"); // PERBAIKAN: Gunakan debugPrint
    }
  }
}

@riverpod
class TargetMetrikList extends _$TargetMetrikList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<TargetMetrikModel>> build(String modulId) async {
    try {
      debugPrint("DEBUG: Memuat Target untuk modulId: $modulId"); // PERBAIKAN: Gunakan debugPrint
      final response = await _supabase
          .from('target_metrik_kurikulum')
          .select()
          .eq('modul_id', modulId);

      return (response as List).map((e) => TargetMetrikModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error build TargetMetrikList: $e"); // PERBAIKAN: Gunakan debugPrint
      return [];
    }
  }

  Future<void> saveTarget(TargetMetrikModel target) async {
    try {
      // PERBAIKAN: Pembersihan data field tambahan sebelum simpan (Insert/Update)
      final Map<String, dynamic> data = target.toJson()
        ..remove('input_type')
        ..remove('options')
        ..remove('is_primary')
        ..remove('has_target')
        ..remove('weight');

      if (target.id == null) {
        await _supabase.from('target_metrik_kurikulum').insert(data);
      } else {
        await _supabase.from('target_metrik_kurikulum').update(data).eq('id', target.id!);
      }
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error saveTarget: $e"); // PERBAIKAN: Gunakan debugPrint
    }
  }

  Future<void> deleteTarget(String id) async {
    try {
      await _supabase.from('target_metrik_kurikulum').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error deleteTarget: $e"); // PERBAIKAN: Gunakan debugPrint
    }
  }
}

// PERBAIKAN: Menambahkan provider untuk fitur Penempatan Kelas (Mapping Level ke classes)
@riverpod
class LevelKelasMapping extends _$LevelKelasMapping {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> build(String levelId) async {
    try {
      // PERBAIKAN: Join ke tabel profiles untuk mendapatkan nama lengkap muallim
      final response = await _supabase
          .from('classes')
          .select('id, name, muallim:profiles(nama_lengkap)')
          .eq('level_id', levelId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error build LevelKelasMapping: $e");
      return [];
    }
  }

  Future<void> linkKelas(String kelasId, String levelId) async {
    try {
      await _supabase
          .from('classes')
          .update({'level_id': levelId})
          .eq('id', kelasId);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error linkKelas: $e");
    }
  }

  Future<void> unlinkKelas(String kelasId) async {
    try {
      await _supabase
          .from('classes')
          .update({'level_id': null})
          .eq('id', kelasId);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error unlinkKelas: $e");
    }
  }
}