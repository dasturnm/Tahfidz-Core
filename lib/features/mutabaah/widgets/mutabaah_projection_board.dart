// Lokasi: lib/features/mutabaah/widgets/mutabaah_projection_board.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart';
import '../providers/mutabaah_projection_provider.dart';

class MutabaahProjectionBoard extends ConsumerWidget {
  final String siswaId;
  final ModulModel modul;

  const MutabaahProjectionBoard({
    super.key,
    required this.siswaId,
    required this.modul,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectionAsync = ref.watch(mutabaahProjectionProvider(siswaId, modul));

    return projectionAsync.when(
      data: (proj) {
        // FIX: Menggunakan totalTarget dari proyeksi, karena modul internal mungkin memiliki targetAmount statis 0
        if (proj.isCompleted && proj.totalTarget > 0) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green),
                SizedBox(width: 12),
                Expanded(child: Text("Alhamdulillah, target modul ini telah tuntas!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              ],
            ),
          );
        }

        final dateStr = proj.estimatedCompletionDate != null ? DateFormat('dd MMM yyyy').format(proj.estimatedCompletionDate!) : '-';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.insights_rounded, size: 14, color: Colors.grey),
                  SizedBox(width: 6),
                  Text("PROYEKSI AKADEMIK", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  _projStat("Sisa Volume", "${proj.remainingVolume.toStringAsFixed(1)} ${modul.targetAmountUnit}"),
                  _projStat("Estimasi Tuntas", "~${proj.estimatedMeetingsLeft} Pertemuan"),
                  _projStat("Prediksi Tanggal", dateStr),
                ],
              )
            ],
          ),
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(strokeWidth: 2))),
      error: (e, st) => Center(child: Text("Gagal memuat proyeksi", style: TextStyle(color: Colors.red.withValues(alpha: 0.7), fontSize: 11))),
    );
  }

  Widget _projStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }
}