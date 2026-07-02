// Lokasi: lib/features/akademik/evaluasi/providers/evaluasi_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/evaluasi_service.dart';
import '../services/ukl_engine_service.dart';
import '../models/evaluasi_record_model.dart';
import '../../../../core/providers/app_context_provider.dart'; // Mengambil state global

part 'evaluasi_controller.g.dart';

@riverpod
class EvaluasiController extends _$EvaluasiController {
  @override
  FutureOr<void> build() {
    // State awal adalah kosong (void).
    // Kita menggunakan controller ini utamanya untuk memantau status loading/error saat submit.
  }

  /// Fungsi untuk menyimpan hasil ujian ke database
  Future<void> submitEvaluasi({
    required String siswaId,
    required String modulId,
    required String tipeEvaluasi, // 'TASMI' atau 'UKL'
    required double nilaiAkhir,
    required bool isLulus,
    required Map<String, dynamic> detailPenilaian,
    String? catatan,
  }) async {
    // Ubah status state menjadi loading agar UI bisa menampilkan animasi putaran (spinner)
    state = const AsyncLoading();

    try {
      // 1. Ambil konteks Lembaga dan Guru secara reaktif
      final appContext = ref.read(appContextProvider);
      final lembagaId = appContext.lembaga?.id; // FIX: Menggunakan .lembaga sesuai isi AppContextState
      final guruId = appContext.profile?.id;

      if (lembagaId == null || guruId == null) {
        throw Exception("Data Lembaga atau Guru tidak ditemukan. Pastikan Anda sudah login dengan benar.");
      }

      // 2. Bungkus data ke dalam Model yang sudah kita buat
      final record = EvaluasiRecordModel(
        lembagaId: lembagaId,
        siswaId: siswaId,
        guruId: guruId,
        modulId: modulId,
        tipeEvaluasi: tipeEvaluasi,
        nilaiAkhir: nilaiAkhir,
        isLulus: isLulus,
        detailPenilaian: detailPenilaian,
        catatan: catatan,
      );

      // 3. Simpan data menggunakan EvaluasiService
      final evaluasiService = EvaluasiService();
      await evaluasiService.submitEvaluasi(record);

      // 4. LOGIKA PINTAR: Jika ini Ujian Kenaikan Level (UKL) dan Lulus, otomatis naikkan kelas!
      if (tipeEvaluasi == 'UKL' && isLulus) {
        final uklEngine = UklEngineService();
        await uklEngine.processPromotion(siswaId);
      }

      // Beri tahu UI bahwa proses berhasil (berhenti loading)
      state = const AsyncData(null);
    } catch (e, st) {
      // Beri tahu UI bahwa terjadi error
      state = AsyncError(e, st);
      rethrow; // Lempar error kembali ke UI agar bisa ditampilkan di SnackBar
    }
  }

  /// Jembatan pengambil data hasil ujian lama dari database untuk disuplai ke UI State
  Future<Map<String, dynamic>?> fetchSavedEvaluasi({
    required String siswaId,
    required String modulId,
  }) async {
    try {
      final evaluasiService = EvaluasiService();
      return await evaluasiService.fetchSavedEvaluasi(siswaId, modulId);
    } catch (e) {
      rethrow;
    }
  }
}