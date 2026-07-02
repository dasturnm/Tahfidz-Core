// Lokasi: lib/features/mutabaah/screens/components/pilar_input_internal.dart
// ignore_for_file: invalid_use_of_protected_member
part of '../mutabaah_input_screen.dart';

extension PilarInputInternal on _ModulInputScreenState {
  Widget _buildInternalForm(ModulModel modul, Color color) {
    final mId = modul.id!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (modul.isPlottingActive) ...[
          Consumer(
              builder: (context, ref, child) {
                final materiAsync = ref.watch(remainingMateriProvider(MateriFilterParam(siswaId: _currentSiswa.id!, modul: modul)));

                return materiAsync.when(
                  data: (materiList) {
                    final int pertemuanSebelumnya = _pertemuanSebelumnyaMap[mId] ?? 0;
                    if (materiList.isEmpty && pertemuanSebelumnya >= modul.targetPertemuan) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Text("Semua materi di modul ini sudah LULUS!", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      );
                    }

                    final String? selectedAwal = _selectedMateri[mId] != null && materiList.contains(_selectedMateri[mId]) ? _selectedMateri[mId] : null;
                    final String? selectedAkhir = _catatanControllers['${mId}_materi_akhir']?.text != null && materiList.contains(_catatanControllers['${mId}_materi_akhir']!.text) ? _catatanControllers['${mId}_materi_akhir']!.text : null;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("MATERI AWAL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: selectedAwal,
                                        hint: const Text("Pilih...", style: TextStyle(fontSize: 11)),
                                        items: materiList.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 11)))).toList(),
                                        onChanged: (v) {
                                          setState(() {
                                            _selectedMateri[mId] = v;
                                            if (_catatanControllers['${mId}_materi_akhir']?.text == null || _catatanControllers['${mId}_materi_akhir']!.text.isEmpty) {
                                              _catatanControllers['${mId}_materi_akhir']?.text = v ?? '';
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("MATERI AKHIR", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: selectedAkhir,
                                        hint: const Text("Pilih...", style: TextStyle(fontSize: 11)),
                                        items: materiList.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 11)))).toList(),
                                        onChanged: (v) => setState(() => _catatanControllers['${mId}_materi_akhir']?.text = v ?? ''),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2))),
                  error: (err, st) => const Text("Gagal memuat sisa materi", style: TextStyle(color: Colors.red)),
                );
              }
          ),
        ] else ...[
          Row(
              children: [
                Expanded(
                  child: AbsorbPointer(
                    absorbing: true,
                    child: _buildNumberDropdown("HALAMAN AWAL", _halamanAwalControllers[mId]!, modul),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildNumberDropdown("HALAMAN AKHIR", _halamanAkhirControllers[mId]!, modul)),
              ]
          ),
        ],
        const SizedBox(height: 20),
        if (modul.useRatingScale)
          MutabaahRatingPicker(
            currentValue: int.tryParse(_nilaiControllers[mId]!.text) ?? 0,
            onRatingSelected: (val) {
              setState(() {
                _nilaiControllers[mId]!.text = val.toString();
                if (val == 1) _switchStates[mId] = -1;
                if (val >= 2) _switchStates[mId] = 1;
              });
            },
          )
        else
          _pilarInput(label: "NILAI CAPAIAN (0-100)", controller: _nilaiControllers[mId]!, hint: "Evaluasi angka..."),
      ],
    );
  }
}