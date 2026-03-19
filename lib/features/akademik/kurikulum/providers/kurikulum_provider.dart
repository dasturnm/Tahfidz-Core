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
        String? programId, // Tambahan filter sesuai model baru
        String? tahunAjaranId, // Tambahan filter sesuai model baru
      }) async {
    try {
      // FIX: Validasi agar query tidak error jika ID kosong atau null string
      if (lembagaId.isEmpty || lembagaId == 'null') return [];

      debugPrint("DEBUG: Memuat Kurikulum (Search: $search, Status: $status)");

      var query = _supabase
          .from('kurikulum')
      // FIX: Melepaskan join 'kelas' karena relasi (Foreign Key) belum ada di DB (PGRST200)
      // MODIFIKASI: Hapus join target_metrik_kurikulum karena sudah menyatu di modul
          .select('*, jenjang:jenjang_kurikulum(*, level:kurikulum_level(*, modul:modul_kurikulum(*)))')
          .eq('lembaga_id', lembagaId);

      // PERBAIKAN POIN 3: Implementasi Pencarian & Filter di Sisi Database
      if (search.isNotEmpty) {
        query = query.ilike('nama_kurikulum', '%$search%');
      }

      if (status != 'Semua') {
        query = query.eq('status', status.toLowerCase());
      }

      // FIX: Gunakan pengecekan .isNotEmpty untuk keamanan filter tambahan
      if (programId != null && programId.isNotEmpty) {
        query = query.eq('program_id', programId);
      }

      if (tahunAjaranId != null && tahunAjaranId.isNotEmpty) {
        query = query.eq('tahun_ajaran_id', tahunAjaranId);
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
      final kurikulumData = kurikulum.toJson()..remove('jenjang');
      String kurikulumId;

      // 1. Upsert Kurikulum utama
      if (kurikulum.id == null) {
        // FIX: Pastikan ID null dihapus agar UUID auto-generate di DB
        final res = await _supabase.from('kurikulum').insert(kurikulumData..remove('id')).select().single();
        kurikulumId = res['id'];
      } else {
        await _supabase.from('kurikulum').update(kurikulumData).eq('id', kurikulum.id!);
        kurikulumId = kurikulum.id!;
      }

      // 2. Iterasi Jenjang
      for (var jenjang in kurikulum.jenjang) {
        final jenjangData = jenjang.toJson()
          ..remove('level')
          ..['kurikulum_id'] = kurikulumId;

        String jenjangId;
        if (jenjang.id == null) {
          // FIX: Pastikan ID null dihapus agar UUID auto-generate di DB
          final res = await _supabase.from('jenjang_kurikulum').insert(jenjangData..remove('id')).select().single();
          jenjangId = res['id'];
        } else {
          await _supabase.from('jenjang_kurikulum').update(jenjangData).eq('id', jenjang.id!);
          jenjangId = jenjang.id!;
        }

        // 3. Iterasi Level
        for (var level in jenjang.level) {
          final levelData = level.toJson()
            ..remove('modul')
            ..['jenjang_id'] = jenjangId
            ..['kurikulum_id'] = kurikulumId;

          String levelId;
          if (level.id == null) {
            // FIX: Pastikan ID null dihapus agar UUID auto-generate di DB
            final res = await _supabase.from('kurikulum_level').insert(levelData..remove('id')).select().single();
            levelId = res['id'];
          } else {
            await _supabase.from('kurikulum_level').update(levelData).eq('id', level.id!);
            levelId = level.id!;
          }

          // 4. Iterasi Modul (Sekarang mencakup data metrik langsung, tanpa looping target)
          for (var modul in level.modul) {
            final modulData = modul.toJson()
              ..['level_id'] = levelId;

            if (modul.id == null) {
              // FIX: Pastikan ID null dihapus agar UUID auto-generate di DB
              await _supabase.from('modul_kurikulum').insert(modulData..remove('id'));
            } else {
              await _supabase.from('modul_kurikulum').update(modulData).eq('id', modul.id!);
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
      // FIX: Proteksi ID null/kosong
      if (kurikulumId.isEmpty || kurikulumId == 'null') return [];

      debugPrint("DEBUG: Memuat Jenjang untuk kurikulumId: $kurikulumId"); // PERBAIKAN: Gunakan debugPrint
      final response = await _supabase
          .from('jenjang_kurikulum')
      // MODIFIKASI: Hapus join target_metrik_kurikulum
          .select('*, level:kurikulum_level(*, modul:modul_kurikulum(*))')
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
      final Map<String, dynamic> data = jenjang.toJson()..remove('level');
      if (jenjang.id == null) {
        await _supabase.from('jenjang_kurikulum').insert(data..remove('id'));
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
      // FIX: Proteksi ID null/kosong
      if (jenjangId.isEmpty || jenjangId == 'null') return [];

      // DEBUG LOG: Sangat penting untuk cek ID yang dikirim UI
      debugPrint("DEBUG: Memuat Level untuk jenjang_id: $jenjangId"); // PERBAIKAN: Gunakan debugPrint

      final response = await _supabase
          .from('kurikulum_level')
      // MODIFIKASI: Hapus join target_metrik_kurikulum
          .select('*, modul:modul_kurikulum(*)')
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
      await _supabase.from('kurikulum_level').insert(level.toJson()..remove('modul')..remove('id'));
      ref.invalidateSelf();
    } catch (e) {
      // SAFE CODE: Menangani error database
      debugPrint('Error addLevel: $e'); // PERBAIKAN: Gunakan debugPrint
    }
  }

  Future<void> saveLevel(LevelModel level) async {
    try {
      final Map<String, dynamic> data = level.toJson()..remove('modul');
      if (level.id == null) {
        await _supabase.from('kurikulum_level').insert(data..remove('id'));
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
      // FIX: Proteksi ID null/kosong
      if (levelId.isEmpty || levelId == 'null') return [];

      debugPrint("DEBUG: Memuat Modul untuk levelId: $levelId"); // PERBAIKAN: Gunakan debugPrint
      final response = await _supabase
          .from('modul_kurikulum')
          .select('*')
          .eq('level_id', levelId);

      return (response as List).map((e) => ModulModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error build ModulList: $e"); // PERBAIKAN: Gunakan debugPrint
      return [];
    }
  }

  Future<void> saveModul(ModulModel modul) async {
    try {
      final Map<String, dynamic> data = modul.toJson();
      if (modul.id == null) {
        await _supabase.from('modul_kurikulum').insert(data..remove('id'));
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

// PERBAIKAN: Menambahkan provider untuk fitur Penempatan Kelas (Mapping Level ke kelas)
@riverpod
class LevelKelasMapping extends _$LevelKelasMapping {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> build(String levelId) async {
    try {
      // FIX: Proteksi ID null/kosong
      if (levelId.isEmpty || levelId == 'null') return [];

      // PERBAIKAN: Menggunakan tabel 'kelas' sesuai Schema v2 dan join profiles
      final response = await _supabase
          .from('kelas')
          .select('id, name, guru:profiles(nama_lengkap)')
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
          .from('kelas')
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
          .from('kelas')
          .update({'level_id': null})
          .eq('id', kelasId);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error unlinkKelas: $e");
    }
  }
}