// Lokasi: lib/features/cabang/providers/cabang_provider.dart

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/cabang_model.dart';
import '../services/cabang_service.dart'; // Import service baru

part 'cabang_provider.g.dart';

@riverpod
class CabangList extends _$CabangList {
  // FIX: Inisialisasi CabangService
  final _service = CabangService();

  @override
  Future<List<CabangModel>> build() async {
    try {
      // FIX: Mendelegasikan logika ke service
      return await _service.getCabang(ref);
    } catch (e) {
      debugPrint("Error memuat CabangList: $e");
      return [];
    }
  }
}