// Lokasi: lib/features/akademik/evaluasi/widgets/sertifikasi_rubric_widget.dart

import 'package:flutter/material.dart';

class SertifikasiRubricWidget extends StatefulWidget {
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onChanged;
  final bool isStandalone; // true = mode mandiri (sertifikasi), false = terikat modul

  const SertifikasiRubricWidget({
    super.key,
    required this.settings,
    required this.onChanged,
    this.isStandalone = false,
  });

  @override
  State<SertifikasiRubricWidget> createState() => _SertifikasiRubricWidgetState();
}

class _SertifikasiRubricWidgetState extends State<SertifikasiRubricWidget> {
  bool _showInstructions = false;

  double _calculateTotalBobot() {
    double total = 0;
    widget.settings.forEach((key, value) {
      if (value is Map && value['active'] == true) {
        total += (value['bobot'] as num?)?.toDouble() ?? 0.0;
      }
    });
    return total;
  }

  void _updateSetting(String aspect, String field, dynamic value) {
    final newSettings = Map<String, dynamic>.from(widget.settings);
    if (!newSettings.containsKey(aspect) || newSettings[aspect] is! Map) {
      newSettings[aspect] = {'active': true, 'bobot': 0.0};
    }
    newSettings[aspect][field] = value;
    widget.onChanged(newSettings);
  }

  void _addCustomAspect({bool isDeductive = false}) {
    final newSettings = Map<String, dynamic>.from(widget.settings);
    int index = 1;
    while (newSettings.containsKey('custom_${isDeductive ? "deductive_" : ""}$index')) {
      index++;
    }
    newSettings['custom_${isDeductive ? "deductive_" : ""}$index'] = {
      'active': true,
      'bobot': 0.0,
      'is_custom': true,
      'is_deductive': isDeductive,
      'name': 'Aspek Baru $index'
    };
    widget.onChanged(newSettings);
  }

  void _removeCustomAspect(String aspectKey) {
    widget.onChanged({aspectKey: null});
  }

