import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/app_context_provider.dart';
import '../models/program_model.dart';

part 'program_provider.g.dart';

@riverpod
class ProgramNotifier extends _$ProgramNotifier {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<ProgramModel>> build() async {
    // Mengambil data dari context global aplikasi
    final context = ref.watch(appContextProvider);
    final lembagaId = context.lembaga?.id;
    final cabangId = context.currentCabang?.id;

    if (lembagaId == null) return [];

    return _fetchPrograms(lembagaId, cabangId);
  }

  // --- FUNGSI AMBIL DATA ---
  Future<List<ProgramModel>> _fetchPrograms(String lembagaId, [String? cabangId]) async {
    var query = _supabase
        .from('program')
        .select()
        .eq('lembaga_id', lembagaId);

    // Filter: Tampilkan program milik cabang terpilih ATAU program global (cabang_id null)
    if (cabangId != null && cabangId.isNotEmpty) {
      query = query.or('cabang_id.eq.$cabangId,cabang_id.is.null');
    }

    final response = await query.order('nama_program');

    return (response as List).map((e) => ProgramModel.fromJson(e)).toList();
  }

  // --- FUNGSI TAMBAH PROGRAM BARU ---
  Future<void> addProgram({
    required String nama,
    String? cabangId, // Diubah: Mengganti tag menjadi cabangId
    String? deskripsi,
    double pendaftaran = 0,
    double spp = 0,
    List<String> hari = const [],
  }) async {
    state = const AsyncValue.loading();

    final context = ref.read(appContextProvider);
    final lembagaId = context.lembaga?.id;
    final currentCabangId = context.currentCabang?.id;

    if (lembagaId == null) return;

    state = await AsyncValue.guard(() async {
      await _supabase.from('program').insert({
        'lembaga_id': lembagaId,
        'cabang_id': cabangId, // Diubah: Menggunakan kolom cabang_id
        'nama_program': nama,
        'deskripsi': deskripsi,
        'biaya_pendaftaran': pendaftaran,
        'biaya_spp': spp,
        'hari_aktif': hari,
      });

      return _fetchPrograms(lembagaId, currentCabangId);
    });
  }

  // --- FUNGSI UPDATE PROGRAM ---
  Future<void> updateProgram(ProgramModel updated) async {
    state = const AsyncValue.loading();
    final context = ref.read(appContextProvider);
    final lembagaId = context.lembaga?.id;
    final cabangId = context.currentCabang?.id;

    if (lembagaId == null) return;

    state = await AsyncValue.guard(() async {
      // FIX: Gunakan Map spesifik untuk update guna menghindari konflik RLS/ID di Supabase
      await _supabase
          .from('program')
          .update({
        'nama_program': updated.namaProgram,
        'cabang_id': updated.cabangId,
        'deskripsi': updated.deskripsi,
        'biaya_pendaftaran': updated.biayaPendaftaran,
        'biaya_spp': updated.biayaSpp,
        'hari_aktif': updated.hariAktif,
      })
          .eq('id', updated.id);

      return _fetchPrograms(lembagaId, cabangId);
    });
  }

  // --- FUNGSI HAPUS PROGRAM ---
  Future<void> deleteProgram(String programId) async {
    state = const AsyncValue.loading();
    final context = ref.read(appContextProvider);
    final lembagaId = context.lembaga?.id;
    final currentCabangId = context.currentCabang?.id;

    if (lembagaId == null) return;

    state = await AsyncValue.guard(() async {
      await _supabase
          .from('program')
          .delete()
          .eq('id', programId);

      return _fetchPrograms(lembagaId, currentCabangId);
    });
  }
}