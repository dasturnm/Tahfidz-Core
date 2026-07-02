// Lokasi: lib/features/mutabaah/services/layanan_pemetaan_mushaf.dart
part of 'mutabaah_service.dart';

class LayananPemetaanMushaf {
  final MutabaahTahfidzService _mainService;
  LayananPemetaanMushaf(this._mainService);

  SupabaseClient get supabase => _mainService.supabase;

  Future<Map<String, dynamic>> calculateTahfidzPayload({
    required int surahMulai,
    required int ayahMulai,
    required int surahAkhir,
    required int ayahAkhir,
    double? targetAmount,
    double previousDebt = 0.0,
    String? targetUnit,
  }) async {
    try {
      final calculator = MushafCalculator();
      final result = await calculator.calculateVolume(
        sSurah: surahMulai,
        sAyah: ayahMulai,
        eSurah: surahAkhir,
        eAyah: ayahAkhir,
        targetAmount: targetAmount,
        previousDebt: previousDebt,
        targetUnit: targetUnit,
      );

      final achievedVolume = (result['achieved_volume'] as num?)?.toDouble() ?? 0.0;
      int estimatedMeetings = (targetAmount != null && targetAmount > 0) ? (achievedVolume / targetAmount).ceil() : 0;

      return {
        ...result,
        "start_surah": surahMulai,
        "start_ayah": ayahMulai,
        "end_surah": surahAkhir,
        "end_ayah": ayahAkhir,
        "estimated_meetings": estimatedMeetings,
        "mushaf_standard": "Madinah 15 Lines (Engine-Based)"
      };
    } catch (e) {
      throw Exception(_mainService.handleError(e));
    }
  }

  Future<Map<String, dynamic>> getNextCoordinate(String siswaId, {ModulModel? modul}) async {
    try {
      if (modul != null) {
        final siswaStatus = await supabase
            .from('siswa')
            .select('is_ready_for_exam, ready_modul_id, academic_state')
            .eq('id', siswaId)
            .maybeSingle();

        if (siswaStatus != null &&
            siswaStatus['is_ready_for_exam'] == true &&
            siswaStatus['ready_modul_id']?.toString() == modul.id) {

          final String academicState = siswaStatus['academic_state']?.toString() ?? 'daily';

          return {
            'surah': null,
            'ayah': null,
            'materi': null,
            'pertemuan_selanjutnya': null,
            'status_sebelumnya_ulang': false,
            'is_ready_for_exam': true,
            'academic_state': academicState,
          };
        }
      }

      var query = supabase
          .from('mutabaah_records')
          .select('data_payload, internal_start, internal_end, materi_silabus_aktif, nomor_urut_materi, status_keputusan, ayah_start, surah_id')
          .eq('siswa_id', siswaId);

      if (modul != null) {
        query = query.eq('modul_id', modul.id!);
      }

      final lastRecordData = await query
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (modul != null && (modul.silabusSource == 'internal' || modul.tipe == 'INTERNAL' || modul.tipe == 'AKADEMIK')) {
        if (lastRecordData != null) {
          final payload = lastRecordData['data_payload'] as Map<String, dynamic>? ?? {};
          final int statusKeputusan = (lastRecordData['status_keputusan'] as num?)?.toInt() ?? 0;

          int lastHalamanAwal = (lastRecordData['internal_start'] as num?)?.toInt() ??
              int.tryParse(payload['halaman_awal']?.toString() ?? '0') ?? 0;

          int lastHalamanAkhir = (lastRecordData['internal_end'] as num?)?.toInt() ??
              int.tryParse(payload['halaman_akhir']?.toString() ?? '0') ?? 0;

          String? lastMateri = lastRecordData['materi_silabus_aktif']?.toString() ??
              payload['materi']?.toString();

          int lastNomorUrut = (lastRecordData['nomor_urut_materi'] as num?)?.toInt() ?? 0;

          if (modul.isPlottingActive) {
            final allMateri = modul.extractedMateriList;
            int index = -1;

            if (lastNomorUrut > 0 && lastNomorUrut < allMateri.length) {
              index = lastNomorUrut;
            } else if (lastMateri != null) {
              index = allMateri.indexOf(lastMateri);
            }

            if (statusKeputusan == -1) {
              return {
                'materi': (index != -1 && index < allMateri.length) ? allMateri[index] : lastMateri,
                'materi_sebelumnya': lastMateri,
                'status_sebelumnya_ulang': true,
              };
            }

            if (index != -1 && index + 1 < allMateri.length) {
              return {
                'materi': allMateri[index + 1],
                'materi_sebelumnya': lastMateri,
                'status_sebelumnya_ulang': false,
              };
            } else {
              return {
                'materi': null,
                'materi_sebelumnya': lastMateri,
                'status_sebelumnya_ulang': false,
              };
            }
          } else {
            if (statusKeputusan == -1) {
              return {
                'pertemuan_selanjutnya': lastHalamanAwal > 0 ? lastHalamanAwal : lastHalamanAkhir,
                'pertemuan_sebelumnya': lastHalamanAkhir,
                'status_sebelumnya_ulang': true,
              };
            }

            return {
              'pertemuan_selanjutnya': lastHalamanAkhir + 1,
              'pertemuan_sebelumnya': lastHalamanAkhir,
              'status_sebelumnya_ulang': false,
            };
          }
        }
        if (modul.isPlottingActive) {
          final allMateri = modul.extractedMateriList;
          return {
            'materi': allMateri.isNotEmpty ? allMateri.first : null,
            'materi_sebelumnya': null,
          };
        } else {
          return {
            'pertemuan_selanjutnya': 1,
            'pertemuan_sebelumnya': null,
          };
        }
      }

      bool isBackward = false;

      if (lastRecordData != null) {
        final payload = lastRecordData['data_payload'] as Map<String, dynamic>? ?? {};
        final int statusKeputusan = (lastRecordData['status_keputusan'] as num?)?.toInt() ?? 0;

        int startSurah = int.tryParse(payload['start_surah']?.toString() ?? '1') ?? 1;
        int endSurah = int.tryParse(payload['end_surah']?.toString() ?? '1') ?? 1;
        int endAyah = int.tryParse(payload['end_ayah']?.toString() ?? '1') ?? 1;

        if (statusKeputusan == -1) {
          int lastStartAyah = (lastRecordData['ayah_start'] as num?)?.toInt() ??
              int.tryParse(payload['start_ayah']?.toString() ?? '1') ?? 1;
          int lastStartSurah = (lastRecordData['surah_id'] as num?)?.toInt() ?? startSurah;

          return {
            'surah': lastStartSurah,
            'ayah': lastStartAyah,
            'status_sebelumnya_ulang': true,
          };
        }

        if (startSurah > endSurah) isBackward = true;

        final String jsonContent = await rootBundle.loadString('assets/mushaf_peta.json');
        final List<dynamic> localRows = json.decode(jsonContent) as List<dynamic>;
        final surahRows = localRows.where((r) => (int.tryParse(r['surah_number']?.toString() ?? '') ?? 0) == endSurah).toList();

        int maxayah = 286;
        if (surahRows.isNotEmpty) {
          surahRows.sort((a, b) => (int.tryParse(b['ayah_end']?.toString() ?? '') ?? 0).compareTo(int.tryParse(a['ayah_end']?.toString() ?? '') ?? 0));
          maxayah = int.tryParse(surahRows.first['ayah_end']?.toString() ?? '') ?? 286;
        }

        if (isBackward) {
          if (endAyah < maxayah) {
            return {'surah': endSurah, 'ayah': endAyah + 1};
          } else {
            int nextSurah = endSurah > 1 ? endSurah - 1 : 114;
            return {'surah': nextSurah, 'ayah': 1};
          }
        } else {
          if (endAyah < maxayah) {
            return {'surah': endSurah, 'ayah': endAyah + 1};
          } else {
            int nextSurah = endSurah < 114 ? endSurah + 1 : 1;
            return {'surah': nextSurah, 'ayah': 1};
          }
        }
      } else {
        return {'surah': 1, 'ayah': 1};
      }
    } catch (e) {
      return {'surah': 1, 'ayah': 1};
    }
  }

