// Lokasi: lib/features/mutabaah/screens/components/pengontrol_input_mutabaah.dart
// ignore_for_file: invalid_use_of_protected_member
part of '../mutabaah_input_screen.dart';

extension PengontrolInputMutabaah on _ModulInputScreenState {
  Future<void> _loadModulSpecificData(ModulModel modul) async {
    final mId = modul.id!;
    final debt = await MutabaahTahfidzService().getLatestDebt(_currentSiswa.id!, mId);
    final nextCoord = await MutabaahTahfidzService().getNextCoordinate(_currentSiswa.id!, modul: modul);

    if (mounted) {
      setState(() {
        _debtsMap[mId] = debt;
        _totalTargetsMap[mId] = modul.targetAmount + (modul.isAccumulated ? debt : 0.0);

        _catatanControllers['${mId}_is_ulang_prev'] = TextEditingController(
            text: (nextCoord['status_sebelumnya_ulang'] == true).toString()
        );

        if (modul.silabusSource == 'internal' || modul.tipe == 'INTERNAL' || modul.tipe == 'AKADEMIK') {
          _pertemuanSebelumnyaMap[mId] = nextCoord['pertemuan_sebelumnya'];
          _materiSebelumnyaMap[mId] = nextCoord['materi_sebelumnya'];
          _modulCompleted[mId] = nextCoord['is_completed'] ?? false;

          if (modul.isPlottingActive) {
            _selectedMateri[mId] = nextCoord['materi'];
            _catatanControllers['${mId}_materi_akhir'] = TextEditingController(text: nextCoord['materi'] ?? '');
          } else {
            final String initialPage = nextCoord['pertemuan_selanjutnya']?.toString() ?? '1';
            _halamanAwalControllers[mId]?.text = initialPage;
            _halamanAkhirControllers[mId]?.text = initialPage;
          }
        } else {
          _startSurah[mId] = nextCoord['surah'];
          _startAyahs[mId] = nextCoord['ayah'];
          _endSurah[mId] = nextCoord['surah'];
          _endAyahs[mId] = nextCoord['ayah'];
        }
      });
      _calculateProgress(modul);
    }
  }

