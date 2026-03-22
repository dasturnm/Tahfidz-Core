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