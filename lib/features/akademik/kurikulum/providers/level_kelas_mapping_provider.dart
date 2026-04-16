// Lokasi: lib/features/akademik/kurikulum/providers/level_kelas_mapping_provider.dart

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/level_kelas_mapping_service.dart'; // FIX: Mengarah ke service spesifik

part 'level_kelas_mapping_provider.g.dart';

@riverpod
class LevelKelasMapping extends _$LevelKelasMapping {
  final _service = LevelKelasMappingService(); // FIX: Menggunakan LevelKelasMappingService

  @override
  Future<List<Map<String, dynamic>>> build(String levelId) async {
    try {
      if (levelId.isEmpty || levelId == 'null') return [];
      return _service.fetchLevelKelasMapping(levelId);
    } catch (e) {
      debugPrint("Error build LevelKelasMapping: $e");
      return [];
    }
  }

  Future<void> linkKelas(String kelasId, String levelId) async {
    try {
      await _service.updateKelasLevel(kelasId, levelId);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error linkKelas: $e");
    }
  }

  Future<void> unlinkKelas(String kelasId) async {
    try {
      await _service.updateKelasLevel(kelasId, null);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error unlinkKelas: $e");
    }
  }
}