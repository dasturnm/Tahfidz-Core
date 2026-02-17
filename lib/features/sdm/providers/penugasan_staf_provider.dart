import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/penugasan_staf_model.dart';

part 'penugasan_staf_provider.g.dart';

@riverpod
class PenugasanStafList extends _$PenugasanStafList {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<PenugasanStafModel>> build(String lembagaId) async {
    return _fetchPenugasan(lembagaId);
  }

  Future<List<PenugasanStafModel>> _fetchPenugasan(String lembagaId) async {
    // JOIN data dari tabel profiles, jabatan, dan cabang sekaligus
    final response = await _supabase
        .from('penugasan_staf')
        .select('''
          *,
          profiles:profile_id(nama_lengkap, email),
          jabatan:jabatan_id(nama_jabatan),
          cabang:cabang_id(nama_cabang)
        ''')
        .eq('lembaga_id', lembagaId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => PenugasanStafModel.fromJson(json))
        .toList();
  }

  Future<void> savePenugasan(PenugasanStafModel penugasan) async {
    try {
      if (penugasan.id.isEmpty) {
        // Insert Baru
        await _supabase.from('penugasan_staf').insert(penugasan.toJson());
      } else {
        // Update
        await _supabase
            .from('penugasan_staf')
            .update(penugasan.toJson())
            .eq('id', penugasan.id);
      }

      // Refresh state agar UI otomatis update
      state = const AsyncValue.loading();
      state = AsyncValue.data(await _fetchPenugasan(lembagaId));
    } catch (e) {
      throw Exception("Gagal menyimpan penugasan: $e");
    }
  }

  Future<void> hapusPenugasan(String id) async {
    try {
      await _supabase.from('penugasan_staf').delete().eq('id', id);
      state = const AsyncValue.loading();
      state = AsyncValue.data(await _fetchPenugasan(lembagaId));
    } catch (e) {
      throw Exception("Gagal menghapus penugasan: $e");
    }
  }
}