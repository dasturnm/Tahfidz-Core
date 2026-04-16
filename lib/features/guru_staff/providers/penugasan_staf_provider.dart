import 'package:riverpod_annotation/riverpod_annotation.dart';
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
    try {
      state = const AsyncValue.loading();

      // FIX: Logika simpan dipindah ke service
      await _service.savePenugasan(penugasan);

      // Refresh data agar UI otomatis update
      state = AsyncValue.data(await _service.fetchPenugasan(lembagaId: lembagaId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> hapusPenugasan(String id) async {
    try {
      state = const AsyncValue.loading();

      // FIX: Logika hapus dipindah ke service
      await _service.deletePenugasan(id);

      state = AsyncValue.data(await _service.fetchPenugasan(lembagaId: lembagaId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
class PenugasanStaf extends _$PenugasanStaf {
  final _service = PenugasanStafService();

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
      state = const AsyncValue.loading();

      // FIX: Pindahkan seluruh logika bisnis mutasi & rangkap ke Service
      await _service.tambahPenugasan(
        stafId: stafId,
        jabatanId: jabatanId,
        cabangId: cabangId,
        isUtama: isUtama,
        deactivatePrevious: deactivatePrevious,
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Lempar error ke UI jika proses gagal agar bisa ditangkap oleh blok catch di form
      rethrow;
    }
  }
}