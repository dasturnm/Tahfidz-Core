// Lokasi: lib/features/akademik/kurikulum/providers/modul_provider.dart

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/kurikulum_model.dart';
import '../services/modul_service.dart'; // FIX: Mengarah ke service spesifik
import 'dart:convert';
import 'package:flutter/services.dart';

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
      // FIX LOCAL LOOKUP: Membaca skema koordinat sekuensial dari asset JSON lokal (Offline-First)
      final String jsonContent = await rootBundle.loadString('assets/mushaf_peta.json');
      final List<dynamic> localRows = json.decode(jsonContent) as List<dynamic>;

      // Filter baris yang sesuai dengan nomor surah modul
      final surahRows = localRows.where((r) {
        final sNum = int.tryParse(r['surah_number']?.toString() ?? '') ?? 0;
        return sNum == modul.surahIdStart;
      }).toList();

      Map<String, dynamic>? startRes;
      Map<String, dynamic>? endRes;

      if (surahRows.isNotEmpty) {
        // Cari baris koordinat awal ayat mulai
        final startMatches = surahRows.where((r) {
          final start = int.tryParse(r['ayah_start']?.toString() ?? '') ?? 0;
          final end = int.tryParse(r['ayah_end']?.toString() ?? '') ?? 0;
          return start <= modul.ayahStart && end >= modul.ayahStart;
        }).toList();
        if (startMatches.isNotEmpty) {
          startMatches.sort((a, b) => (int.tryParse(a['koordinat_baris']?.toString() ?? '') ?? 0)
              .compareTo(int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0));
          startRes = startMatches.first;
        }

        // Cari baris koordinat akhir ayat akhir
        final endMatches = surahRows.where((r) {
          final start = int.tryParse(r['ayah_start']?.toString() ?? '') ?? 0;
          final end = int.tryParse(r['ayah_end']?.toString() ?? '') ?? 0;
          return start <= modul.ayahEnd && end >= modul.ayahEnd;
        }).toList();
        if (endMatches.isNotEmpty) {
          endMatches.sort((a, b) => (int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0)
              .compareTo(int.tryParse(a['koordinat_baris']?.toString() ?? '') ?? 0));
          endRes = endMatches.first;
        }
      }

      ModulModel finalModul = modul;

      if (startRes != null && endRes != null) {
        final startKoor = int.tryParse(startRes['koordinat_baris']?.toString() ?? '') ?? 0;
        final endKoor = int.tryParse(endRes['koordinat_baris']?.toString() ?? '') ?? 0;

        final minKoor = startKoor < endKoor ? startKoor : endKoor;
        final maxKoor = startKoor < endKoor ? endKoor : startKoor;

        // Hitung total baris fisik di antara rentang koordinat secara lokal
        final int calculatedTotalBaris = surahRows.where((r) {
          final koor = int.tryParse(r['koordinat_baris']?.toString() ?? '') ?? 0;
          return koor >= minKoor && koor <= maxKoor;
        }).length;

        finalModul = modul.copyWith(totalBaris: calculatedTotalBaris);
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