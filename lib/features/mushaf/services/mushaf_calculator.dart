// Lokasi: lib/features/mushaf/services/mushaf_calculator.dart

import 'dart:convert';
import 'package:flutter/services.dart';

/// Daftar statis jumlah ayat per surah (114 Surah) sebagai fallback stabilitas
const List<int> _surahAyahCounts = [
  7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6
];

class MushafCalculator {
  MushafCalculator();

  Future<Map<String, dynamic>> calculateVolume({
    required int sSurah,
    required int sAyah,
    required int eSurah,
    required int eAyah,
    double? targetAmount,
    double previousDebt = 0.0,
    String? targetUnit,
  }) async {
    try {
      final int maxAyahS = (sSurah >= 1 && sSurah <= 114) ? _surahAyahCounts[sSurah - 1] : 286;
      final int maxAyahE = (eSurah >= 1 && eSurah <= 114) ? _surahAyahCounts[eSurah - 1] : 286;
      final int safeSAyah = sAyah > maxAyahS ? maxAyahS : (sAyah < 1 ? 1 : sAyah);
      final int safeEAyah = eAyah > maxAyahE ? maxAyahE : (eAyah < 1 ? 1 : eAyah);

      final String jsonContent = await rootBundle.loadString('assets/mushaf_peta.json');
      final List<dynamic> allRows = json.decode(jsonContent) as List<dynamic>;

      final sSurahRows = allRows.where((r) {
        final sNum = int.tryParse(r['surah_number']?.toString() ?? '') ?? 0;
        return sNum == sSurah;
      }).toList();

      sSurahRows.sort((a, b) {
        final kA = int.tryParse(a['koordinat_baris']?.toString() ?? '') ?? 0;
        final kB = int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0;
        return kA.compareTo(kB);
      });

      Map<String, dynamic>? startRes;
      if (safeSAyah == 1) {
        for (var r in sSurahRows) {
          final int? aStart = int.tryParse(r['ayah_start']?.toString() ?? '');
          final int? aEnd = int.tryParse(r['ayah_end']?.toString() ?? '');

          if (aStart != null && aEnd != null) {
            startRes = Map<String, dynamic>.from(r as Map);
            break;
          }
        }
      } else {
        for (var r in sSurahRows) {
          final int? aStart = int.tryParse(r['ayah_start']?.toString() ?? '');
          final int? aEnd = int.tryParse(r['ayah_end']?.toString() ?? '');
          if (aStart != null && aEnd != null && aStart <= safeSAyah && aEnd >= safeSAyah) {
            startRes = Map<String, dynamic>.from(r as Map);
            break;
          }
        }
      }

      if (startRes == null && sSurahRows.isNotEmpty) {
        for (var r in sSurahRows) {
          final int? aStart = int.tryParse(r['ayah_start']?.toString() ?? '');
          final int? aEnd = int.tryParse(r['ayah_end']?.toString() ?? '');

          if (aStart != null && aEnd != null) {
            startRes = Map<String, dynamic>.from(r as Map);
            break;
          }
        }
      }

      final eSurahRows = allRows.where((r) {
        final sNum = int.tryParse(r['surah_number']?.toString() ?? '') ?? 0;
        return sNum == eSurah;
      }).toList();

      eSurahRows.sort((a, b) {
        final kA = int.tryParse(a['koordinat_baris']?.toString() ?? '') ?? 0;
        final kB = int.tryParse(b['koordinat_baris']?.toString() ?? '') ?? 0;
        return kB.compareTo(kA);
      });

      Map<String, dynamic>? endRes;
      for (var r in eSurahRows) {
        final int? aStart = int.tryParse(r['ayah_start']?.toString() ?? '');
        final int? aEnd = int.tryParse(r['ayah_end']?.toString() ?? '');
        if (aStart != null && aEnd != null && aStart <= safeEAyah && aEnd >= safeEAyah) {
          endRes = Map<String, dynamic>.from(r as Map);
          break;
        }
      }

      if (endRes == null && eSurahRows.isNotEmpty) {
        for (var r in eSurahRows) {
          final int? aStart = int.tryParse(r['ayah_start']?.toString() ?? '');
          final int? aEnd = int.tryParse(r['ayah_end']?.toString() ?? '');

          if (aStart != null && aEnd != null) {
            endRes = Map<String, dynamic>.from(r as Map);
            break;
          }
        }
      }

      if (startRes == null || endRes == null) {
        return _emptyResult();
      }

      final int dbStartKoor = int.tryParse(startRes['koordinat_baris']?.toString() ?? '') ?? 0;
      int dbEndKoor = int.tryParse(endRes['koordinat_baris']?.toString() ?? '') ?? 0;

      if (sSurah == eSurah && safeEAyah == 1) {
        if (eSurahRows.isNotEmpty) {
          final int maxSurahKoor = int.tryParse(eSurahRows.first['koordinat_baris']?.toString() ?? '') ?? 0;
          if (maxSurahKoor > dbEndKoor) {
            dbEndKoor = maxSurahKoor;
          }
        }
      }

      final minKoor = dbStartKoor < dbEndKoor ? dbStartKoor : dbEndKoor;
      final maxKoor = dbStartKoor < dbEndKoor ? dbEndKoor : dbStartKoor;

      final List<dynamic> rows = allRows.where((r) {
        final int rowSurah = int.tryParse(r['surah_number']?.toString() ?? '') ?? 0;
        final int? aStart = int.tryParse(r['ayah_start']?.toString() ?? '');
        final int? aEnd = int.tryParse(r['ayah_end']?.toString() ?? '');
        if (aStart == null || aEnd == null) return false;

        if (sSurah == eSurah) {
          return (rowSurah == sSurah && aStart <= safeEAyah && aEnd >= safeSAyah);
        } else {
          if (rowSurah < sSurah || rowSurah > eSurah) return false;
          if (rowSurah == sSurah) return (aEnd >= safeSAyah);
          if (rowSurah == eSurah) return (aStart <= safeEAyah);
          return true;
        }
      }).toList();

      final uniqueKoor = <int>{};
      for (var row in rows) {
        final int koor = int.tryParse(row['koordinat_baris']?.toString() ?? '') ?? 0;
        final int rowSurah = int.tryParse(row['surah_number']?.toString() ?? '') ?? 0;
        final int? aStart = int.tryParse(row['ayah_start']?.toString() ?? '');
        final int? aEnd = int.tryParse(row['ayah_end']?.toString() ?? '');

        if (koor > 0) {
          if (targetUnit == 'SURAH' || (sSurah == eSurah)) {
            if (rowSurah < sSurah || rowSurah > eSurah) continue;
          }

          if (sSurah == 1 && eSurah == 1 && rowSurah == 1 && koor == 102) continue;

          if (aStart != null && aEnd != null) {
            uniqueKoor.add(koor);
          }
        }
      }

      double totalLines = uniqueKoor.length.toDouble();

      final surahsSet = <int>{};
      final juzsSet = <int>{};
      final pagesSet = <int>{};
      final ayahsSet = <int>{};

      for (var row in rows) {
        final int sNum = int.tryParse(row['surah_number']?.toString() ?? '') ?? 0;
        if (sNum > 0) surahsSet.add(sNum);
        final int? jNum = int.tryParse(row['juz_number']?.toString() ?? '');
        if (jNum != null) juzsSet.add(jNum);
        final int? pNum = int.tryParse(row['page_number']?.toString() ?? '');
        if (pNum != null) pagesSet.add(pNum);
        final int? aStart = int.tryParse(row['ayah_start']?.toString() ?? '');
        final int? aEnd = int.tryParse(row['ayah_end']?.toString() ?? '');
        if (aStart != null && aEnd != null) {
          for (int i = aStart; i <= aEnd; i++) {
            if (i > 0) ayahsSet.add((sNum * 10000) + i);
          }
        }
      }

      double volumePages = 0.0;
      double volumeJuz = 0.0;

      final Map<int, Set<int>> pageCoords = {};
      final Map<int, Set<int>> juzCoords = {};

      for (var row in allRows) {
        final koor = int.tryParse(row['koordinat_baris']?.toString() ?? '') ?? 0;
        final int? aStart = int.tryParse(row['ayah_start']?.toString() ?? '');
        final int? aEnd = int.tryParse(row['ayah_end']?.toString() ?? '');

        if (koor > 0 && aStart != null && aEnd != null) {
          final pNum = int.tryParse(row['page_number']?.toString() ?? '') ?? 0;
          final jNum = int.tryParse(row['juz_number']?.toString() ?? '') ?? 0;
          if (pNum > 0) pageCoords.putIfAbsent(pNum, () => {}).add(koor);
          if (jNum > 0) juzCoords.putIfAbsent(jNum, () => {}).add(koor);
        }
      }

      for (final p in pagesSet) {
        final coordsInPage = pageCoords[p] ?? {};
        if (coordsInPage.isNotEmpty) {
          final matched = coordsInPage.where((c) => uniqueKoor.contains(c)).length;
          volumePages += matched / coordsInPage.length;
        }
      }

      for (final j in juzsSet) {
        final coordsInJuz = juzCoords[j] ?? {};
        if (coordsInJuz.isNotEmpty) {
          final matched = coordsInJuz.where((c) => uniqueKoor.contains(c)).length;
          volumeJuz += matched / coordsInJuz.length;
        }
      }

      double achievedVolume = totalLines;
      if (targetUnit == 'HALAMAN') {
        achievedVolume = volumePages;
      } else if (targetUnit == 'JUZ') achievedVolume = volumeJuz;
      else if (targetUnit == 'SURAH') achievedVolume = surahsSet.length.toDouble();
      else if (targetUnit == 'AYAH') achievedVolume = ayahsSet.length.toDouble();

      bool isAchieved = true;
      double deficit = 0;
      if (targetAmount != null && targetAmount > 0) {
        final double totalTarget = targetAmount + previousDebt;
        isAchieved = achievedVolume >= totalTarget;
        deficit = isAchieved ? 0 : (totalTarget - achievedVolume);
      }

      return {
        "calculated_pages": volumePages,
        "calculated_lines": totalLines.toInt(),
        "calculated_ayahs": ayahsSet.length,
        "calculated_surahs": surahsSet.length,
        "calculated_juzs": volumeJuz,
        "calculated_pages_unique": pagesSet.length.toDouble(),
        "achieved_volume": achievedVolume,
        "is_target_met": isAchieved,
        "deficit_value": deficit,
        "mushaf_standard": "Madinah 15 Lines (Spatial Engine)",
      };
    } catch (e) {
      return _emptyResult();
    }
  }

  Map<String, dynamic> _emptyResult() {
    return {
      "calculated_pages": 0.0,
      "calculated_lines": 0,
      "calculated_ayahs": 0,
      "calculated_surahs": 0,
      "calculated_juzs": 0.0,
      "calculated_pages_unique": 0.0,
      "achieved_volume": 0.0,
      "is_target_met": true,
      "deficit_value": 0.0,
    };
  }
}