// Lokasi: lib/features/akademik/kurikulum/screens/components/modul_estimation_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../program/providers/program_provider.dart';
import '../../../../program/providers/agenda_provider.dart';
// FIX PATH: Menyesuaikan kedalaman folder dari /screens/components/ ke /providers/
import '../../providers/kurikulum_provider.dart';
import '../../../../../core/providers/app_context_provider.dart';

class ModulEstimationCard extends ConsumerWidget {
  final String levelId;
  final String programIdFromLevel;
  final String targetPertemuan;
  final VoidCallback onRefresh;

  const ModulEstimationCard({
    super.key,
    required this.levelId,
    required this.programIdFromLevel,
    required this.targetPertemuan,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String totalMeetings = targetPertemuan.isEmpty ? "0" : targetPertemuan;
    String estimatedDate = _calculateDate(ref);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue[100]!)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text("RINGKASAN AKADEMIK", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blue, letterSpacing: 1)),
                const Spacer(),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.blue),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(color: Colors.white, height: 24, thickness: 2),
            _buildRow("Total Pertemuan:", "$totalMeetings Kali"),
            const SizedBox(height: 8),
            _buildRow("Estimasi Lulus:", estimatedDate),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
        // FIX: Tampilkan "-" jika belum ada input agar tidak terlihat seperti loading terus menerus (Poin 3)
        Text((value == "0 Kali" || value == "0" || value == "-") ? "-" : value, style: const TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w900)),
      ],
    );
  }

  String _calculateDate(WidgetRef ref) {
    int meetingsNeeded = int.tryParse(targetPertemuan) ?? 0;
    if (meetingsNeeded <= 0) return "-";

    final lembagaId = ref.watch(appContextProvider).lembaga?.id ?? '';
    final kurikulumAsync = ref.watch(kurikulumListProvider(lembagaId));
    if (kurikulumAsync.isLoading) return "Menghitung...";

    final kurikulumList = kurikulumAsync.value ?? [];
    String? targetProgramId;

    for (var k in kurikulumList) {
      if (k.jenjang.any((j) => j.level.any((l) => l.id == levelId))) {
        targetProgramId = k.programId;
        break;
      }
    }

    final String finalProgramId = targetProgramId ?? programIdFromLevel;
    if (finalProgramId.isEmpty || finalProgramId == 'null') return "Jadwal Belum Diatur";

    final List<String> activeDaysStr = ref.watch(programHariEfektifProvider(finalProgramId));
    final agendas = ref.watch(agendaNotifierProvider(programId: finalProgramId)).value ?? [];

    final Map<String, int> dayMap = {'senin': 1, 'selasa': 2, 'rabu': 3, 'kamis': 4, 'jumat': 5, 'sabtu': 6, 'minggu': 7};
    final activeDays = activeDaysStr.map((d) => dayMap[d.toLowerCase()] ?? 0).where((d) => d != 0).toList();

    if (activeDays.isEmpty) return "Jadwal Belum Diatur";

    DateTime current = DateTime.now();
    int added = 0;
    while (added < meetingsNeeded) {
      current = current.add(const Duration(days: 1));
      final dateOnly = DateTime(current.year, current.month, current.day);

      // FIX: Normalisasi pengecekan tanggal libur (menghindari error jam/menit)
      bool isHoliday = agendas.any((a) {
        final start = DateTime(a.tanggalMulai.year, a.tanggalMulai.month, a.tanggalMulai.day);
        final end = DateTime(a.tanggalBerakhir.year, a.tanggalBerakhir.month, a.tanggalBerakhir.day);
        return a.statusHariBelajar == 'LIBUR' && !dateOnly.isBefore(start) && !dateOnly.isAfter(end);
      });

      if (activeDays.contains(current.weekday) && !isHoliday) {
        added++;
      }

      // Safety break untuk menghindari infinite loop jika jadwal belum diatur dengan benar
      if (current.isAfter(DateTime.now().add(const Duration(days: 3650)))) break;
    }
    return DateFormat('dd MMMM yyyy', 'id_ID').format(current);
  }
}