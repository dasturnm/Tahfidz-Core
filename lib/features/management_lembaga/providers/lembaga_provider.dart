// Lokasi: lib/features/management_lembaga/providers/lembaga_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/app_context_provider.dart';
import '../models/cabang_model.dart';
import '../models/divisi_model.dart';
import '../models/jabatan_model.dart';
import '../services/lembaga_service.dart';

part 'lembaga_provider.g.dart';

@riverpod
class CabangList extends _$CabangList {
  final _service = LembagaService();

  @override
  Future<List<CabangModel>> build() async {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;
    if (lembagaId == null) return [];
    return _service.getCabang(ref, lembagaId);
  }

  Future<void> saveCabang(CabangModel cabang) async {
    await _service.saveCabang(ref, cabang);
    ref.invalidateSelf();
  }

  Future<void> deleteCabang(String id) async {
    await _service.deleteCabang(id);
    ref.invalidateSelf();
  }
}

@riverpod
class DivisiList extends _$DivisiList {
  final _service = LembagaService();

  @override
  Future<List<DivisiModel>> build() async {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;
    if (lembagaId == null) return [];
    return _service.getDivisi(ref, lembagaId);
  }

  Future<void> saveDivisi(DivisiModel divisi) async {
    await _service.saveDivisi(ref, divisi);
    ref.invalidateSelf();
  }

  Future<void> deleteDivisi(String id) async {
    await _service.deleteDivisi(id);
    ref.invalidateSelf();
  }
}

@riverpod
class JabatanList extends _$JabatanList {
  final _service = LembagaService();

  @override
  Future<List<JabatanModel>> build() async {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;
    if (lembagaId == null) return [];
    return _service.getJabatan(ref, lembagaId);
  }

  Future<void> saveJabatan(JabatanModel jabatan) async {
    await _service.saveJabatan(ref, jabatan);
    ref.invalidateSelf();
  }

  Future<void> deleteJabatan(String id) async {
    await _service.deleteJabatan(id);
    ref.invalidateSelf();
  }
}