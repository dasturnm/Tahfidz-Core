// Lokasi: lib/features/siswa/providers/siswa_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';
import '../models/siswa_model.dart';
import '../services/siswa_service.dart';
import '../../kelas/models/kelas_model.dart'; // Tambahan untuk tipe data
import '../../kelas/providers/kelas_provider.dart'; // Tambahan untuk akses data kelas

part 'siswa_provider.g.dart';

// --- PROVIDER PENCARIAN (Modern & Reactive) ---
@riverpod
class SiswaSearch extends _$SiswaSearch {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
}

// --- PROVIDER FILTER KELAS (Reactive Filter) ---
// Provider ini digunakan untuk menyaring daftar kelas berdasarkan Program ID yang dipilih.
@riverpod
List<KelasModel> filteredKelas(FilteredKelasRef ref, String? programId) {
  if (programId == null) return [];

  // Logic reaktif: Mengambil semua kelas dan memfilternya berdasarkan programId
  final allKelas = ref.watch(kelasProvider);

  return allKelas.where((kelas) => kelas.programId == programId).toList();
}

// --- PROVIDER UTAMA SISWA (AsyncNotifier) ---
@riverpod
class SiswaList extends _$SiswaList {
  // Menjaga nama variabel sesuai kode dasar Coach (Menggunakan Provider v2026.03.22)
  SiswaService get _siswaervice => ref.read(siswaServiceProvider);

  @override
  Future<List<SiswaModel>> build() async {
    // 🛡️ REAKTIF: Otomatis fetch ulang jika lembaga di context berubah
    final appContext = ref.watch(appContextProvider);
    final lembagaId = appContext.lembaga?.id;

    if (lembagaId == null) return [];

    // Mengambil data melalui service (The Worker)
    return _siswaervice.getSiswa(ref);
  }

  // --- ACTIONS (LOGIK CRUD) ---

  Future<bool> addSiswa(SiswaModel newSiswa) async {
    state = const AsyncValue.loading();
    try {
      final appContext = ref.read(appContextProvider);
      final validatedSiswa = newSiswa.copyWith(
        lembagaId: appContext.lembaga?.id,
        cabangId: appContext.currentCabang?.id,
      );

      await _siswaervice.addSiswa(validatedSiswa);

      // Refresh state secara internal
      ref.invalidateSelf();
      await future;
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateSiswa(SiswaModel updatedSiswa) async {
    state = const AsyncValue.loading();
    try {
      await _siswaervice.updateSiswa(updatedSiswa);
      ref.invalidateSelf();
      await future;
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteSiswa(String id) async {
    state = const AsyncValue.loading();
    try {
      await _siswaervice.deleteSiswa(id);
      ref.invalidateSelf();
      await future;
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // --- FITUR PLOTTING ---

  Future<bool> assignSiswaToKelas(String siswaId, String? kelasId) async {
    state = const AsyncValue.loading();
    try {
      await _siswaervice.assignSiswaToKelas(siswaId, kelasId);
      ref.invalidateSelf(); // Refresh data siswa
      ref.invalidate(kelasListProvider); // 🔥 PERBAIKAN: Paksa refresh data kelas agar jumlah sinkron
      await future;
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> bulkImportSiswa(List<SiswaModel> siswa) async {
    state = const AsyncValue.loading();
    try {
      await _siswaervice.bulkAddSiswa(siswa);
      ref.invalidateSelf();
      await future;
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> bulkAssignToKelas(List<String> siswaIds, String? kelasId) async {
    state = const AsyncValue.loading();
    try {
      await _siswaervice.bulkAssignSiswaToKelas(siswaIds, kelasId);
      ref.invalidateSelf(); // Refresh data siswa
      ref.invalidate(kelasListProvider); // 🔥 PERBAIKAN: Paksa refresh data kelas agar jumlah sinkron
      await future;
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // --- FITUR CSV ---

  Future<void> exportSiswa() async {
    final listSiswa = state.value ?? [];
    await _siswaervice.exportSiswaKeCsv(listSiswa);
  }

  Future<void> downloadTemplate() async {
    await _siswaervice.unduhTemplateSiswaCsv();
  }

  Future<void> importSiswaCsv() async {
    final appContext = ref.read(appContextProvider);
    final lembagaId = appContext.lembaga?.id ?? '';

    await _siswaervice.importSiswaDariCsv(
      lembagaId: lembagaId,
      onComplete: () => ref.invalidateSelf(),
    );
  }

  // --- HELPER COMPATIBILITY (Untuk UI existing Coach) ---

  // Pengganti fetchSiswa manual agar tidak error di initState UI
  Future<void> fetchSiswa() async => ref.invalidateSelf();

  // Pengganti searchSiswa agar tidak error di UI
  void searchSiswa(String query) => ref.read(siswaSearchProvider.notifier).updateQuery(query);

  // Getter data list (Safety handling)
  List<SiswaModel> get siswa => state.value ?? [];

  // Getters filter lokal
  List<SiswaModel> get unassignedSiswa {
    return (state.value ?? []).where((s) => s.kelasId == null).toList();
  }

  List<SiswaModel> getSiswaInKelas(String kelasId) {
    return (state.value ?? []).where((s) => s.kelasId == kelasId).toList();
  }

  // Getter error message
  String? get errorMessage => state.hasError ? state.error.toString() : null;
  bool get isLoading => state.isLoading;
}