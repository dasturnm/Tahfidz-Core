// Lokasi: lib/features/akademik/kurikulum/screens/components/modul_pencapaian_section.dart

import 'package:flutter/material.dart';
import 'modul_shared_widgets.dart';

class ModulPencapaianSection extends StatelessWidget {
  final TextEditingController targetAmountController;
  final String selectedTargetUnit;
  final ValueChanged<String> onUnitChanged;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const ModulPencapaianSection({
    super.key,
    required this.targetAmountController,
    required this.selectedTargetUnit,
    required this.onUnitChanged,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    List<String> unitOptions = ['JUZ', 'SURAH', 'HALAMAN', 'AYAT', 'NOMOR', 'MATERI'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Pencapaian per Pertemuan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModulSharedWidgets.buildLabel("TARGET"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onDecrement,
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: targetAmountController,
                          keyboardType: TextInputType.number,
                          decoration: ModulSharedWidgets.inputStyle("Angka"),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: onIncrement,
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModulSharedWidgets.buildLabel("TIPE TARGET"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: unitOptions.contains(selectedTargetUnit) ? selectedTargetUnit : unitOptions.first,
                    decoration: ModulSharedWidgets.inputStyle("Satuan"),
                    items: unitOptions.map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (v) => onUnitChanged(v!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}