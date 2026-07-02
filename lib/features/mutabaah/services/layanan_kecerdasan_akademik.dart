// Lokasi: lib/features/mutabaah/services/layanan_kecerdasan_akademik.dart
part of 'mutabaah_service.dart';

class LayananKecerdasanAkademik {
  final MutabaahTahfidzService _mainService;
  LayananKecerdasanAkademik(this._mainService);

  SupabaseClient get supabase => _mainService.supabase;

  Future<void> _evaluateExamReadiness(String siswaId, String? modulId) async {
    if (modulId == null) return;
    try {
      final modulData = await supabase
          .from('modul_kurikulum')
          .select('*, level:level_id(kurikulum_id, urutan)')
          .eq('id', modulId)
          .single();

      final modul = ModulModel.fromJson(modulData);
      final projection = await getModuleProjection(siswaId, modul);

      if (modul.isCumulativeExam && modul.cumulativeRange > 0) {
        double rangeVol = modul.cumulativeRange.toDouble();
        double currentVol = projection.currentAchieved;

        if (currentVol.floor() >= rangeVol.toInt() && (currentVol.floor() % rangeVol.toInt() == 0)) {
          String targetState = modul.isTasmiRequired ? 'tasmi_mode' : 'exam_ready';
          await supabase.from('siswa').update({
            'is_ready_for_exam': true,
            'ready_modul_id': modulId,
            'academic_state': targetState,
          }).eq('id', siswaId);
          return;
        }
      }

      final recordsResponse = await supabase
          .from('mutabaah_records')
          .select('data_payload, internal_end')
          .match({'siswa_id': siswaId, 'modul_id': modulId})
          .order('created_at', ascending: false);

      final recordsList = recordsResponse as List;
      bool targetPertemuanHabis = recordsList.length >= modul.targetPertemuan;
      bool volumeTercapai = projection.remainingVolume <= 0;

      bool boundaryReached = false;
      if (recordsList.isNotEmpty) {
        final latestRecord = recordsList.first;
        final payload = latestRecord['data_payload'] as Map<String, dynamic>? ?? {};
        final String silabusSource = modulData['silabus_source']?.toString() ?? '';
        final String tipeModul = modulData['tipe']?.toString().toUpperCase() ?? '';

        if (silabusSource == 'internal' || tipeModul == 'INTERNAL' || tipeModul == 'AKADEMIK') {
          int targetEnd = (modulData['akhir_koordinat'] as num?)?.toInt() ?? 0;
          int lastEnd = (latestRecord['internal_end'] as num?)?.toInt() ??
              int.tryParse(payload['halaman_akhir']?.toString() ?? '0') ?? 0;
          boundaryReached = lastEnd >= targetEnd;
        } else {
          int targetSurah = (modulData['surah_akhir'] as num?)?.toInt() ?? (modulData['end_surah'] as num?)?.toInt() ?? 0;
          int targetAyah = (modulData['ayah_akhir'] as num?)?.toInt() ?? (modulData['end_ayah'] as num?)?.toInt() ?? 0;
          int lastSurah = int.tryParse(payload['end_surah']?.toString() ?? '0') ?? 0;
          int lastAyah = int.tryParse(payload['end_ayah']?.toString() ?? '0') ?? 0;
          int startSurah = (modulData['surah_mulai'] as num?)?.toInt() ?? (modulData['start_surah'] as num?)?.toInt() ?? 1;

          if (startSurah > targetSurah) {
            if (lastSurah < targetSurah) {
              boundaryReached = true;
            } else if (lastSurah == targetSurah) {
              boundaryReached = lastAyah >= targetAyah;
            }
          } else {
            if (lastSurah > targetSurah) {
              boundaryReached = true;
            } else if (lastSurah == targetSurah) {
              boundaryReached = lastAyah >= targetAyah;
            }
          }
        }
      }

      // FIX BOUNDARY CHECK: Menggunakan gerbang logika OR agar pencapaian koordinat fisik materi (boundaryReached)
      // atau volume selesai (volumeTercapai) langsung memicu status kelulusan harian menuju mode ujian.
      if (volumeTercapai || targetPertemuanHabis || boundaryReached) {
        String targetState = modul.isTasmiRequired ? 'tasmi_mode' : 'exam_ready';
        await supabase.from('siswa').update({
          'is_ready_for_exam': true,
          'ready_modul_id': modulId,
          'academic_state': targetState,
        }).eq('id', siswaId);
      }
    } catch (e) {
      print("Error _evaluateExamReadiness: $e");
    }
  }

