import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kurikulum_model.dart';

part 'kurikulum_provider.g.dart';

@riverpod
class KurikulumList extends _$KurikulumList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<KurikulumModel>> build(String programId) async {
    final response = await _supabase
        .from('kurikulum')
        .select()
        .eq('program_id', programId)
        .order('nama_kurikulum');

    return (response as List).map((e) => KurikulumModel.fromJson(e)).toList();
  }

  Future<void> addKurikulum(KurikulumModel kurikulum) async {
    await _supabase.from('kurikulum').insert(kurikulum.toJson());
    ref.invalidateSelf();
  }

  Future<void> saveKurikulum(KurikulumModel kurikulum) async {
    final Map<String, dynamic> data = kurikulum.toJson();
    if (kurikulum.id == null) {
      await _supabase.from('kurikulum').insert(data);
    } else {
      await _supabase.from('kurikulum').update(data).eq('id', kurikulum.id!);
    }
    ref.invalidateSelf();
  }

  Future<void> deleteKurikulum(String id) async {
    await _supabase.from('kurikulum').delete().eq('id', id);
    ref.invalidateSelf();
  }
}

@riverpod
class JenjangList extends _$JenjangList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<JenjangModel>> build(String kurikulumId) async {
    final response = await _supabase
        .from('jenjang_kurikulum')
        .select()
        .eq('kurikulum_id', kurikulumId)
        .order('id');

    return (response as List).map((e) => JenjangModel.fromJson(e)).toList();
  }

  Future<void> saveJenjang(JenjangModel jenjang) async {
    final Map<String, dynamic> data = jenjang.toJson();
    if (jenjang.id == null) {
      await _supabase.from('jenjang_kurikulum').insert(data);
    } else {
      await _supabase.from('jenjang_kurikulum').update(data).eq('id', jenjang.id!);
    }
    ref.invalidateSelf();
  }

  Future<void> deleteJenjang(String id) async {
    await _supabase.from('jenjang_kurikulum').delete().eq('id', id);
    ref.invalidateSelf();
  }
}

@riverpod
class LevelList extends _$LevelList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<LevelModel>> build(String jenjangId) async {
    final response = await _supabase
        .from('level_kurikulum')
        .select()
        .eq('jenjang_id', jenjangId)
        .order('urutan', ascending: true);

    return (response as List).map((e) => LevelModel.fromJson(e)).toList();
  }

  Future<void> addLevel(LevelModel level) async {
    await _supabase.from('level_kurikulum').insert(level.toJson());
    ref.invalidateSelf();
  }

  Future<void> saveLevel(LevelModel level) async {
    final Map<String, dynamic> data = level.toJson();
    if (level.id == null) {
      await _supabase.from('level_kurikulum').insert(data);
    } else {
      await _supabase.from('level_kurikulum').update(data).eq('id', level.id!);
    }
    ref.invalidateSelf();
  }

  Future<void> deleteLevel(String id) async {
    await _supabase.from('level_kurikulum').delete().eq('id', id);
    ref.invalidateSelf();
  }
}

@riverpod
class ModulList extends _$ModulList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<ModulModel>> build(String levelId) async {
    final response = await _supabase
        .from('modul_kurikulum')
        .select()
        .eq('level_id', levelId);

    return (response as List).map((e) => ModulModel.fromJson(e)).toList();
  }

  Future<void> saveModul(ModulModel modul) async {
    final Map<String, dynamic> data = modul.toJson();
    if (modul.id == null) {
      await _supabase.from('modul_kurikulum').insert(data);
    } else {
      await _supabase.from('modul_kurikulum').update(data).eq('id', modul.id!);
    }
    ref.invalidateSelf();
  }

  Future<void> deleteModul(String id) async {
    await _supabase.from('modul_kurikulum').delete().eq('id', id);
    ref.invalidateSelf();
  }
}

@riverpod
class TargetMetrikList extends _$TargetMetrikList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<TargetMetrikModel>> build(String modulId) async {
    final response = await _supabase
        .from('target_metrik_kurikulum')
        .select()
        .eq('modul_id', modulId);

    return (response as List).map((e) => TargetMetrikModel.fromJson(e)).toList();
  }

  Future<void> saveTarget(TargetMetrikModel target) async {
    final Map<String, dynamic> data = target.toJson();
    if (target.id == null) {
      await _supabase.from('target_metrik_kurikulum').insert(data);
    } else {
      await _supabase.from('target_metrik_kurikulum').update(data).eq('id', target.id!);
    }
    ref.invalidateSelf();
  }

  Future<void> deleteTarget(String id) async {
    await _supabase.from('target_metrik_kurikulum').delete().eq('id', id);
    ref.invalidateSelf();
  }
}