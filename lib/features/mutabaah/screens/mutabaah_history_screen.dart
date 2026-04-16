// Lokasi: lib/features/mutabaah/screens/mutabaah_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/mutabaah_provider.dart';
import '../models/mutabaah_model.dart';

class MutabaahHistoryScreen extends ConsumerWidget {
  final String? siswaId; // Jika null, tampilkan semua (Mutabaah Hub)

  const MutabaahHistoryScreen({super.key, this.siswaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memilih provider berdasarkan apakah ini riwayat personal atau global
    final historyAsync = siswaId != null
        ? ref.watch(mutabaahHistoryProvider(siswaId!))
        : ref.watch(mutabaahAllHistoryProvider);

    const Color emerald = Color(0xFF10B981);
    const Color slate = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          siswaId != null ? "Riwayat Santri" : "Log Mutabaah Pusat",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: slate,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // TODO: Implementasi filter tanggal/tipe modul
            },
          )
        ],
      ),
      body: historyAsync.when(
        data: (records) {
          if (records.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildHistoryCard(record, emerald, slate);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildHistoryCard(MutabaahRecord record, Color emerald, Color slate) {
    final isTahfidz = record.tipeModul == 'HAFALAN';
    final dateStr = DateFormat('dd MMM yyyy • HH:mm').format(record.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isTahfidz ? emerald.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTahfidz ? Icons.menu_book_rounded : Icons.assignment_turned_in_rounded,
                color: isTahfidz ? emerald : Colors.blue,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Text(
                  record.tipeModul,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                    color: isTahfidz ? emerald : Colors.blue,
                  ),
                ),
                const Spacer(),
                // BADGE DELEGASI (Penting untuk Audit Payroll)
                if (record.isDelegasi)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "PENGGANTI",
                      style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildPayloadContent(record),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(dateStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          if (record.catatan != null && record.catatan!.isNotEmpty)
            _buildCatatanBox(record.catatan!),
        ],
      ),
    );
  }

  Widget _buildPayloadContent(MutabaahRecord record) {
    if (record.tipeModul == 'HAFALAN') {
      final p = record.dataPayload;
      return Text(
        "Surah ${p['start_surah']}:${p['start_ayah']} - ${p['end_surah']}:${p['end_ayah']} (${p['calculated_pages']} Hal)",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
      );
    } else {
      return Text(
        "Skor: ${record.dataPayload['nilai'] ?? 0} / 100",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
      );
    }
  }

  Widget _buildCatatanBox(String catatan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Text(
        "“$catatan”",
        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Color(0xFFE2E8F0)),
          SizedBox(height: 16),
          Text("Belum ada rekaman mutabaah.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}