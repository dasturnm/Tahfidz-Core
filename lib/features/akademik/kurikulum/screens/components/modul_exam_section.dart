// Lokasi: lib/features/akademik/kurikulum/screens/components/modul_exam_section.dart
import 'package:flutter/material.dart';
// TAMBAHKAN IMPORT widget evaluasi section Anda di sini jika diperlukan, contoh:
// import '../../widgets/modul_evaluasi_section.dart';
import '../../widgets/evaluation_card.dart'; // FIX: Jalur impor diarahkan ke folder widgets tempat asli file berada

class ModulExamSection extends StatelessWidget {
  final bool isExamRequired;
  final String silabusSource;
  final String tasmiType;
  final double tasmiVolume;
  final String tasmiUnit;
  final bool isCumulativeTasmi;
  final int tasmiRange;
  final ValueChanged<bool> onRequiredChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String> onVolumeChanged;
  final ValueChanged<String?> onUnitChanged;
  final ValueChanged<bool> onCumulativeChanged;
  final ValueChanged<String> onRangeChanged;

  // Tambahkan parameter template & notifier jika ModulEvaluasiSection membutuhkannya langsung di sini,
  // Atau panggil Widget Evaluasi terpadu Anda. Di sini kita asumsikan widget dipanggil secara modular.
  final List<dynamic>? evaluationTemplates;
  final dynamic formNotifier; // Gunakan tipe controller Anda (ModulFormController)
  final String? lembagaId;

  const ModulExamSection({
    super.key,
    required this.isExamRequired,
    required this.silabusSource,
    required this.tasmiType,
    required this.tasmiVolume,
    required this.tasmiUnit,
    required this.isCumulativeTasmi,
    required this.tasmiRange,
    required this.onRequiredChanged,
    required this.onTypeChanged,
    required this.onVolumeChanged,
    required this.onUnitChanged,
    required this.onCumulativeChanged,
    required this.onRangeChanged,
    this.evaluationTemplates,
    this.formNotifier,
    this.lembagaId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isExamRequired) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                const Divider(height: 24),
                // BUAT KETERANGAN SAAT MEMBUAT LEMBARAN EVALUASI BAHWA PENILAIAN DIBUAT DENGAN SKALA 1-4
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Seluruh aspek kriteria di bawah ini akan diukur menggunakan standar indikator kompetensi skala 1-4 (Belum Layak hingga Sangat Baik) guna memastikan objektivitas evaluasi kelulusan santri.",
                          style: TextStyle(fontSize: 11, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w500, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (evaluationTemplates != null && formNotifier != null) ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: evaluationTemplates!.length,
                    itemBuilder: (context, index) {
                      final template = evaluationTemplates![index];
                      return Dismissible(
                        key: Key(index.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => formNotifier.removeEvaluasiTemplate(index),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: EvaluationCard(
                          template: template,
                          onChanged: (nama, indikatorKelulusan) {
                            formNotifier.updateEvaluasiTemplateItem(index, namaMateri: nama, indikatorKelulusan: indikatorKelulusan);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => formNotifier.addEvaluasiTemplate(lembagaId ?? ''),
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
                      label: const Text(
                        "Tambah Aspek Kriteria",
                        style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}