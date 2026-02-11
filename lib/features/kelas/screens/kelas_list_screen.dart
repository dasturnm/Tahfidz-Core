import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kelas_provider.dart';
import '../widgets/kelas_card.dart';
import '../widgets/add_kelas_dialog.dart'; // Sesuaikan path-nya
import 'package:tahfidz_core/shared/widgets/app_drawer.dart';

class KelasListScreen extends ConsumerWidget {
  const KelasListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kelasAsync = ref.watch(kelasNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Manajemen Kelas"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: kelasAsync.when(
        data: (listKelas) => listKelas.isEmpty
            ? const Center(child: Text("Belum ada data kelas"))
            : RefreshIndicator(
          onRefresh: () => ref.refresh(kelasNotifierProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listKelas.length,
            itemBuilder: (context, index) => KelasCard(
              kelas: listKelas[index],
              onDelete: () => _showDeleteDialog(context, ref, listKelas[index].id!),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF10B981),
        onPressed: () => _showAddClassDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddKelasDialog(),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Kelas?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              ref.read(kelasNotifierProvider.notifier).deleteKelas(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}