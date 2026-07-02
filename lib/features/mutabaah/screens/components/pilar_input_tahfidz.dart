// Lokasi: lib/features/mutabaah/screens/components/pilar_input_tahfidz.dart
// ignore_for_file: invalid_use_of_protected_member
part of '../mutabaah_input_screen.dart';

extension PilarInputTahfidz on _ModulInputScreenState {
  Widget _buildTahfidzForm(ModulModel modul, Color color) {
    final mId = modul.id!;
    final bool isBelow = !(_targetsMetMap[mId] ?? true) && (_totalTargetsMap[mId] ?? 0) > 0;

    return Column(
      children: [
        if (modul.isAccumulated && (_debtsMap[mId] ?? 0) > 0)
          _infoBox("Hutang: ${(_debtsMap[mId] ?? 0).toInt()} ${modul.targetAmountUnit}", Colors.red),

        AbsorbPointer(
          absorbing: true,
          child: MutabaahSurahAyahPicker(modul: modul, label: "DARI", surahValue: _startSurah[mId], ayahValue: _startAyahs[mId], surahList: _surahList, onUpdate: (s, a) {
            setState(() {
              _startSurah[mId] = s;
              _startAyahs[mId] = a;
              if (s != null && a != null && (_endSurah[mId] == null || _endSurah[mId]! < s || (_endSurah[mId] == s && (_endAyahs[mId] == null || _endAyahs[mId]! < a)))) {
                _endSurah[mId] = s;
                _endAyahs[mId] = a;
              }
            });
            _calculateProgress(modul);
          }),
        ),
        const SizedBox(height: 12),
        MutabaahSurahAyahPicker(modul: modul, label: "SAMPAI", surahValue: _endSurah[mId], ayahValue: _endAyahs[mId], surahList: _surahList, onUpdate: (s, a) {
          setState(() { _endSurah[mId] = s; _endAyahs[mId] = a; }); _calculateProgress(modul);
        }),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: isBelow ? Colors.orange.withOpacity(0.05) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Ringkasan Capaian Setoran:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
                  if (!(_loadingMap[mId] ?? false))
                    Text(
                        "Setara ~${(_pagesMap[mId] ?? 0.0).toStringAsFixed(1)} Hal",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)
                    ),
                ],
              ),
              const SizedBox(height: 12),
              (_loadingMap[mId] ?? false)
                  ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))))
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItemMutabaah("Juz", (_juzsMap[mId] ?? 0.0).toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), ""), color, isBelow),
                  _summaryItemMutabaah("Hal", (_pagesMap[mId] ?? 0.0).toStringAsFixed(1).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), ""), color, isBelow),
                  _summaryItemMutabaah("Surah", (_surahsMap[mId] ?? 0.0).toInt().toString(), color, isBelow),
                  _summaryItemMutabaah("Baris", (_linesMap[mId] ?? 0.0).toInt().toString(), color, isBelow),
                ],
              ),
            ],
          ),
        ),
        if (modul.tipe == 'MUROJAAH') ...[
          const SizedBox(height: 20),
          if (modul.showSabqiInMutabaah) ...[
            _pilarInput(label: "SABQI", controller: _sabqiControllers[mId]!, hint: "Halaman disetor..."),
            const SizedBox(height: 12),
          ],
          _pilarInput(label: "MANZIL", controller: _manzilControllers[mId]!, hint: "Realisasi hari ini..."),
        ],
        if (modul.useRatingScale) ...[
          const SizedBox(height: 20),
          MutabaahRatingPicker(
            currentValue: int.tryParse(_nilaiControllers[mId]!.text) ?? 0,
            onRatingSelected: (val) {
              setState(() {
                _nilaiControllers[mId]!.text = val.toString();
                if (val == 1) _switchStates[mId] = -1;
                if (val >= 2) _switchStates[mId] = 1;
              });
            },
          ),
        ],
      ],
    );
  }
}