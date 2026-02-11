import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../management_lembaga/providers/app_context_provider.dart';
import '../models/program_model.dart';

part 'program_provider.g.dart';

@riverpod
class ProgramNotifier extends _$ProgramNotifier {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<ProgramModel>> build() async {
    // Mengambil lembaga_id dari context global aplikasi
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;
    if (lembagaId == null) return [];

    return _fetchPrograms(lembagaId);
  }

  // --- FUNGSI AMBIL DATA ---
  Future<List<ProgramModel>> _fetchPrograms(String lembagaId) async {
    final response = await _supabase
        .from('program')
        .select()
        .eq('lembaga_id', lembagaId)
        .order('nama_program');

    return (response as List).map((e) => ProgramModel.fromJson(e)).toList();
  }

  // --- FUNGSI TAMBAH PROGRAM BARU ---
  Future<void> addProgram({
    required String nama,
    String? tag,
    String? deskripsi,
    double pendaftaran = 0,
    double spp = 0,
    List<String> hari = const [],
  }) async {
    state = const AsyncValue.loading();

    final lembagaId = ref.read(appContextProvider).lembaga?.id;
    if (lembagaId == null) return;

    state = await AsyncValue.guard(() async {
      await _supabase.from('program').insert({
        'lembaga_id': lembagaId,
        'nama_program': nama,
        'tag_kurikulum': tag,
        'deskripsi': deskripsi,
        'biaya_pendaftaran': pendaftaran,
        'biaya_spp': spp,
        'hari_aktif': hari,
      });

      return _fetchPrograms(lembagaId);
    });
  }

  // --- FUNGSI UPDATE PROGRAM ---
  Future<void> updateProgram(ProgramModel updated) async {
    state = const AsyncValue.loading();
    final lembagaId = ref.read(appContextProvider).lembaga?.id;
    if (lembagaId == null) return;

    state = await AsyncValue.guard(() async {
      await _supabase
          .from('program')
          .update(updated.toJson())
          .eq('id', updated.id);

      return _fetchPrograms(lembagaId);
    });
  }

  // --- FUNGSI HAPUS PROGRAM ---
  Future<void> deleteProgram(String programId) async {
    state = const AsyncValue.loading();
    final lembagaId = ref.read(appContextProvider).lembaga?.id;
    if (lembagaId == null) return;

    state = await AsyncValue.guard(() async {
      await _supabase
          .from('program')
          .delete()
          .eq('id', programId);

      return _fetchPrograms(lembagaId);
    });
  }
}