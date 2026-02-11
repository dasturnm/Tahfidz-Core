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
}

@riverpod
class LevelList extends _$LevelList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<LevelModel>> build(String kurikulumId) async {
    final response = await _supabase
        .from('level_kurikulum')
        .select()
        .eq('kurikulum_id', kurikulumId)
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