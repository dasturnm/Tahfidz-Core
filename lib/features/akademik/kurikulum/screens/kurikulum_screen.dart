import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kurikulum_provider.dart';
import '../models/kurikulum_model.dart';
import '../../../program/models/program_model.dart';
import 'kurikulum_detail_screen.dart';
import 'package:tahfidz_core/shared/widgets/app_drawer.dart';

class KurikulumScreen extends ConsumerWidget {
  final ProgramModel program;

  const KurikulumScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch daftar kurikulum berdasarkan programId
    final kurikulumAsync = ref.watch(kurikulumListProvider(program.id));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Kurikulum: ${program.namaProgram}"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: kurikulumAsync.when(
        data: (list) => list.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final k = list[index];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF10B981),
                  child: Icon(Icons.assignment_outlined, color: Colors.white, size: 20),
                ),
                title: Text(k.namaKurikulum, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(k.isActive ? "Status: Aktif" : "Status: Non-Aktif"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigasi ke detail level di dalam kurikulum ini
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KurikulumDetailScreen(kurikulum: k),
                    ),
                  );
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddKurikulumDialog(context, ref),
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Kurikulum", style: TextStyle(color: Colors.white)),
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tambah Kurikulum Baru"),
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
              await ref.read(kurikulumListProvider(program.id).notifier).addKurikulum(
                KurikulumModel(
                  programId: program.id,
                  lembagaId: program.lembagaId,
                  namaKurikulum: controller.text.trim(),
                ),
              );
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}