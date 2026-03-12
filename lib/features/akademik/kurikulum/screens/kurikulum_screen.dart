import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kurikulum_provider.dart';
import '../models/kurikulum_model.dart';
import '../../../program/models/program_model.dart';
import 'kurikulum_detail_screen.dart';
import 'package:tahfidz_core/shared/widgets/app_drawer.dart';
import '../../../management_lembaga/providers/app_context_provider.dart';
import '../widgets/kurikulum_card.dart'; // Baru: Import KurikulumCard biru

class KurikulumScreen extends ConsumerWidget {
  final ProgramModel program;

  const KurikulumScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id ?? ''; // TAMBAHAN: Ambil lembagaId
    // Watch daftar kurikulum berdasarkan programId
    final kurikulumAsync = ref.watch(kurikulumListProvider(lembagaId)); // PERBAIKAN

    // Konstanta Warna Tema Kurikulum (Biru)
    const blueTheme = Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Kurikulum: ${program.namaProgram}"),
        backgroundColor: blueTheme, // Diubah ke Biru
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: kurikulumAsync.when(
        data: (list) => list.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(20), // Padding disesuaikan
          itemCount: list.length,
          itemBuilder: (context, index) {
            final k = list[index];
            // PERBAIKAN: Memanggil KurikulumCard dengan parameter onTap (Tanpa bungkus InkWell luar)
            return KurikulumCard(
              kurikulum: k,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KurikulumDetailScreen(kurikulum: k),
                  ),
                );
              },
              onEdit: () {
                // TODO: Aksi buka form edit
              },
              onDelete: () async {
                await ref.read(kurikulumListProvider(lembagaId).notifier).deleteKurikulum(k.id!); // PERBAIKAN
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddKurikulumDialog(context, ref),
        backgroundColor: blueTheme, // Diubah ke Biru
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Kurikulum", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Belum ada kurikulum untuk program ini.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showAddKurikulumDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    const blueTheme = Color(0xFF3B82F6); // Diubah ke Biru

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tambah Kurikulum Baru", style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Nama Kurikulum",
            hintText: "Misal: Kurikulum Reguler 2026",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              final lembagaId = ref.read(appContextProvider).lembaga?.id; // Ambil Lembaga ID
              await ref.read(kurikulumListProvider(lembagaId!).notifier).addKurikulum( // PERBAIKAN
                KurikulumModel(
                  lembagaId: lembagaId,
                  namaKurikulum: controller.text.trim(),
                ), // PERBAIKAN: Menghapus programId
              );
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: blueTheme,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}