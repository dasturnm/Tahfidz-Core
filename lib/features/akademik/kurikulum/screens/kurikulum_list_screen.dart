import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/management_lembaga/providers/app_context_provider.dart';
import '../providers/kurikulum_provider.dart';
import '../models/kurikulum_model.dart';
import 'kurikulum_detail_screen.dart';

class KurikulumListScreen extends ConsumerWidget {
  const KurikulumListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil ID Lembaga aktif
    final lembagaId = ref.watch(appContextProvider).lembaga?.id;

    // Watch Provider (Pastikan Anda sudah membuat 'kurikulumListProvider' yang menerima lembagaId)
    // Gunakan 'const AsyncValue.data([])' jika provider belum siap, untuk testing UI
    final kurikulumAsync = ref.watch(kurikulumListProvider(lembagaId ?? ''));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Daftar Kurikulum"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: lembagaId == null
          ? const Center(child: Text("Data Lembaga tidak ditemukan"))
          : kurikulumAsync.when(
        data: (data) => data.isEmpty
            ? _buildEmptyState(context, ref)
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return _buildCard(context, item);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref, lembagaId!),
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCard(BuildContext context, KurikulumModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
          child: const Icon(Icons.book_outlined, color: Color(0xFF10B981)),
        ),
        title: Text(item.namaKurikulum, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(item.deskripsi ?? "Tidak ada deskripsi"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Navigasi ke Detail (Hierarki 1: Kurikulum)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KurikulumDetailScreen(kurikulum: item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("Belum ada data kurikulum", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, String lembagaId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tambah Kurikulum"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nama Kurikulum (cth: K13, Tahfidz)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;

              final newKurikulum = KurikulumModel(
                  id: null,
                  programId: '', // Fix: Tambahkan programId sesuai required di model
                  lembagaId: lembagaId,
                  namaKurikulum: controller.text.trim(),
                  deskripsi: "Kurikulum standar lembaga",
                  status: "aktif"
              );

              await ref.read(kurikulumListProvider(lembagaId).notifier).saveKurikulum(newKurikulum);

              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }
}