// Lokasi: lib/features/akademik/kurikulum/providers/level_provider.dart

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/kurikulum_model.dart';
import '../services/level_service.dart'; // FIX: Mengarah ke service spesifik

part 'level_provider.g.dart';

@riverpod
class LevelList extends _$LevelList {
  final _service = LevelService(); // FIX: Menggunakan LevelService

  @override
  Future<List<LevelModel>> build(String jenjangId) async {
    try {
      if (jenjangId.isEmpty || jenjangId == 'null') return [];
      return _service.fetchLevel(jenjangId);
    } catch (e) {
      debugPrint("Error build LevelList: $e");
      return [];
    }
  }

  Future<void> saveLevel(LevelModel level) async {
    try {
      // FIX: Mendelegasikan logika database ke service
      await _service.saveLevel(level);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error saveLevel: $e');
    }
  }

  Future<void> deleteLevel(String id) async {
    try {
      // FIX: Mendelegasikan logika database ke service
      await _service.deleteLevel(id);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error deleteLevel: $e");
    }
  }
}