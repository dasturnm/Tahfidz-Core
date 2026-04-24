// Lokasi: lib/features/mutabaah/screens/mutabaah_monitoring_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../siswa/models/siswa_model.dart';
import '../providers/mutabaah_provider.dart';

class MutabaahMonitoringScreen extends ConsumerWidget {
  const MutabaahMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siswaAsync = ref.watch(siswaByGuruProvider);
    const Color emerald = Color(0xFF10B981);
    const Color slate = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Monitoring Progres", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: slate,
        elevation: 0,
      ),
      body: siswaAsync.when(
        data: (listSiswa) {
          if (listSiswa.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: listSiswa.length,
            itemBuilder: (context, index) {
              final siswa = listSiswa[index];
              return _buildProgressCard(context, ref, siswa, emerald, slate);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, WidgetRef ref, SiswaModel siswa, Color emerald, Color slate) {
    // Watch statistik bulanan secara reaktif
    final stats = ref.watch(mutabaahStatsProvider(siswa.id ?? ''));

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: slate.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(siswa.namaLengkap, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                  // FIX: Menggunakan namaKelas sesuai standarisasi model terbaru
                  Text("Kelas: ${siswa.kelas?.namaKelas ?? '-'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const Icon(Icons.trending_up, color: Colors.blue, size: 20),
            ],
          ),
          const SizedBox(height: 20),

          // PROGRESS BAR VISUAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Capaian Bulan Ini", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text("${stats['monthly_pages'].toStringAsFixed(1)} Halaman", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: emerald)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (stats['monthly_pages'] / 20).clamp(0.0, 1.0), // Contoh target 20 hal/bulan
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(emerald),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              _buildMiniStat(Icons.event_note, "${stats['total_records']}", "Setoran"),
              const SizedBox(width: 16),
              _buildMiniStat(Icons.star_outline, stats['avg_score'].toStringAsFixed(1), "Rata-rata Nilai"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B))),
                Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Tidak ada santri bimbingan."));
  }
}