import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kelas_model.dart';

part 'kelas_provider.g.dart';

@riverpod
class KelasNotifier extends _$KelasNotifier {
  final _supabase = Supabase.instance.client;

  @override
  FutureOr<List<KelasModel>> build() async {
    return _fetchClasses();
  }

  // Fungsi internal untuk ambil data dengan join guru (Wali Kelas)
  Future<List<KelasModel>> _fetchClasses() async {
    // Kita ambil data kelas sekaligus data gurunya (join)
    final response = await _supabase
        .from('classes')
        .select('*, gurus(*)'); // Pastikan nama tabel di Supabase adalah 'gurus'

    return (response as List)
        .map((json) => KelasModel.fromJson(json))
        .toList();
  }

  // Fungsi Tambah Kelas
  Future<void> addKelas(String name, String? level, String? teacherId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _supabase.from('classes').insert({
        'name': name,
        'level': level,
        'teacher_id': teacherId,
      });

      // Refresh data setelah berhasil insert
      return _fetchClasses();
    });
  }

  // Fungsi Hapus Kelas
  Future<void> deleteKelas(String id) async {
    state = await AsyncValue.guard(() async {
      await _supabase.from('classes').delete().eq('id', id);
      return _fetchClasses();
    });
  }
}