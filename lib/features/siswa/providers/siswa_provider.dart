// Lokasi: lib/features/siswa/providers/siswa_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart';
import '../models/siswa_model.dart';
import '../services/siswa_service.dart';
import '../../kelas/models/kelas_model.dart'; // Tambahan untuk tipe data
import '../../kelas/providers/kelas_provider.dart'; // Tambahan untuk akses data kelas
import '../../mutabaah/providers/mutabaah_provider.dart'; // TAMBAHAN: Sinkronisasi Multi-Modul

part 'siswa_provider.g.dart';

// --- PROVIDER PENCARIAN (Modern & Reactive) ---
@riverpod
class SiswaSearch extends _$SiswaSearch {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
}

// --- NEW: PROVIDER FILTER CABANG (Reactive) ---
@riverpod
class SiswaFilterCabang extends _$SiswaFilterCabang {
  @override
  String? build() => null;
  void update(String? id) => state = id;
}

// --- NEW: PROVIDER FILTER PROGRAM (Reactive) ---
@riverpod
class SiswaFilterProgram extends _$SiswaFilterProgram {
  @override
  String? build() => null;
  void update(String? id) => state = id;
}

// --- NEW: PROVIDER FILTER KURIKULUM (Reactive) ---
@riverpod
class SiswaFilterKurikulum extends _$SiswaFilterKurikulum {
  @override
  String? build() => null;
  void update(String? id) => state = id;
}

// --- NEW: PROVIDER FILTER LEVEL (Reactive) ---
@riverpod
class SiswaFilterLevel extends _$SiswaFilterLevel {
  @override
  String? build() => null;
  void update(String? id) => state = id;
}

// --- NEW: PROVIDER FILTERED SISWA (The Solution) ---
@riverpod
List<SiswaModel> filteredSiswa(FilteredSiswaRef ref) {
  // 1. Ambil data mentah dari database
  final allSiswa = ref.watch(siswaListProvider).value ?? [];

  // 2. Ambil semua state filter
  final query = ref.watch(siswaSearchProvider).toLowerCase();
  final cabangId = ref.watch(siswaFilterCabangProvider);
  final programId = ref.watch(siswaFilterProgramProvider);
  final kurikulumId = ref.watch(siswaFilterKurikulumProvider); // TAMBAHAN
  final levelId = ref.watch(siswaFilterLevelProvider);

  // 3. Terapkan logika penyaringan (Search & Multiple Filters)
  return allSiswa.where((s) {
    // A. Filter Pencarian (Nama atau NISN)
    final matchesQuery = s.namaLengkap.toLowerCase().contains(query) ||
        (s.nisn?.contains(query) ?? false);

    // B. Filter Cabang
    final matchesCabang = cabangId == null || s.cabangId == cabangId;

    // C. Filter Program
    final matchesProgram = programId == null || s.programId == programId;

    // D. Filter Kurikulum (TAMBAHAN)
    final matchesKurikulum = kurikulumId == null || s.kurikulumId == kurikulumId;

    // E. Filter Level (Jenjang)
    final matchesLevel = levelId == null || s.levelId == levelId;

    return matchesQuery && matchesCabang && matchesProgram && matchesKurikulum && matchesLevel;
  }).toList();
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

      // TAMBAHAN: Paksa refresh daftar modul jika Level/Data Siswa berubah
      if (updatedSiswa.id != null) {
        ref.invalidate(activeModulsBySiswaProvider(updatedSiswa.id!));
      }

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

  // TAMBAHAN: Metode pembaruan state lokal instan untuk mendukung transisi 3-tahap akademik secara reaktif di UI tanpa reload
  void updateAcademicStateLocal(String siswaId, String newState) {
    if (state.value == null) return;

    final currentList = state.value!;
    final index = currentList.indexWhere((s) => s.id == siswaId);

    if (index != -1) {
      final updatedList = List<SiswaModel>.from(currentList);
      updatedList[index] = updatedList[index].copyWith(
        academicState: newState,
        isReadyForExam: newState == 'exam_ready',
      );
      state = AsyncValue.data(updatedList);
    }
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