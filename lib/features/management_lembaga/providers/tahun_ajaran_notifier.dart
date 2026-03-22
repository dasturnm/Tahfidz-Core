import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tahun_ajaran_model.dart';
import '../../../core/providers/app_context_provider.dart';

part 'tahun_ajaran_notifier.g.dart';

@riverpod
class TahunAjaranNotifier extends _$TahunAjaranNotifier {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<TahunAjaranModel>> build() async {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;
    if (lembagaId == null) return [];

    final data = await _supabase
        .from('tahun_ajaran')
        .select()
        .eq('lembaga_id', lembagaId)
        .order('label_tahun', ascending: false);

    return (data as List).map((e) => TahunAjaranModel.fromJson(e)).toList();
  }

  // --- FUNGSI TAMBAH (CREATE) ---
  Future<void> addTahunAjaran(TahunAjaranModel ta) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.from('tahun_ajaran').insert(ta.toJson());
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- FUNGSI UBAH (UPDATE) ---
  Future<void> updateTahunAjaran(TahunAjaranModel ta) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.from('tahun_ajaran').update(ta.toJson()).eq('id', ta.id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- FUNGSI HAPUS (DELETE) ---
  Future<void> deleteTahunAjaran(String id) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.from('tahun_ajaran').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- FUNGSI SET AKTIF (Menghubungkan ke Lembaga) ---
  Future<void> setTahunAjaranAktif(String taId) async {
    final lembagaId = ref.read(appContextProvider).lembaga?.id;
    if (lembagaId == null) return;

    state = const AsyncValue.loading(); // Baru: Atur status loading
    try {
      await _supabase
          .from('lembaga')
          .update({'tahun_ajaran_aktif_id': taId})
          .eq('id', lembagaId);

      // Refresh context agar seluruh aplikasi tahu tahun ajaran sudah berubah
      await ref.read(appContextProvider.notifier).initContext();
    } catch (e, st) {
      state = AsyncValue.error(e, st); // Baru: Tangkap error jika gagal
    }
  }

  // --- LOGIKA SEMI-OTOMATIS: SARAN TAHUN ---
  String sarankanLabelTahun() {
    final now = DateTime.now();
    // Jika bulan sekarang Juli ke atas, sarankan tahun ini/tahun depan
    if (now.month >= 7) {
      return "${now.year}/${now.year + 1}";
    } else {
      // Jika bulan Januari - Juni, sarankan tahun lalu/tahun ini
      return "${now.year - 1}/${now.year}";
    }
  }
}