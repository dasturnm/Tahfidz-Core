// Lokasi: lib/features/guru_staff/providers/penugasan_staf_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tahfidz_core/core/providers/app_context_provider.dart'; // TAMBAHAN
import '../models/penugasan_staf_model.dart';
import '../services/penugasan_staf_service.dart';

part 'penugasan_staf_provider.g.dart';

@riverpod
class PenugasanStafList extends _$PenugasanStafList {
  final _service = PenugasanStafService();

  @override
  Future<List<PenugasanStafModel>> build(String lembagaId) async {
    // FIX: Memanggil service (Worker) untuk ambil data
    return _service.fetchPenugasan(lembagaId: lembagaId);
  }

  Future<void> savePenugasan(PenugasanStafModel penugasan) async {
    state = const AsyncValue.loading();
    // FIX: Menggunakan AsyncValue.guard untuk mencegah "Future already completed"
    state = await AsyncValue.guard(() async {
      await _service.savePenugasan(penugasan);
      // Ambil data terbaru secara aman
      return _service.fetchPenugasan(lembagaId: lembagaId);
    });
  }

  Future<void> hapusPenugasan(String id) async {
    state = const AsyncValue.loading();
    // FIX: Menggunakan AsyncValue.guard untuk mencegah "Future already completed"
    state = await AsyncValue.guard(() async {
      await _service.deletePenugasan(id);
      // Ambil data terbaru secara aman
      return _service.fetchPenugasan(lembagaId: lembagaId);
    });
  }
}

@riverpod
class PenugasanStaf extends _$PenugasanStaf {
  final _service = PenugasanStafService();

  @override
  void build() {
    // FIX: Method build dibuat void (sinkronus) untuk Notifier Aksi/Mutasi
    // agar tidak terjadi konflik completer saat update state manual.
  }

  /// Menambahkan data penugasan staf/guru baru ke database
  Future<void> tambahPenugasan({
    required String stafId,
    String? cabangId,
    required String jabatanId,
    bool isUtama = false, // Tambahan: Mendukung Rangkap Jabatan
    bool deactivatePrevious = false, // Tambahan: Opsi Mutasi (Ganti) atau Rangkap (Tambah)
  }) async {
    state = const AsyncValue.loading();

    // FIX: Menggunakan try-catch manual karena state bertipe void (menghindari use_of_void_result)
    try {
      // FIX: Ambil lembagaId dari context agar data tidak 'Yatim' (Lolos RLS)
      final lembagaId = ref.read(appContextProvider).lembaga?.id ?? '';

      await _service.tambahPenugasan(
        stafId: stafId,
        lembagaId: lembagaId, // SINKRON: Mengirim lembagaId ke service
        jabatanId: jabatanId,
        cabangId: cabangId,
        isUtama: isUtama,
        deactivatePrevious: deactivatePrevious,
      );

      // Berhasil: set state ke data null
      state = const AsyncValue.data(null);
    } catch (e, st) {
      // Gagal: set state ke error
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}