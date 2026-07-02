// Lokasi: lib/features/mushaf/providers/mushaf_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mushaf_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

final mushafPageProvider = FutureProvider.family<List<MushafLine>, int>((ref, pageNumber) async {
  // FIX LOCAL CHUNK: Membaca potongan baris fisik per halaman dari JSON lokal
  final String jsonContent = await rootBundle.loadString('assets/mushaf_peta.json');
  final List<dynamic> allRows = json.decode(jsonContent) as List<dynamic>;

  final filtered = allRows.where((row) {
    final pNum = int.tryParse(row['page_number']?.toString() ?? '') ?? 0;
    return pNum == pageNumber;
  }).toList();

  filtered.sort((a, b) {
    final lA = int.tryParse(a['line_number']?.toString() ?? '') ?? 0;
    final lB = int.tryParse(b['line_number']?.toString() ?? '') ?? 0;
    return lA.compareTo(lB);
  });

  return filtered.map((e) => MushafLine.fromJson(e)).toList();
});

// StateProvider ini sekarang sangat penting untuk sinkronisasi Index -> MushafView
final currentPageProvider = StateProvider<int>((ref) => 1);

/// Provider untuk menyimpan kata kunci pencarian Surah (Poin 1)
final mushafSearchProvider = StateProvider<String>((ref) => "");

/// Provider untuk mengambil daftar surah unik dari database Supabase (Poin 2)
final surahListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Daftar statis jumlah ayah 114 Surah untuk mencegah error Null
  const surahAyahCounts = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6
  ];

  // FIX LOCAL ENGINE: Mengekstrak daftar 114 surah unik dari memori lokal secara instan
  final String jsonContent = await rootBundle.loadString('assets/mushaf_peta.json');
  final List<dynamic> allRows = json.decode(jsonContent) as List<dynamic>;

  final Map<int, Map<String, dynamic>> uniqueSurahs = {};

  for (var row in allRows) {
    final sNum = int.tryParse(row['surah_number']?.toString() ?? '') ?? 0;
    final aStart = int.tryParse(row['ayah_start']?.toString() ?? '') ?? 0;
    final aEnd = int.tryParse(row['ayah_end']?.toString() ?? '') ?? 0;
    final pNum = int.tryParse(row['page_number']?.toString() ?? '') ?? 1;

    if (sNum > 0 && aStart <= 1 && aEnd >= 1) {
      if (!uniqueSurahs.containsKey(sNum)) {
        uniqueSurahs[sNum] = {
          'surah_number': sNum,
          'surah_name': row['surah_name']?.toString() ?? 'Surah $sNum',
          'page_number': pNum,
          'total_ayah': (sNum <= surahAyahCounts.length) ? surahAyahCounts[sNum - 1] : 0,
        };
      }
    }
  }

  final result = uniqueSurahs.values.toList();
  result.sort((a, b) => (a['surah_number'] as int).compareTo(b['surah_number'] as int));
  return result;
});