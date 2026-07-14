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
      ModulModel finalModul = modul;

      // IMPLEMENTASI OPSI 2: Lakukan transformasi balik data koordinat ke DB jika toggle hafalan mundur aktif
      if (finalModul.isReverseOrder) {
        finalModul = finalModul.copyWith(
          surahIdStart: modul.surahIdEnd,
          surahIdEnd: modul.surahIdStart,
          ayahStart: modul.ayahEnd,
          ayahEnd: modul.ayahStart,
          mulaiHalaman: modul.akhirHalaman,
          akhirHalaman: modul.mulaiHalaman,
          mulaiKoordinatJuz: modul.akhirKoordinatJuz,
          akhirKoordinatJuz: modul.mulaiKoordinatJuz,
        );
      }

      // FIX: Mendelegasikan logika database ke service
      // Membersihkan field yang tidak ada di skema modul_kurikulum sebelum dikirim ke service
      final modulData = finalModul.toJson();
      modulData.remove('lembaga_id');
      await _service.saveModul(ModulModel.fromJson(modulData));
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