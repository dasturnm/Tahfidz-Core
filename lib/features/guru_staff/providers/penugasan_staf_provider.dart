import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'penugasan_staf_provider.g.dart';

@riverpod
class PenugasanStaf extends _$PenugasanStaf {
  @override
  FutureOr<void> build() {
    // Inisialisasi awal (kosong)
    return null;
  }

  /// Menambahkan data penugasan staf/guru baru ke database
  Future<void> tambahPenugasan({
    required String stafId,
    required String cabangId,
    required String jabatanId,
  }) async {
    // Set state ke loading agar UI bisa merespon jika perlu
    state = const AsyncLoading();

    // Menggunakan guard untuk menangani perubahan state secara aman
    state = await AsyncValue.guard(() async {
      final supabase = Supabase.instance.client;

      // Proses insert ke tabel penugasan_staf
      await supabase.from('penugasan_staf').insert({
        'staf_id': stafId,
        'cabang_id': cabangId,
        'jabatan_id': jabatanId,
        'tanggal_mulai': DateTime.now().toIso8601String(),
        'status': 'aktif',
      });
    });

    // Lempar error ke UI jika proses gagal, tapi state sudah aman dikelola guard.
    if (state.hasError) {
      throw state.error!;
    }
  }
}