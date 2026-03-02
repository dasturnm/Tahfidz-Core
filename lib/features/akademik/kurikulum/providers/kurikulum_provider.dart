import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kurikulum_model.dart';

part 'kurikulum_provider.g.dart';

@riverpod
class KurikulumList extends _$KurikulumList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<KurikulumModel>> build(String programId) async {
    try {
      print("DEBUG: Memuat Kurikulum untuk programId: $programId");
      final response = await _supabase
          .from('kurikulum')
          .select()
          .eq('program_id', programId)
          .order('nama_kurikulum');

      return (response as List).map((e) => KurikulumModel.fromJson(e)).toList();
    } catch (e) {
      print("Error build KurikulumList: $e");
      return [];
    }
  }

  Future<void> addKurikulum(KurikulumModel kurikulum) async {
    try {
      await _supabase.from('kurikulum').insert(kurikulum.toJson()..remove('jenjangs'));
      ref.invalidateSelf();
    } catch (e) {
      print("Error addKurikulum: $e");
    }
  }

  Future<void> saveKurikulum(KurikulumModel kurikulum) async {
    try {
      final Map<String, dynamic> data = kurikulum.toJson()..remove('jenjangs');
      if (kurikulum.id == null) {
        await _supabase.from('kurikulum').insert(data);
      } else {
        await _supabase.from('kurikulum').update(data).eq('id', kurikulum.id!);
      }
      ref.invalidateSelf();
    } catch (e) {
      print("Error saveKurikulum: $e");
    }
  }

  Future<void> deleteKurikulum(String id) async {
    try {
      await _supabase.from('kurikulum').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print("Error deleteKurikulum: $e");
    }
  }
}

@riverpod
class JenjangList extends _$JenjangList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<JenjangModel>> build(String kurikulumId) async {
    try {
      print("DEBUG: Memuat Jenjang untuk kurikulumId: $kurikulumId");
      final response = await _supabase
          .from('jenjang_kurikulum')
          .select()
          .eq('kurikulum_id', kurikulumId)
          .order('id');

      return (response as List).map((e) => JenjangModel.fromJson(e)).toList();
    } catch (e) {
      print("Error build JenjangList: $e");
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
      print('Error saveJenjang: $e');
    }
  }

  Future<void> deleteJenjang(String id) async {
    try {
      await _supabase.from('jenjang_kurikulum').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print("Error deleteJenjang: $e");
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
      print("DEBUG: Memuat Level untuk jenjang_id: $jenjangId");

      final response = await _supabase
          .from('kurikulum_level')
          .select()
          .eq('jenjang_id', jenjangId)
          .order('id', ascending: true);

      return (response as List).map((e) => LevelModel.fromJson(e)).toList();
    } catch (e) {
      // SAFE CODE: Menangani error database
      print("Error build LevelList: $e");
      return [];
    }
  }

  Future<void> addLevel(LevelModel level) async {
    try {
      await _supabase.from('kurikulum_level').insert(level.toJson()..remove('modules'));
      ref.invalidateSelf();
    } catch (e) {
      // SAFE CODE: Menangani error database
      print('Error addLevel: $e');
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
      print('Error saveLevel: $e');
    }
  }

  Future<void> deleteLevel(String id) async {
    try {
      await _supabase.from('kurikulum_level').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print("Error deleteLevel: $e");
    }
  }
}

@riverpod
class ModulList extends _$ModulList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<ModulModel>> build(String levelId) async {
    try {
      print("DEBUG: Memuat Modul untuk levelId: $levelId");
      final response = await _supabase
          .from('modul_kurikulum')
          .select()
          .eq('level_id', levelId);

      return (response as List).map((e) => ModulModel.fromJson(e)).toList();
    } catch (e) {
      print("Error build ModulList: $e");
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
      print("Error saveModul: $e");
    }
  }

  Future<void> deleteModul(String id) async {
    try {
      await _supabase.from('modul_kurikulum').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print("Error deleteModul: $e");
    }
  }
}

@riverpod
class TargetMetrikList extends _$TargetMetrikList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<TargetMetrikModel>> build(String modulId) async {
    try {
      print("DEBUG: Memuat Target untuk modulId: $modulId");
      final response = await _supabase
          .from('target_metrik_kurikulum')
          .select()
          .eq('modul_id', modulId);

      return (response as List).map((e) => TargetMetrikModel.fromJson(e)).toList();
    } catch (e) {
      print("Error build TargetMetrikList: $e");
      return [];
    }
  }

  Future<void> saveTarget(TargetMetrikModel target) async {
    try {
      final Map<String, dynamic> data = target.toJson();
      if (target.id == null) {
        await _supabase.from('target_metrik_kurikulum').insert(data);
      } else {
        await _supabase.from('target_metrik_kurikulum').update(data).eq('id', target.id!);
      }
      ref.invalidateSelf();
    } catch (e) {
      print("Error saveTarget: $e");
    }
  }

  Future<void> deleteTarget(String id) async {
    try {
      await _supabase.from('target_metrik_kurikulum').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print("Error deleteTarget: $e");
    }
  }
}