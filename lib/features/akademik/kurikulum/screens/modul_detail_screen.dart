import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import '../providers/kurikulum_provider.dart';
import '../widgets/target_metrik_dialog.dart';

class ModulDetailScreen extends ConsumerWidget {
  final LevelModel level;
  final ModulModel modul;

  const ModulDetailScreen({super.key, required this.level, required this.modul});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch daftar metrik untuk modul ini
    final metrikAsync = ref.watch(targetMetrikListProvider(modul.id!));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Manajemen Akademik", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildBreadcrumbHeader(context),
          Expanded(
            child: metrikAsync.when(
              data: (targets) => targets.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: targets.length,
                itemBuilder: (context, index) {
                  final target = targets[index];
                  return _buildMetrikCard(context, ref, target);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "JENJANG TAHSIN / LEVEL ${level.namaLevel.toUpperCase()}",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  modul.namaModul,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => TargetMetrikDialog(modul: modul),
                  );
                },
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text(
                  "TAMBAH METRIK",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBadge(modul.tipe, const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _buildBadge("${modul.durasiHari} Hari", Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildMetrikCard(BuildContext context, WidgetRef ref, TargetMetrikModel target) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.track_changes, color: Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("METRIK", target.jenisMetrik),
                const SizedBox(height: 4),
                _buildInfoRow("CAKUPAN MATERI", "${target.mulai} ➔ ${target.akhir}"),
                const SizedBox(height: 4),
                _buildInfoRow("SATUAN", target.satuan),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("MIN. KKM", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text("${target.kkm.toInt()}%", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildIconBtn(Icons.edit_outlined, () {}),
                  const SizedBox(width: 8),
                  _buildIconBtn(Icons.delete_outline, () {}, color: Colors.red[300]),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
        ),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
        child: Icon(icon, size: 16, color: color ?? Colors.grey),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.ads_click, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text("Belum ada target metrik pengujian.", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}