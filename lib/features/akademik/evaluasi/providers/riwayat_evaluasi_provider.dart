// Lokasi: lib/features/akademik/evaluasi/providers/riwayat_evaluasi_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/evaluasi_record_model.dart';
import '../services/evaluasi_service.dart';

part 'riwayat_evaluasi_provider.g.dart';

/// Provider ini bertugas mengambil daftar riwayat evaluasi/ujian berdasarkan ID Siswa.
/// Karena menggunakan @riverpod, data akan di-cache dan otomatis diperbarui jika ada perubahan.
@riverpod
Future<List<EvaluasiRecordModel>> riwayatEvaluasi(RiwayatEvaluasiRef ref, String siswaId) async {
  final evaluasiService = EvaluasiService();
  // Memanggil fungsi READ dari layer service yang telah kita buat
  return await evaluasiService.getRiwayatEvaluasi(siswaId);
}