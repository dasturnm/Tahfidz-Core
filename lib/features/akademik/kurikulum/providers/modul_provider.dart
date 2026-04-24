// Lokasi: lib/features/akademik/kurikulum/providers/modul_provider.dart

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/kurikulum_model.dart';
import '../services/modul_service.dart'; // FIX: Mengarah ke service spesifik

part 'modul_provider.g.dart';

@riverpod
class ModulList extends _$ModulList {
  final _service = ModulService(); // FIX: Menggunakan ModulService

  @override
  Future<List<ModulModel>> build(String levelId) async {
    try {
      if (levelId.isEmpty || levelId == 'null') return [];
      return _service.fetchModul(levelId);
    } catch (e) {
      debugPrint("Error build ModulList: $e");
      return [];
    }
  }

  Future<void> saveModul(ModulModel modul) async {
    try {
      // FIX: Mendelegasikan logika database ke service
      await _service.saveModul(modul);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error saveModul: $e");
      rethrow; // Tambahkan rethrow agar UI bisa menangkap error
    }
  }

  Future<void> deleteModul(String id) async {
    try {
      // FIX: Mendelegasikan logika database ke service
      await _service.deleteModul(id);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error deleteModul: $e");
      rethrow; // Tambahkan rethrow agar UI bisa menampilkan pesan gagal
    }
  }
}