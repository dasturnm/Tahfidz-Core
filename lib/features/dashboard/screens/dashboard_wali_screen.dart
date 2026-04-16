// Lokasi: lib/features/dashboard/screens/dashboard_wali_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_context_provider.dart';
import '../../murojaah/widgets/murojaah_checklist_widget.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart';

class DashboardWaliScreen extends ConsumerWidget {
  const DashboardWaliScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextState = ref.watch(appContextProvider);
    final profile = contextState.profile;
    const Color emerald = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Beranda Santri", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => ref.read(appContextProvider.notifier).initContext(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(appContextProvider.notifier).initContext(),
        color: emerald,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. WELCOME HEADER
              Text(
                "Assalamu'alaikum,",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                profile?.namaLengkap ?? "Ananda",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 32),

              // 2. PROGRESS SUMMARY CARD
              _buildProgressCard(emerald),
              const SizedBox(height: 32),

              // 3. MUROJAAH CHECKLIST (CORE FEATURE)
              if (profile != null)
                MurojaahChecklistWidget(
                  studentId: profile.id, // Menghapus dead null aware (id sudah pasti ada jika profile != null)
                  // Menghapus 'const' karena ModulModel memiliki properti List/non-const
                  modul: ModulModel(
                      levelId: "current_level",
                      namaModul: "Program Murojaah",
                      tipe: "MUROJAAH",
                      sabqiAmount: 5, // Default 5 hal ke belakang
                      manzilType: 'percentage', // Default manzil dinamis 10%
                      manzilAmount: 10.0
                  ),
                ),

              const SizedBox(height: 32),

              // 4. INFORMASI TERBARU
              const Text(
                "INFO LEMBAGA",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.blueGrey, letterSpacing: 1.1),
              ),
              const SizedBox(height: 16),
              _buildInfoTile("Ujian Tasmi' Akhir Semester", "Senin, 20 April 2026", Icons.event_note),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Hafalan", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("12 Juz 5 Halaman", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white24,
            child: Icon(Icons.trending_up_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}