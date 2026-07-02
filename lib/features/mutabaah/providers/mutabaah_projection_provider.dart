// Lokasi: lib/features/mutabaah/providers/mutabaah_projection_provider.dart

// FIX: Tambahkan import flutter_riverpod
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/mutabaah_projection_model.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart';
import '../services/mutabaah_service.dart';

// Standar AGENTS.md: Wajib menggunakan nama part yang identik dengan nama file
part 'mutabaah_projection_provider.g.dart';

/// Provider untuk mengambil proyeksi akademik (Sisa pertemuan & estimasi kelulusan)
/// Menggunakan parameter [siswaId] dan [modul]
@riverpod
Future<MutabaahProjectionModel> mutabaahProjection(
    MutabaahProjectionRef ref, // FIX: Menggunakan tipe generated Ref khusus fungsi ini agar tidak ditolak build_runner
    String siswaId,
    ModulModel modul,
    ) async {
  // Instansiasi service (bisa juga menggunakan watch/read jika service dibungkus provider lain)
  final service = MutabaahTahfidzService();

  // Mengambil hasil kalkulasi proyeksi dari service
  return await service.getModuleProjection(siswaId, modul);
}