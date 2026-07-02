// Lokasi: lib/features/akademik/kurikulum/screens/kurikulum_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// FIX: Update path import sesuai pemisahan provider
import '../providers/jenjang_provider.dart';
import '../providers/level_provider.dart';
import '../models/kurikulum_model.dart';
import 'level_list_screen.dart';
import 'level_detail_screen.dart'; // TAMBAHAN: Untuk navigasi bypass linier
// TAMBAHAN: Untuk bypass form

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
                data: (jenjang) => jenjang.isEmpty
                    ? _buildEmptyState(context, ref)
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: jenjang.length,
                  itemBuilder: (context, index) {
                    final j = jenjang[index];
                    return _buildJenjangCard(context, j, ref);
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
                  // FIX: Ubah pemanggilan menjadi fungsi yang mendukung edit
                  onPressed: () => _showJenjangSheet(context, ref),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _emerald.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.account_tree_outlined, color: _emerald, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("STRUKTUR KURIKULUM", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
              Text(kurikulum.namaKurikulum, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _slate)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJenjangCard(BuildContext context, JenjangModel jenjang, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.layers_outlined, color: Color(0xFF94A3B8), size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                jenjang.namaJenjang,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _slate),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (kurikulum.isLinear) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "LINIER",
                  style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
            kurikulum.isLinear
                ? "Isi Materi & Modul"
                : "${jenjang.level.length} Tingkatan Level",
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)
        ),
        // FIX: Tambahkan tombol edit di sebelah kanan sebelum panah
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 18),
              onPressed: () => _showJenjangSheet(context, ref, existingJenjang: jenjang),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
          ],
        ),
        onTap: () => _handleNavigation(context, ref, jenjang),
      ),
    );
  }

  Future<void> _handleNavigation(BuildContext context, WidgetRef ref, JenjangModel j) async {
    // Debugging feedback
    debugPrint("Navigasi ke jenjang: ${j.namaJenjang} (Linear: ${kurikulum.isLinear})");

    if (kurikulum.isLinear) {
      // 1. Cek apakah level sudah ada di dalam object jenjang
      if (j.level.isEmpty) {
        showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
        try {
          // Buatkan shadow level jika belum ada
          await ref.read(levelListProvider(j.id!).notifier).saveLevel(
            LevelModel(kurikulumId: kurikulum.id!, jenjangId: j.id!, namaLevel: j.namaJenjang, urutan: 0),
          );
          // Refresh data jenjang agar level masuk ke object j
          ref.invalidate(jenjangListProvider(kurikulum.id!));
          await ref.read(jenjangListProvider(kurikulum.id!).future);
          if (context.mounted) Navigator.pop(context);
        } catch (e) {
          if (context.mounted) Navigator.pop(context);
          return;
        }
      }

      // 2. Bypass langsung ke LevelDetailScreen menggunakan level dari object j
      // Kita perlu fetch data level terbaru jika tadi baru saja create
      final levels = j.level.isNotEmpty ? j.level : (ref.read(levelListProvider(j.id!)).value ?? []);

      if (!context.mounted) return;

      if (levels.isNotEmpty) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LevelDetailScreen(level: levels.first)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Materi belum tersedia")));
      }
    } else {
      // Navigasi standar untuk kurikulum hirarkis
      Navigator.push(context, MaterialPageRoute(builder: (context) => LevelListScreen(jenjang: j, isLinear: false)));
    }
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return const Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree_outlined, size: 64, color: Color(0xFFE2E8F0)),
            SizedBox(height: 16),
            Text("Belum Ada Jenjang", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            SizedBox(height: 8),
            Text(
              "Kurikulum sudah siap. Sekarang, tambahkan jenjang pendidikan (seperti Dasar, Menengah, dst) dengan mengklik tombol + di pojok kanan bawah.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, height: 1.5, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showJenjangSheet(BuildContext context, WidgetRef ref, {JenjangModel? existingJenjang}) {
    final bool isEdit = existingJenjang != null;
    final controller = TextEditingController(text: isEdit ? existingJenjang.namaJenjang : "");
    final urutanController = TextEditingController(text: isEdit ? existingJenjang.urutan.toString() : "0");

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
                  child: Text(isEdit ? "Edit Jenjang" : "Tambah Jenjang", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _slate)),
                ),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              kurikulum.isLinear
                  ? "Jenjang linier akan otomatis memiliki satu modul materi."
                  : "Anda akan mengatur tingkatan level di jenjang ini.",
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
            const SizedBox(height: 16),
            TextField(
              controller: urutanController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "URUTAN / SEQUENCE",
                hintText: "Contoh: 1",
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
                      id: isEdit ? existingJenjang.id : null,
                      kurikulumId: kurikulum.id!,
                      namaJenjang: controller.text.trim(),
                      urutan: int.tryParse(urutanController.text.trim()) ?? 0,
                    ),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _emerald,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("SIMPAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}