  Future<void> _fetchSurah() async {
    try {
      final data = await ref.read(mutabaahServiceProvider).getSurahList();
      const totalAyahs = [0, 7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6];

      final enrichedData = data.map((e) {
        int sNum = e['surah_number'] as int;
        return {
          'id': sNum,
          'name_id': e['surah_name'],
          'total_ayah': sNum >= 1 && sNum <= 114 ? totalAyahs[sNum] : 286,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _surahList = enrichedData;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching surah: $e");
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  void _calculateProgress(ModulModel modul) async {
    final mId = modul.id!;
    setState(() => _loadingMap[mId] = true);
    try {
      final String tipe = modul.tipe.trim().toUpperCase();
      if (modul.silabusSource == 'internal' || tipe == 'INTERNAL' || tipe == 'AKADEMIK') {
        final intStart = int.tryParse(_halamanAwalControllers[mId]?.text ?? '0') ?? 0;
        final intEnd = int.tryParse(_halamanAkhirControllers[mId]?.text ?? '0') ?? 0;
        final double vol = (intEnd >= intStart) ? (intEnd - intStart + 1).toDouble() : 0.0;
        if (mounted) setState(() { _pagesMap[mId] = vol; _targetsMetMap[mId] = (vol >= modul.targetAmount); });
      } else {
        if (_startSurah[mId] == null || _startAyahs[mId] == null || _endSurah[mId] == null || _endAyahs[mId] == null) return;
        final calculator = MushafCalculator();
        final result = await calculator.calculateVolume(
          sSurah: _startSurah[mId]!,
          sAyah: _startAyahs[mId]!,
          eSurah: _endSurah[mId]!,
          eAyah: _endAyahs[mId]!,
          targetAmount: modul.targetAmount,
          previousDebt: modul.isAccumulated ? (_debtsMap[mId] ?? 0.0) : 0.0,
          targetUnit: modul.targetAmountUnit,
        );

        if (mounted) {
          setState(() {
            _endSurah[mId] = _endSurah[mId]; // Explicit state sync
            _pagesMap[mId] = (result['calculated_pages'] as num?)?.toDouble() ?? 0.0;
            _linesMap[mId] = (result['calculated_lines'] as num?)?.toDouble() ?? 0.0;
            _ayahsMap[mId] = (result['calculated_ayahs'] as num?)?.toDouble() ?? 0.0;
            _surahsMap[mId] = (result['calculated_surahs'] as num?)?.toDouble() ?? 0.0;
            _juzsMap[mId] = (result['calculated_juzs'] as num?)?.toDouble() ?? 0.0;
            _pagesUniqueMap[mId] = (result['calculated_pages_unique'] as num?)?.toDouble() ?? 0.0;
            _targetsMetMap[mId] = result['is_target_met'] ?? true;
          });
        }
      }
    } catch (e) { debugPrint("Error: $e"); } finally {
      if (mounted) setState(() => _loadingMap[mId] = false);
    }
  }

  void _submitDataBatch() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    List<MutabaahRecord> batchRecords = [];

    for (var modul in widget.activeModuls) {
      final mId = modul.id!;
      final isExamReady = modul.isExamRequired && _currentSiswa.isReadyForExam && _currentSiswa.readyModulId == mId;
      if (isExamReady) continue;

      final String tipe = modul.tipe.trim().toUpperCase();
      final isQuranic = !['INTERNAL', 'AKADEMIK'].contains(tipe) &&
          ['ZIYADAH HAFALAN', 'ZIYADAH TILAWAH', 'MUROJAAH', 'HAFALAN', 'TILAWAH', 'TASMI\''].contains(tipe);

      Map<String, dynamic> payload = {};
      double achieved = 0.0;
      double deficit = 0.0;

      int sId = 0;
      int aStart = 0;
      int aEnd = 0;
      int tBaris = 0;
      double sabqiReal = 0.0;

      int intStart = 0;
      int intEnd = 0;
      String? matSilabus;
      int numUrut = 0;

      if (modul.silabusSource == 'internal' || tipe == 'INTERNAL') {
        achieved = double.tryParse(_nilaiControllers[mId]!.text) ?? 0.0;

        if (modul.useRatingScale && achieved == 0.0) {
          if (_switchStates[mId] == -1) achieved = 1.0;
          if (_switchStates[mId] == 1) achieved = 3.0;
        }

        if (modul.isPlottingActive) {
          final String? matAwal = _selectedMateri[mId];
          final String matAkhir = _catatanControllers['${mId}_materi_akhir']?.text ?? '';
          final allMateri = modul.extractedMateriList;

          int indexAwal = (matAwal != null) ? allMateri.indexOf(matAwal) : -1;
          int indexAkhir = (matAkhir.isNotEmpty) ? allMateri.indexOf(matAkhir) : -1;

          if (indexAwal != -1 && indexAkhir != -1 && indexAkhir >= indexAwal) {
            for (int i = indexAwal; i <= indexAkhir; i++) {
              final currentMateri = allMateri[i];
              final localPayload = {
                "nilai": achieved,
                "materi": currentMateri,
                "materi_akhir": matAkhir,
                "status_kedisiplinan": _switchStates[mId],
              };

              batchRecords.add(MutabaahRecord(
                siswaId: _currentSiswa.id!, guruId: currentUser.id,
                modulId: mId, tipeModul: modul.tipe, dataPayload: localPayload,
                achievedAmount: achieved, debtCreated: 0.0,
                isPassedTarget: _switchStates[mId] == 1,
                catatan: _catatanControllers[mId]!.text, createdAt: DateTime.now(),
                surahId: sId, ayahStart: aStart, ayahEnd: aEnd, totalBaris: tBaris,
                targetSnapshot: _totalTargetsMap[mId] ?? 0.0, sabqiAmount: sabqiReal,
                internalStart: intStart, internalEnd: intEnd,
                materiSilabusAktif: currentMateri,
                nomorUrutMateri: i,
                statusKeputusan: _switchStates[mId] ?? 0,
              ));
            }
          } else {
            matSilabus = matAwal;
            if (matSilabus != null && allMateri.contains(matSilabus)) {
              numUrut = allMateri.indexOf(matSilabus);
            }
            payload = {
              "nilai": achieved,
              "materi": matSilabus ?? '',
              "materi_akhir": matAkhir,
              "status_kedisiplinan": _switchStates[mId],
            };
            batchRecords.add(MutabaahRecord(
              siswaId: _currentSiswa.id!, guruId: currentUser.id,
              modulId: mId, tipeModul: modul.tipe, dataPayload: payload,
              achievedAmount: achieved, debtCreated: 0.0,
              isPassedTarget: _switchStates[mId] == 1,
              catatan: _catatanControllers[mId]!.text, createdAt: DateTime.now(),
              surahId: sId, ayahStart: aStart, ayahEnd: aEnd, totalBaris: tBaris,
              targetSnapshot: _totalTargetsMap[mId] ?? 0.0, sabqiAmount: sabqiReal,
              internalStart: intStart, internalEnd: intEnd,
              materiSilabusAktif: matSilabus, nomorUrutMateri: numUrut,
              statusKeputusan: _switchStates[mId] ?? 0,
            ));
          }
          continue;
        } else {
          intStart = int.tryParse(_halamanAwalControllers[mId]!.text) ?? 0;
          intEnd = int.tryParse(_halamanAkhirControllers[mId]!.text) ?? 0;
          payload = {
            "nilai": achieved,
            "halaman_awal": intStart.toDouble(),
            "halaman_akhir": intEnd.toDouble(),
          };
        }
      } else if (isQuranic) {
        if (_startSurah[mId] == null || _endSurah[mId] == null) continue;

        sId = _startSurah[mId]!;
        aStart = _startAyahs[mId] ?? 0;
        aEnd = _endAyahs[mId] ?? 0;
        tBaris = (_linesMap[mId] ?? 0.0).toInt();
        sabqiReal = double.tryParse(_sabqiControllers[mId]!.text) ?? 0.0;

        achieved = modul.targetAmountUnit == 'HALAMAN' ? (_pagesMap[mId] ?? 0.0) :
        modul.targetAmountUnit == 'JUZ' ? (_juzsMap[mId] ?? 0.0) :
        modul.targetAmountUnit == 'SURAH' ? (_surahsMap[mId] ?? 0.0) : (_linesMap[mId] ?? 0.0);

        deficit = (_totalTargetsMap[mId] ?? 0.0) - achieved;

        payload = {
          "start_surah": _startSurah[mId], "start_ayah": _startAyahs[mId],
          "end_surah": _endSurah[mId], "end_ayah": _endAyahs[mId],
          "calculated_pages": _pagesMap[mId],
          "calculated_lines": _linesMap[mId],
          "calculated_juzs": _juzsMap[mId],
          "calculated_surahs": _surahsMap[mId],
          "target_unit_at_time": modul.targetAmountUnit,
          "sabqi_realisasi": sabqiReal,
        };
      } else {
        achieved = double.tryParse(_nilaiControllers[modul.id!]!.text) ?? 0.0;
        payload = {"nilai": achieved};
      }

      payload['status_kedisiplinan'] = _switchStates[mId];

      batchRecords.add(MutabaahRecord(
        siswaId: _currentSiswa.id!, guruId: currentUser.id,
        modulId: mId, tipeModul: modul.tipe, dataPayload: payload,
        achievedAmount: achieved, debtCreated: modul.isAccumulated ? (deficit > 0 ? deficit : 0.0) : 0.0,
        isPassedTarget: _switchStates[mId] == 1,
        catatan: _catatanControllers[mId]!.text, createdAt: DateTime.now(),
        surahId: sId,
        ayahStart: aStart,
        ayahEnd: aEnd,
        endSurahId: isQuranic ? (_endSurah[mId] ?? 0) : 0,
        totalBaris: tBaris,
        targetSnapshot: _totalTargetsMap[mId] ?? 0.0,
        sabqiAmount: sabqiReal,
        internalStart: intStart,
        internalEnd: intEnd,
        materiSilabusAktif: matSilabus,
        nomorUrutMateri: numUrut,
        statusKeputusan: _switchStates[mId] ?? 0,
      ));
    }

    if (batchRecords.isNotEmpty) {
      await ref.read(mutabaahProvider.notifier).submitBatchRecords(batchRecords);

      try {
        final updatedSiswaData = await _supabase
            .from('siswa')
            .select()
            .eq('id', _currentSiswa.id!)
            .single();

        if (mounted) {
          setState(() {
            _currentSiswa = SiswaModel.fromJson(updatedSiswaData);
          });
        }
      } catch (e) {
        debugPrint("Gagal sinkronisasi data siswa terbaru: $e");
      }

      if (mounted) Navigator.pop(context);
    }
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(fontSize: 13)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("MENGERTI", style: TextStyle(color: Color(0xFF10B981)))),
        ],
      ),
    );
  }

