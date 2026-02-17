import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_context_provider.dart';
import '../providers/lembaga_provider.dart'; // Ditambahkan: Import provider baru
import '../models/divisi_model.dart';

class DivisiListScreen extends ConsumerStatefulWidget {
  const DivisiListScreen({super.key});

  @override
  ConsumerState<DivisiListScreen> createState() => _DivisiListScreenState();
}

class _DivisiListScreenState extends ConsumerState<DivisiListScreen> {
  // FIX: _isLoading dan _divisiList dihapus karena sudah dikelola oleh DivisiListProvider

  void _showDivisiDialog(String lembagaId, {DivisiModel? divisi}) {
    final isEdit = divisi != null;
    final nameController = TextEditingController(text: divisi?.namaDivisi ?? '');
    final descController = TextEditingController(text: divisi?.deskripsi ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Edit Divisi" : "Tambah Divisi Baru", style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Divisi",
                  hintText: "cth: Akademik, Tahfidz, SDM",
                ),
                validator: (val) => val!.isEmpty ? "Nama divisi wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: "Deskripsi",
                  hintText: "Jelaskan fungsi divisi ini",
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              try {
                // UPDATE: Menggunakan DivisiModel dan Provider Notifier
                final updatedDivisi = (divisi ?? DivisiModel(
                  id: '',
                  lembagaId: lembagaId,
                  namaDivisi: nameController.text.trim(),
                )).copyWith(
                  namaDivisi: nameController.text.trim(),
                  deskripsi: descController.text.trim(),
                  status: divisi?.status ?? 'aktif',
                );

                await ref.read(divisiListProvider(lembagaId).notifier).saveDivisi(updatedDivisi);

                if (!mounted) return; // FIX: use_build_context_synchronously
                navigator.pop();

                messenger.showSnackBar(
                  SnackBar(content: Text(isEdit ? "Divisi berhasil diupdate!" : "Divisi berhasil ditambahkan!")),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text("Gagal menyimpan: $e")),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: Text(isEdit ? "Update" : "Simpan", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lembaga = ref.watch(appContextProvider).lembaga;
    if (lembaga == null) return const Center(child: CircularProgressIndicator());

    // Memantau data divisi secara reaktif
    final divisiAsync = ref.watch(divisiListProvider(lembaga.id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: divisiAsync.when(
        data: (divisiList) => divisiList.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: divisiList.length,
          itemBuilder: (context, index) {
            final d = divisiList[index];
            return _buildDivisiCard(d);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: FloatingActionButton.extended(
          onPressed: () => _showDivisiDialog(lembaga.id),
          backgroundColor: const Color(0xFF10B981),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Tambah Divisi", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildDivisiCard(DivisiModel d) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.account_tree_outlined, color: Color(0xFF10B981)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                d.namaDivisi,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            _buildStatusChip(d.status ?? 'aktif'),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            d.deskripsi ?? "Tidak ada deskripsi",
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
        trailing: const Icon(Icons.edit_outlined, color: Colors.grey),
        onTap: () {
          final lembagaId = ref.read(appContextProvider).lembaga!.id;
          _showDivisiDialog(lembagaId, divisi: d);
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final bool isActive = status == 'aktif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? "AKTIF" : "NONAKTIF",
        style: TextStyle(
          color: isActive ? const Color(0xFF10B981) : Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Belum ada divisi terdaftar",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}