// Lokasi: lib/features/mutabaah/screens/mutabaah_log_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../siswa/models/siswa_model.dart';
import '../models/mutabaah_model.dart';
import '../providers/mutabaah_provider.dart';

class MutabaahLogScreen extends ConsumerWidget {
  final SiswaModel siswa;

  const MutabaahLogScreen({super.key, required this.siswa});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(mutabaahHistoryProvider(siswa.id!));
    const Color emerald = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Riwayat Progres", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(siswa.namaLengkap, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: historyAsync.when(
        data: (records) {
          if (records.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(mutabaahHistoryProvider(siswa.id!).future),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return _buildHistoryCard(record, emerald);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: emerald)),
        error: (e, _) => Center(child: Text("Gagal memuat data: $e")),
      ),
    );
  }

  Widget _buildHistoryCard(MutabaahRecord record, Color color) {
    final dateStr = DateFormat('dd MMM yyyy • HH:mm').format(record.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card: Nama Modul & Tipe
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.tipeModul, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    const Text("Modul Akademik", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)), // Ganti dengan nama modul asli dari join
                  ],
                ),
                Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),

          const Divider(height: 1),

          // Body Card: Progres Dinamis
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressDetail(record, color),
                if (record.catatan != null && record.catatan!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      "“${record.catatan}”",
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF475569)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetail(MutabaahRecord record, Color color) {
    if (record.tipeModul == 'HAFALAN') {
      final p = record.dataPayload;
      return Row(
        children: [
          _metricItem(Icons.menu_book_rounded, "Rentang", "QS ${p['start_surah']}:${p['start_ayah']} - ${p['end_ayah']}"),
          const SizedBox(width: 24),
          _metricItem(Icons.auto_graph_rounded, "Volume", "${p['calculated_pages'].toStringAsFixed(1)} Hal", isHighlight: true, color: color),
        ],
      );
    } else {
      final nilai = record.dataPayload['nilai'] ?? 0;
      return _metricItem(Icons.grade_rounded, "Skor Akhir", "$nilai / 100", isHighlight: true, color: color);
    }
  }

  Widget _metricItem(IconData icon, String label, String value, {bool isHighlight = false, Color color = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 18 : 14,
            fontWeight: FontWeight.w900,
            color: isHighlight ? color : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text("Belum ada catatan progres.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}