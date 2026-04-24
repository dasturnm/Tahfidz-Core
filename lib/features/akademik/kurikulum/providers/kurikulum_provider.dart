// Lokasi: lib/features/akademik/kurikulum/providers/kurikulum_provider.dart

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/kurikulum_model.dart';
import '../services/kurikulum_service.dart';

part 'kurikulum_provider.g.dart';

// =============================================================================
// PROVIDER: KurikulumList
// Mengelola state daftar kurikulum dan aksi terkait (Save/Delete)
// =============================================================================

@riverpod
class KurikulumList extends _$KurikulumList {
  final _service = KurikulumService();

  // ---------------------------------------------------------------------------
  // 1. BUILD & FETCH LOGIC
  // ---------------------------------------------------------------------------
  @override
  Future<List<KurikulumModel>> build(
      String lembagaId, {
        String search = '',
        String status = 'Semua',
        String? programId,
        String? tahunAjaranId,
      }) async {
    try {
      if (lembagaId.isEmpty || lembagaId == 'null') return [];
      return _service.fetchKurikulum(
        lembagaId: lembagaId,
        search: search,
        status: status,
        programId: programId,
        tahunAjaranId: tahunAjaranId,
      );
    } catch (e) {
      debugPrint("Error build KurikulumList: $e");
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // 2. MUTATION LOGIC (SAVE & DELETE)
  // ---------------------------------------------------------------------------

  /// Menyimpan data kurikulum baru atau memperbarui yang lama
  Future<void> saveKurikulum(KurikulumModel kurikulum) async {
    try {
      await _service.saveKurikulum(kurikulum);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error saveKurikulum: $e");
    }
  }

  /// Menghapus kurikulum berdasarkan ID
  Future<void> deleteKurikulum(String id) async {
    try {
      await _service.deleteKurikulum(id);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error deleteKurikulum: $e");
    }
  }
}