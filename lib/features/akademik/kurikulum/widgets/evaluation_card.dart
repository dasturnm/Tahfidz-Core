// COPY-SAFE: lib/features/akademik/kurikulum/widgets/evaluation_card.dart
import 'package:flutter/material.dart';
import '../models/kurikulum_model.dart'; // Pastikan import ke file model yang benar

class EvaluationCard extends StatelessWidget {
  final ModulEvaluasiTemplateModel template; // Gunakan model template modul
  final Function(String namaMateri, String indikatorKelulusan) onChanged; // Callback diupdate

  const EvaluationCard({
    super.key,
    required this.template,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              initialValue: template.namaMateri,
              decoration: const InputDecoration(labelText: 'Nama Materi/Aspek', border: OutlineInputBorder()),
              onChanged: (val) => onChanged(val, template.indikatorKelulusan),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: template.indikatorKelulusan,
              decoration: const InputDecoration(labelText: 'Indikator Kelulusan', border: OutlineInputBorder()),
              onChanged: (val) => onChanged(template.namaMateri, val),
            ),
          ],
        ),
      ),
    );
  }
}