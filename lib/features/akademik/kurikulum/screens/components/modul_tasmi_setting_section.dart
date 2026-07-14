// Lokasi: lib/features/akademik/kurikulum/screens/components/modul_tasmi_setting_section.dart

import 'package:flutter/material.dart';
import 'modul_shared_widgets.dart';

class ModulTasmiSettingSection extends StatelessWidget {
  final double examVolume;
  final String examUnit;
  final bool isCumulativeExam;
  final int cumulativeRange;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<bool> onCumulativeChanged;
  final ValueChanged<int> onRangeChanged;

  const ModulTasmiSettingSection({
    super.key,
    required this.examVolume,
    required this.examUnit,
    required this.isCumulativeExam,
    required this.cumulativeRange,
    required this.onVolumeChanged,
    required this.onUnitChanged,
    required this.onCumulativeChanged,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModulSharedWidgets.buildLabel("VOLUME UJIAN"),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: examVolume.toString(),
                    keyboardType: TextInputType.number,
                    decoration: ModulSharedWidgets.inputStyle("1.0"),
                    onChanged: (v) {
                      final parsed = double.tryParse(v);
                      if (parsed != null) onVolumeChanged(parsed);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModulSharedWidgets.buildLabel("SATUAN"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: examUnit.trim().toUpperCase().isNotEmpty ? examUnit.trim().toUpperCase() : 'JUZ',
                    decoration: ModulSharedWidgets.inputStyle(""),
                    items: const [
                      DropdownMenuItem(value: 'JUZ', child: Text("Juz")),
                      DropdownMenuItem(value: 'HALAMAN', child: Text("Halaman")),
                    ],
                    onChanged: (v) {
                      if (v != null) onUnitChanged(v);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tasmi' Bertingkat (Kumulatif)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text("Wajib tasmi' gabungan per periode juz", style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Switch(
              value: isCumulativeExam,
              activeThumbColor: const Color(0xFF10B981),
              onChanged: onCumulativeChanged,
            ),
          ],
        ),
        if (isCumulativeExam) ...[
          const SizedBox(height: 8),
          ModulSharedWidgets.buildLabel("KELIPATAN JUZ (MISAL: 5)"),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: cumulativeRange.toString(),
            keyboardType: TextInputType.number,
            decoration: ModulSharedWidgets.inputStyle("5"),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null) onRangeChanged(parsed);
            },
          ),
        ],
      ],
    );
  }
}