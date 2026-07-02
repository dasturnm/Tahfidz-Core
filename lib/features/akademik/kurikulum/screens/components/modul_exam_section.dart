// Lokasi: lib/features/akademik/kurikulum/screens/components/modul_exam_section.dart
import 'package:flutter/material.dart';
import 'modul_shared_widgets.dart';
// TAMBAHKAN IMPORT widget evaluasi section Anda di sini jika diperlukan, contoh:
// import '../../widgets/modul_evaluasi_section.dart';
import '../../widgets/evaluation_card.dart'; // FIX: Jalur impor diarahkan ke folder widgets tempat asli file berada

class ModulExamSection extends StatelessWidget {
  final bool isExamRequired;
  final String silabusSource;
  final String examType;
  final double examVolume;
  final String examUnit;
  final bool isCumulativeExam;
  final int cumulativeRange;
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
    required this.examType,
    required this.examVolume,
    required this.examUnit,
    required this.isCumulativeExam,
    required this.cumulativeRange,
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
    // Normalisasi string untuk validasi local state widget
    final String currentType = examType.trim().toUpperCase();
    final String safeType = ['TASMI', 'CHECKLIST'].contains(currentType) ? currentType : 'TASMI';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // REVISI: Hapus label duplikat & box switch dari komponen ini karena tombol On/Off sudah berada di judul utama file form screen
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
                ModulSharedWidgets.buildLabel("TIPE UJIAN"),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  // FIX: Menggunakan properti value, bukan initialValue agar reaktif
                  initialValue: safeType,
                  isExpanded: true,
                  decoration: ModulSharedWidgets.inputStyle(""),
                  items: const [
                    DropdownMenuItem(value: 'TASMI', child: Text("Lembaran Evaluasi Silabus Mushaf")),
                    DropdownMenuItem(value: 'CHECKLIST', child: Text("Lembaran Evaluasi Silabus Internal")),
                  ],
                  onChanged: onTypeChanged,
                ),
                const SizedBox(height: 16),

                // TAMBAHAN LOGIKA BYPASS TASMI: Hanya muncul jika tipe TASMI dan silabus berbasis Mushaf
                if (safeType == 'TASMI' && silabusSource == 'mushaf') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Wajib Ujian Tasmi' Kelancaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text("Siswa wajib tasmi' kelancaran sebelum ujian skor formal", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Switch(
                        value: (formNotifier?.state?.modul?.isTasmiRequired ?? false) == true,
                        activeThumbColor: const Color(0xFF10B981),
                        onChanged: (value) {
                          if (formNotifier != null) {
                            formNotifier.updateField(isTasmiRequired: value);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // KONDISI 1: JIKA TIPE TASMI
                if (safeType == 'TASMI') ...[
                  // FIX: Form hanya muncul jika switch Wajib Ujian Tasmi Kelancaran diaktifkan
                  if ((formNotifier?.state?.modul?.isTasmiRequired ?? false) == true) ...[
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
                                onChanged: onVolumeChanged,
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
                                onChanged: onUnitChanged,
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
                        onChanged: onRangeChanged,
                      ),
                    ],
                  ],
                ],

                // KONDISI 2: FIX UNTUK MERENDER LEMBARAN EVALUASI (CHECKLIST)
                if (safeType == 'CHECKLIST') ...[
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
              ],
            ),
          ),
        ],
      ],
    );
  }
}