  String convertLinesToHumanReadable(int totalLines) {
    if (totalLines < 15) {
      return "$totalLines Baris";
    }
    int pages = totalLines ~/ 15;
    int remainingLines = totalLines % 15;

    if (remainingLines == 0) {
      return "$pages Halaman";
    } else {
      return "$pages Halaman $remainingLines Baris";
    }
  }

  Future<double> getLatestDebt(String siswaId, String modulId) async {
    try {
      final response = await supabase
          .from('mutabaah_records')
          .select('debt_created')
          .match({'siswa_id': siswaId, 'modul_id': modulId})
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return 0.0;
      return (response['debt_created'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> getSurahList() async {
    try {
      final String jsonContent = await rootBundle.loadString('assets/mushaf_peta.json');
      final List<dynamic> localRows = json.decode(jsonContent) as List<dynamic>;

      final Map<int, Map<String, dynamic>> surahMap = {};
      for (var item in localRows) {
        final sNum = int.tryParse(item['surah_number']?.toString() ?? '') ?? 0;
        if (sNum > 0 && !surahMap.containsKey(sNum)) {
          surahMap[sNum] = {
            'surah_number': sNum,
            'surah_name': item['surah_name'] ?? '',
          };
        }
      }

      final result = surahMap.values.toList();
      result.sort((a, b) => (a['surah_number'] as int).compareTo(b['surah_number'] as int));
      return result;
    } catch (e) {
      throw Exception(_mainService.handleError(e));
    }
  }

  Future<List<String>> getRemainingMateri(String siswaId, ModulModel modul) async {
    try {
      if (modul.silabusSource != 'internal' && modul.tipe != 'INTERNAL') return [];

      final response = await supabase
          .from('mutabaah_records')
          .select('data_payload, status_keputusan, is_passed_target')
          .eq('siswa_id', siswaId)
          .eq('modul_id', modul.id!)
          .order('created_at', ascending: false);

      final Set<String> passedMateri = {};
      final Set<String> processedMateri = {};

      for (var record in (response as List)) {
        final payload = record['data_payload'] as Map<String, dynamic>?;
        final int statusKeputusan = (record['status_keputusan'] as num?)?.toInt() ?? 0;
        final bool isPassed = record['is_passed_target'] ?? false;

        if (payload != null && payload.containsKey('materi')) {
          final String materiName = payload['materi'].toString();

          if (!processedMateri.contains(materiName)) {
            processedMateri.add(materiName);

            if (statusKeputusan == 1 || isPassed) {
              passedMateri.add(materiName);
            }
          }
        }
      }

      final allMateri = modul.extractedMateriList;
      return allMateri.where((m) => !passedMateri.contains(m)).toList();
    } catch (e) {
      return modul.extractedMateriList;
    }
  }
}