  Widget _buildNumberDropdown(String label, TextEditingController controller, ModulModel modul) {
    final mId = modul.id!;
    int max = (modul.targetPertemuan > 0) ? modul.targetPertemuan : 100;
    int startNumber = 1;

    if (label == "HALAMAN AKHIR") {
      startNumber = int.tryParse(_halamanAwalControllers[mId]!.text) ?? 1;
    } else if (modul.silabusContent.isNotEmpty) {
      // LOGIKA INDEX-BASED: Mengambil index materi selanjutnya dari silabusContent
      int lastIdx = (_pertemuanSebelumnyaMap[mId] ?? -1);
      final bool isPreviousUlang = _catatanControllers['${mId}_is_ulang_prev']?.text == 'true';
      int nextIdx = isPreviousUlang ? lastIdx : (lastIdx + 1);

      // Proteksi agar tidak melebihi panjang silabus
      startNumber = (nextIdx >= modul.silabusContent.length) ? modul.silabusContent.length : (nextIdx + 1);
      max = modul.silabusContent.length;
    } else {
      // Tentukan batas maksimal berdasarkan total baris/fisik, bukan targetPertemuan (administratif)
      if (modul.totalBaris > 0) {
        max = modul.totalBaris;
      }
      // Jika totalBaris masih 0, gunakan targetPertemuan atau 100 (fallback tetap di atas)

      if (_pertemuanSebelumnyaMap[mId] != null) {
        final bool isPreviousUlang = _catatanControllers['${mId}_is_ulang_prev']?.text == 'true';
        startNumber = isPreviousUlang ? _pertemuanSebelumnyaMap[mId]! : _pertemuanSebelumnyaMap[mId]! + 1;
      } else {
        startNumber = 1;
      }
    }

    final List<String> numbers = startNumber <= max
        ? List.generate(max - startNumber + 1, (i) => (startNumber + i).toString())
        : [startNumber.toString()];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        initialValue: numbers.contains(controller.text) ? controller.text : (numbers.isNotEmpty ? numbers.first : null),
        isExpanded: true,
        items: numbers.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
        onChanged: (v) {
          setState(() {
            controller.text = v ?? '';
            if (label == "HALAMAN AWAL") {
              _halamanAkhirControllers[mId]!.text = v ?? '';
            }
          });
        },
        decoration: const InputDecoration(
            filled: true, fillColor: Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none)
        ),
      )
    ]);
  }
}