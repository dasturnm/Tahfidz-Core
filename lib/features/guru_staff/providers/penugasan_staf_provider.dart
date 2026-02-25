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
    String? cabangId,
    required String jabatanId,
    bool isUtama = false, // Tambahan: Mendukung Rangkap Jabatan
    bool deactivatePrevious = false, // Tambahan: Opsi Mutasi (Ganti) atau Rangkap (Tambah)
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final today = DateTime.now().toIso8601String().split('T')[0];

      // 1. Jika diminta mutasi (bukan rangkap), nonaktifkan penugasan lama
      if (deactivatePrevious) {
        await supabase
            .from('penugasan_staf')
            .update({
          'status': 'selesai',
          'tanggal_selesai': today,
          'is_utama': false,
        })
            .eq('profile_id', stafId)
            .eq('status', 'aktif');
      }

      // 2. Jika ini jabatan utama, set jabatan lain milik staf ini menjadi false dulu
      if (isUtama) {
        await supabase
            .from('penugasan_staf')
            .update({'is_utama': false})
            .eq('profile_id', stafId);
      }

      // 3. Proses insert ke tabel penugasan_staf
      await supabase.from('penugasan_staf').insert({
        'profile_id': stafId,
        'cabang_id': cabangId,
        'jabatan_id': jabatanId,
        'tanggal_mulai': today,
        'is_utama': isUtama,
        'status': 'aktif',
      });
    } catch (e) {
      // Lempar error ke UI jika proses gagal agar bisa ditangkap oleh blok catch di form
      rethrow;
    }
  }
}