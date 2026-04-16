import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/kurikulum_model.dart';
import '../services/kurikulum_service.dart';

part 'kurikulum_provider.g.dart';

@riverpod
class KurikulumList extends _$KurikulumList {
  final _service = KurikulumService();

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

  Future<void> saveKurikulum(KurikulumModel kurikulum) async {
    try {
      await _service.saveKurikulum(kurikulum);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error saveKurikulum: $e");
    }
  }

  Future<void> deleteKurikulum(String id) async {
    try {
      await _service.deleteKurikulum(id);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error deleteKurikulum: $e");
    }
  }
}