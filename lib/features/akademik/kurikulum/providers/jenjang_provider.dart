// Lokasi: lib/features/akademik/kurikulum/providers/jenjang_provider.dart

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/kurikulum_model.dart';
import '../services/jenjang_service.dart'; // FIX: Mengarah ke service spesifik

part 'jenjang_provider.g.dart';

@riverpod
class JenjangList extends _$JenjangList {
  final _service = JenjangService(); // FIX: Menggunakan JenjangService

  @override
  Future<List<JenjangModel>> build(String kurikulumId) async {
    try {
      if (kurikulumId.isEmpty || kurikulumId == 'null') return [];
      return _service.fetchJenjang(kurikulumId);
    } catch (e) {
      debugPrint("Error build JenjangList: $e");
      return [];
    }
  }

  Future<void> saveJenjang(JenjangModel jenjang) async {
    try {
      await _service.saveJenjang(jenjang);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error saveJenjang: $e');
    }
  }

  Future<void> deleteJenjang(String id) async {
    try {
      await _service.deleteJenjang(id);
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Error deleteJenjang: $e");
    }
  }
}