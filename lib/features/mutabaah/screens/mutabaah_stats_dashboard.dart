// Lokasi: lib/features/mutabaah/screens/mutabaah_stats_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../siswa/models/siswa_model.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart';
import '../services/mutabaah_provider.dart';
import '../services/mutabaah_pdf_service.dart';

class MutabaahStatsDashboard extends ConsumerWidget {
  final SiswaModel siswa;
  final LevelModel currentLevel; // Membutuhkan data target dari level

  const MutabaahStatsDashboard({
    super.key,
    required this.siswa,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(mutabaahStatsProvider(siswa.id!));
    const Color emerald = Color(0xFF10B981);
    const Color slate = Color(0xFF1E293B);

    // Hitung persentase target level
    double targetTotal = currentLevel.targetTotal;
    double progressPercent = (stats['monthly_pages'] / targetTotal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Statistik Capaian", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: slate,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: stats['total_records'] == 0
                ? null
                : () => MutabaahPdfService.generateMonthlyReport(
              siswa: siswa,
              stats: stats,
              namaLembaga: "SISTEM AKADEMIK QURAN",
            ),
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
            tooltip: "Unduh Laporan PDF",
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(emerald),
            const SizedBox(height: 24),

            // CARD UTAMA: Progres Hafalan
            _buildMainProgressCard(emerald, stats['monthly_pages'], targetTotal, progressPercent),

            const SizedBox(height: 16),

            // BARIS STATISTIK SEKUNDER
            Row(
              children: [
                Expanded(
                  child: _buildSmallStatCard(
                      "Rerata Nilai",
                      "${stats['avg_score'].toStringAsFixed(1)}",
                      Icons.auto_awesome_rounded,
                      Colors.orange
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSmallStatCard(
                      "Total Setoran",
                      "${stats['total_records']} Kali",
                      Icons.history_edu_rounded,
                      Colors.blue
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text("ANALISA GURU", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _buildInsightCard(progressPercent),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: stats['total_records'] == 0
                    ? null
                    : () => MutabaahPdfService.generateMonthlyReport(
                  siswa: siswa,
                  stats: stats,
                  namaLembaga: "SISTEM AKADEMIK QURAN",
                ),
                icon: const Icon(Icons.print_rounded),
                label: const Text("CETAK LAPORAN RESMI", style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: slate,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(Icons.analytics_rounded, color: color),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(siswa.namaLengkap, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Level: ${currentLevel.namaLevel}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildMainProgressCard(Color color, double current, double target, double percent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Target Level Bulan Ini", style: TextStyle(color: Colors.white70, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                child: Text("${(percent * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text("${current.toStringAsFixed(1)} / $target Halaman", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Tetap istiqomah untuk mencapai target level tepat waktu.", style: TextStyle(color: Colors.white54, fontSize: 11, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(double percent) {
    String message = percent > 0.7 ? "Performa Luar Biasa!" : "Pertahankan Semangat!";
    IconData icon = percent > 0.7 ? Icons.workspace_premium_rounded : Icons.tips_and_updates_rounded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "$message Santri menunjukkan konsistensi yang baik dalam setoran harian.",
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }
}