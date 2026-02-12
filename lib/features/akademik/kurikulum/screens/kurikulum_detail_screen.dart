import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kurikulum_provider.dart';
import '../models/kurikulum_model.dart';
import 'level_list_screen.dart'; // Import ini wajib untuk navigasi

class KurikulumDetailScreen extends ConsumerWidget {
  final KurikulumModel kurikulum;

  const KurikulumDetailScreen({super.key, required this.kurikulum});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sesuai Hierarki: Di bawah Kurikulum adalah Jenjang
    final jenjangAsync = ref.watch(jenjangListProvider(kurikulum.id!));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(kurikulum.namaKurikulum),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: jenjangAsync.when(
        data: (jenjangs) => jenjangs.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jenjangs.length,
          itemBuilder: (context, index) {
            final jenjang = jenjangs[index];
            return _buildJenjangCard(context, jenjang);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddJenjangDialog(context, ref),
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add_road, color: Colors.white),
        label: const Text("Tambah Jenjang", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildJenjangCard(BuildContext context, JenjangModel jenjang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
          child: const Icon(Icons.layers_outlined, color: Color(0xFF10B981), size: 20),
        ),
        title: Text(jenjang.namaJenjang, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(jenjang.deskripsi ?? 'Belum ada deskripsi jenjang'),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Navigasi ke daftar level di bawah jenjang ini
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LevelListScreen(jenjang: jenjang),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center( // Perbaikan: Menghapus const agar properti child dinamis jika diperlukan, namun tetap efisien
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined, size: 80, color: Colors.grey[300]), // Perbaikan warna agar konsisten
          const SizedBox(height: 16),
          const Text("Belum ada jenjang pendidikan.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showAddJenjangDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tambah Jenjang Baru"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Nama Jenjang",
            hintText: "Misal: Pra-Tahsin / Tahfidz Dasar",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              await ref.read(jenjangListProvider(kurikulum.id!).notifier).saveJenjang(
                JenjangModel(
                  kurikulumId: kurikulum.id!,
                  namaJenjang: controller.text.trim(),
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