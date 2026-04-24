// Lokasi: lib/features/kelas/providers/kelas_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_context_provider.dart';
import '../models/kelas_model.dart';
import '../services/kelas_service.dart';

part 'kelas_provider.g.dart';

// --- PROVIDER UNTUK PENCARIAN (Konsisten dengan StaffSearch) ---
@riverpod
class KelasSearch extends _$KelasSearch {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
}

@riverpod
class KelasList extends _$KelasList {
  // Menghubungkan ke provider service (Aturan 7)
  KelasService get _service => ref.read(kelasServiceProvider);

  @override
  Future<List<KelasModel>> build() async {
    // 1. Secara reaktif memantau perubahan lembaga/cabang (The Brain)
    final context = ref.watch(appContextProvider);
    final lembagaId = context.lembaga?.id;

    if (lembagaId == null) return [];

    // 2. Mengambil data melalui service (Parameter ref sesuai Protokol v2026.03.22)
    return _service.getKelas(ref);
  }

  // --- FUNGSI TAMBAH KELAS ---
  Future<void> addKelas(KelasModel newKelas) async {
    state = const AsyncValue.loading();
    try {
      final appContext = ref.read(appContextProvider);

      // Injeksi lembaga_id dari konteks saat ini (cabang_id dihapus karena redundan)
      final validatedKelas = newKelas.copyWith(
        lembagaId: appContext.lembaga?.id,
      );

      await _service.addKelas(validatedKelas);

      // 🔥 MODERN & REACTIVE: Paksa refresh build() untuk sinkronisasi total
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- FUNGSI UPDATE KELAS ---
  Future<void> updateKelas(KelasModel updatedKelas) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateKelas(updatedKelas);

      // Refresh state secara reaktif
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --- FUNGSI HAPUS KELAS ---
  Future<void> deleteKelas(String id) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteKelas(id);

      // Refresh state secara reaktif
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// --- PROVIDER HELPER (Krusial untuk Filter Reaktif) ---
// Menyediakan data list mentah agar bisa di-watch oleh filteredKelasProvider di siswa_provider.
@riverpod
List<KelasModel> kelas(Ref ref) {
  return ref.watch(kelasListProvider).maybeWhen(
    data: (list) => list,
    orElse: () => [],
  );
}