  Future<void> _evaluateStudentPromotion(String siswaId) async {
    try {
      final siswaData = await supabase.from('siswa').select('level_id').eq('id', siswaId).single();
      final currentLevelId = siswaData['level_id'];
      if (currentLevelId == null) return;

      final currentLevelData = await supabase.from('kurikulum_level').select('kurikulum_id, urutan').eq('id', currentLevelId).single();
      final kurikulumId = currentLevelData['kurikulum_id'];
      final currentUrutan = currentLevelData['urutan'];

      final modulsInLevel = await supabase.from('modul_kurikulum').select('id, tipe').eq('level_id', currentLevelId);
      if (modulsInLevel.isEmpty) return;
      final modulIds = (modulsInLevel as List)
          .where((m) => m['tipe']?.toString().trim().toUpperCase() != 'TASMI\'')
          .map((m) => m['id'].toString())
          .toList();

      final passedRecords = await supabase
          .from('mutabaah_records')
          .select('modul_id')
          .match({'siswa_id': siswaId, 'modul_id': modulIds})
          .match({'is_passed_target': true});

      final passedModulIds = (passedRecords as List).map((m) => m['modul_id'].toString()).toSet();

      bool allPassed = true;
      for (var id in modulIds) {
        if (!passedModulIds.contains(id)) {
          allPassed = false;
          break;
        }
      }

      if (allPassed) {
        final nextLevelData = await supabase
            .from('kurikulum_level')
            .select('id')
            .eq('kurikulum_id', kurikulumId)
            .gt('urutan', currentUrutan)
            .order('urutan', ascending: true)
            .limit(1)
            .maybeSingle();

        if (nextLevelData != null) {
          final nextLevelId = nextLevelData['id'];
          await supabase.from('siswa').update({
            'level_id': nextLevelId,
            'current_level_id': nextLevelId,
          }).eq('id', siswaId);
        }
      }
    } catch (e) {
      print("Error Auto-Promotion: $e");
    }
  }

  double calculateTasmiScore(Map<String, dynamic> tasmiSettings, Map<String, dynamic> penaltyCounts, Map<String, double> directScores) {
    double totalScore = 0.0;

    tasmiSettings.forEach((aspect, config) {
      if (config['active'] == true) {
        double bobot = (config['bobot'] as num?)?.toDouble() ?? 0.0;

        if (aspect == 'itqon' || aspect == 'tajwid' || aspect == 'makhraj') {
          double deductions = 0.0;
          if (aspect == 'itqon') {
            int countS = penaltyCounts['itqon_s'] ?? 0;
            int countT = penaltyCounts['itqon_t'] ?? 0;
            int countP = penaltyCounts['itqon_p'] ?? 0;
            deductions += countS * ((config['pinalti_stt'] as num?)?.toDouble() ?? 0.0);
            deductions += countT * ((config['pinalti_t'] as num?)?.toDouble() ?? 0.0);
            deductions += countP * ((config['pinalti_p'] as num?)?.toDouble() ?? 0.0);
          } else if (aspect == 'tajwid' || aspect == 'makhraj') {
            int countK = penaltyCounts['${aspect}_k'] ?? 0;
            int countS = penaltyCounts['${aspect}_s'] ?? 0;
            deductions += countK * ((config['pinalti_kurang'] as num?)?.toDouble() ?? 0.0);
            deductions += countS * ((config['pinalti_salah'] as num?)?.toDouble() ?? 0.0);
          }

          double aspectScore = bobot - deductions;
          if (aspectScore < 0) aspectScore = 0;
          totalScore += aspectScore;
        } else {
          double rawScore = directScores[aspect] ?? 0.0;
          totalScore += (rawScore / 100) * bobot;
        }
      }
    });

    return totalScore;
  }

  Future<MutabaahProjectionModel> getModuleProjection(String siswaId, ModulModel modul) async {
    try {
      final response = await supabase
          .from('mutabaah_records')
          .select('achieved_amount')
          .match({'siswa_id': siswaId, 'modul_id': modul.id!});

      double currentAchieved = 0.0;
      final records = response as List;

      for (var record in records) {
        currentAchieved += (record['achieved_amount'] as num?)?.toDouble() ?? 0.0;
      }

      double totalTarget = modul.targetAmount * modul.targetPertemuan;
      if (modul.totalBaris > 0) {
        if (modul.targetAmountUnit == 'JUZ') {
          totalTarget = modul.totalBaris / 300.0;
        } else if (modul.targetAmountUnit == 'HALAMAN') {
          totalTarget = modul.totalBaris / 15.0;
        } else if (modul.targetAmountUnit == 'SURAH') {
          totalTarget = (modul.totalSurah > 0) ? modul.totalSurah.toDouble() : (modul.totalBaris / 15.0);
        } else if (modul.targetAmountUnit == 'AYAH') {
          totalTarget = (modul.totalBaris > 0) ? totalTarget : 0.0;
        } else {
          totalTarget = modul.totalBaris.toDouble();
        }
      }

      if (totalTarget <= 0) totalTarget = 100.0;

      double remainingVolume = totalTarget - currentAchieved;
      if (remainingVolume < 0) remainingVolume = 0;

      double averageVelocity = modul.targetAmount;
      if (records.isNotEmpty && currentAchieved > 0) {
        averageVelocity = currentAchieved / records.length;
      }
      if (averageVelocity <= 0) averageVelocity = 1.0;

      int estimatedMeetingsLeft = (remainingVolume / averageVelocity).ceil();
      DateTime estimatedCompletionDate = DateTime.now().add(Duration(days: estimatedMeetingsLeft));

      return MutabaahProjectionModel(
        siswaId: siswaId,
        modulId: modul.id!,
        totalTarget: totalTarget,
        currentAchieved: currentAchieved,
        remainingVolume: remainingVolume,
        averageVelocity: averageVelocity,
        estimatedMeetingsLeft: estimatedMeetingsLeft,
        estimatedCompletionDate: estimatedCompletionDate,
        isCompleted: remainingVolume <= 0,
      );
    } catch (e) {
      throw Exception(_mainService.handleError(e));
    }
  }
}