  @override
  Widget build(BuildContext context) {
    final double totalBobot = _calculateTotalBobot();
    final bool isBobotValid = totalBobot == 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                "PENGATURAN GRADASI NILAI",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isBobotValid ? const Color(0xFF10B981) : Colors.red[600],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Total Bobot: ${totalBobot.toStringAsFixed(1)}%",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
        if (!isBobotValid)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Total bobot wajib berjumlah 100%. Silakan sesuaikan.",
              style: TextStyle(fontSize: 11, color: Colors.red[800], fontWeight: FontWeight.bold),
            ),
          ),

        const SizedBox(height: 16),
        _buildInstructionsPanel(),
        const SizedBox(height: 24),

        // KATEGORI A: DEDUKTIF (PINALTI)
        const Text(
          "KATEGORI A: PENGURANGAN NILAI (DEDUKTIF)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey),
        ),
        const SizedBox(height: 12),
        _buildAspectCard('itqon', "Kelancaran (Itqon)", isDeductive: true,
            inputs: [
              _buildInput('itqon', 'bobot', "Bobot %"),
              _buildInput('itqon', 'pinalti_stt', "S (-)"),
              _buildInput('itqon', 'pinalti_t', "T (-)"),
              _buildInput('itqon', 'pinalti_p', "P (-)"),
            ]),
        _buildAspectCard('tajwid', "Tajwid", isDeductive: true,
            inputs: [
              _buildInput('tajwid', 'bobot', "Bobot %"),
              _buildInput('tajwid', 'pinalti_kurang', "K (-)"),
              _buildInput('tajwid', 'pinalti_salah', "S (-)"),
            ]),
        _buildAspectCard('makhraj', "Makhraj Al-Huruf", isDeductive: true,
            inputs: [
              _buildInput('makhraj', 'bobot', "Bobot %"),
              _buildInput('makhraj', 'pinalti_kurang', "K (-)"),
              _buildInput('makhraj', 'pinalti_salah', "S (-)"),
            ]),

        // Custom Deductive Aspects (Kategori A)
        ...widget.settings.entries.where((e) => e.value is Map && e.value['is_custom'] == true && e.value['is_deductive'] == true).map((e) {
          return _buildAspectCard(e.key, e.value['name'] ?? "Aspek Custom", isDeductive: true, isCustom: true,
              inputs: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: e.value['name'],
                        decoration: const InputDecoration(labelText: "Nama Aspek", border: OutlineInputBorder(), isDense: true),
                        onChanged: (v) => _updateSetting(e.key, 'name', v),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInput(e.key, 'bobot', "Bobot %"),
                          _buildInput(e.key, 'pinalti_kurang', "K (-)"),
                          _buildInput(e.key, 'pinalti_salah', "S (-)"),
                        ],
                      ),
                    ],
                  ),
                ),
              ]);
        }),

        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _addCustomAspect(isDeductive: true),
          icon: const Icon(Icons.add),
          label: const Text("Tambah Aspek Penilaian (Deduktif)"),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF10B981),
            side: const BorderSide(color: Color(0xFF10B981)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 24),

        // KATEGORI B: KOMULATIF (SKOR LANGSUNG)
        const Text(
          "KATEGORI B: SKOR LANGSUNG (KOMULATIF)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey),
        ),
        const SizedBox(height: 12),
        _buildAspectCard('nada', "Nada / Irama", isDeductive: false, inputs: [_buildInput('nada', 'bobot', "Bobot %")]),
        _buildAspectCard('adab', "Adab Tilawah", isDeductive: false, inputs: [_buildInput('adab', 'bobot', "Bobot %")]),

        // Custom Aspects (Komulatif)
        ...widget.settings.entries.where((e) => e.value is Map && e.value['is_custom'] == true && e.value['is_deductive'] != true).map((e) {
          return _buildAspectCard(e.key, e.value['name'] ?? "Aspek Custom", isDeductive: false, isCustom: true,
              inputs: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: e.value['name'],
                    decoration: const InputDecoration(labelText: "Nama Aspek", border: OutlineInputBorder(), isDense: true),
                    onChanged: (v) => _updateSetting(e.key, 'name', v),
                  ),
                ),
                const SizedBox(width: 8),
                _buildInput(e.key, 'bobot', "Bobot %"),
              ]);
        }),

        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _addCustomAspect(isDeductive: false),
          icon: const Icon(Icons.add),
          label: const Text("Tambah Aspek Penilaian"),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF10B981),
            side: const BorderSide(color: Color(0xFF10B981)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _showInstructions = !_showInstructions),
            leading: const Icon(Icons.menu_book_rounded, color: Colors.blue),
            title: Text(
              widget.isStandalone
                  ? "Panduan Sertifikasi Mandiri"
                  : (widget.settings['silabus_source'] == 'internal'
                  ? "Panduan Lembaran Evaluasi Silabus Internal"
                  : "Panduan Lembaran Evaluasi Silabus Mushaf"),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            trailing: Icon(_showInstructions ? Icons.expand_less : Icons.expand_more, color: Colors.blue),
          ),
          if (_showInstructions)
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.black12),
                  Text("• S (Saktah/Tanbih): Salah Ringan/Tanpa Teguran (Santri sadar sendiri atau diingatkan pelan).", style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  SizedBox(height: 4),
                  Text("• T (Tawaquf): Salah Sedang/Dengan Teguran (Santri terhenti dan butuh pancingan kata).", style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  SizedBox(height: 4),
                  Text("• P (Fath/Talqin): Salah Berat/Dipandu (Santri tidak bisa lanjut dan harus dibacakan ayahnya/pindah).", style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  SizedBox(height: 8),
                  Text("• K (Kurang Tepat): Kesalahan minor pada panjang pendek atau makhraj ringan.", style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  SizedBox(height: 4),
                  Text("• S (Salah): Kesalahan fatal yang mengubah arti (Lahn Jali).", style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAspectCard(String key, String title, {required bool isDeductive, required List<Widget> inputs, bool isCustom = false}) {
    final rawData = widget.settings[key];
    final data = rawData is Map ? rawData : {'active': false};
    final bool isActive = data['active'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey[100],
        border: Border.all(color: isActive ? Colors.grey[300]! : Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isActive ? Colors.black87 : Colors.grey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCustom)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _removeCustomAspect(key),
                  ),
                Switch(
                  value: isActive,
                  activeThumbColor: const Color(0xFF10B981),
                  onChanged: (v) => _updateSetting(key, 'active', v),
                ),
              ],
            ),
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(children: inputs),
            ),
        ],
      ),
    );
  }

  Widget _buildInput(String catKey, String fieldKey, String label) {
    final rawData = widget.settings[catKey];
    final data = rawData is Map ? rawData : {};
    final value = data[fieldKey] ?? 0.0;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: TextFormField(
          initialValue: value.toString(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 11),
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          ),
          onChanged: (v) => _updateSetting(catKey, fieldKey, double.tryParse(v) ?? 0.0),
        ),
      ),
    );
  }
}