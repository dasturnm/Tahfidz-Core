// Lokasi: lib/features/akademik/kurikulum/screens/kurikulum_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kurikulum_provider.dart';
import '../models/kurikulum_model.dart';
import 'level_list_screen.dart';

class KurikulumDetailScreen extends ConsumerWidget {
  final KurikulumModel kurikulum;
  final bool isGridView;

  const KurikulumDetailScreen({
    super.key,
    required this.kurikulum,
    this.isGridView = true,
  });

  final Color _emerald = const Color(0xFF10B981);
  final Color _slate = const Color(0xFF1E293B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memastikan ID kurikulum tersedia sebelum watch provider
    final String kurId = kurikulum.id ?? '';
    final jenjangAsync = ref.watch(jenjangListProvider(kurId));

    // PERBAIKAN: Tidak menggunakan Scaffold karena sudah ada di AkademikHubScreen
    return Column(
      children: [
        _buildBreadcrumbHeader(context),
        Expanded(
          child: Stack(
            children: [
              jenjangAsync.when(
                data: (jenjangs) => jenjangs.isEmpty
                    ? _buildEmptyState(context, ref) // PERBAIKAN POIN 1
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  itemCount: jenjangs.length,
                  itemBuilder: (context, index) {
                    final jenjang = jenjangs[index];
                    return _buildJenjangCard(context, jenjang);
                  },
                ),
                loading: () => Center(child: CircularProgressIndicator(color: _emerald)),
                error: (err, _) => Center(child: Text("Error: $err")),
              ),

              // Floating Action Button manual karena tidak ada Scaffold di level ini
              Positioned(
                bottom: 32,
                right: 32,
                child: FloatingActionButton(
                  onPressed: () => _showAddJenjangSheet(context, ref),
                  backgroundColor: _slate,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumbHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "KURIKULUM ${kurikulum.namaKurikulum.toUpperCase()}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _emerald,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "1. Jenjang Pendidikan",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _slate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJenjangCard(BuildContext context, JenjangModel jenjang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.layers_outlined, color: Color(0xFF94A3B8), size: 24),
        ),
        title: Row(
          children: [
            Text(
                jenjang.namaJenjang,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _slate)
            ),
            if (kurikulum.isLinear) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "LINEAR",
                  style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          // PERBAIKAN POIN 4 & 5: Logika Level Tunggal & Sinkronisasi Info Modul
            kurikulum.isLinear
                ? "${jenjang.levels.fold(0, (sum, l) => sum + l.modules.length)} Modul Pelatihan"
                : "${jenjang.levels.length} Tingkatan / Level",
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LevelListScreen(
                jenjang: jenjang,
                isLinear: kurikulum.isLinear, // Teruskan flag ke layar berikutnya
              ),
            ),
          );
        },
      ),
    );
  }

  // PERBAIKAN POIN 1: Instruksi buat jenjang saat kosong
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_tree_outlined, size: 80, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
            const Text(
              "Kurikulum berhasil dibuat! Langkah selanjutnya, silakan tentukan Jenjang pendidikan pertama Anda.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddJenjangSheet(context, ref),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text("BUAT JENJANG PERTAMA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _emerald,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddJenjangSheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            left: 32, right: 32, top: 32
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.layers_outlined, color: _emerald, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text("Tambah Jenjang Baru", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _slate)),
                ),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              kurikulum.isLinear
                  ? "Mode Linear: Jenjang ini akan langsung berisi modul."
                  : "Mode Hierarki: Anda akan mengatur tingkatan di jenjang ini.",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "NAMA JENJANG",
                hintText: "Contoh: Tahfidz Dasar",
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.text.isEmpty) return;
                  if (kurikulum.id == null) return;

                  await ref.read(jenjangListProvider(kurikulum.id!).notifier).saveJenjang(
                    JenjangModel(
                      kurikulumId: kurikulum.id!,
                      namaJenjang: controller.text.trim(),
                    ),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _emerald,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("SIMPAN JENJANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}