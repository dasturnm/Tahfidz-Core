import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/siswa_provider.dart';
import 'siswa_form_screen.dart';
import '../widgets/enroll_kurikulum_dialog.dart';
import 'package:tahfidz_core/shared/widgets/app_drawer.dart';

class SiswaListScreen extends ConsumerWidget {
  const SiswaListScreen({super.key});

  // Helper untuk Import
  void _handleImport(BuildContext context, WidgetRef ref) async {
    // Info format CSV
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Import CSV"),
        content: const Text("Pastikan file CSV memiliki format urutan:\n\n1. No\n2. Nama\n3. L/P\n4. NISN\n5. Alamat\n\nBaris pertama (Header) akan dilewati."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text("Pilih File", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Loading
    if(!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
    );

    // Proses
    final msg = await ref.read(siswaListProvider.notifier).importSiswaFromCSV();

    // Selesai
    if (context.mounted) {
      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: msg.contains("Berhasil") ? const Color(0xFF10B981) : Colors.red,
      ));
    }
  }

  // Helper untuk Export
  void _handleExport(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(siswaListProvider.notifier).exportSiswaToCSV();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siswaAsync = ref.watch(siswaListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Data Siswa"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // TOMBOL MENU IMPORT / EXPORT
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'import') _handleImport(context, ref);
              if (value == 'export') _handleExport(context, ref);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(children: [Icon(Icons.upload_file, color: Colors.green), SizedBox(width: 10), Text("Import CSV")]),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(children: [Icon(Icons.download, color: Colors.blue), SizedBox(width: 10), Text("Export CSV")]),
              ),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: siswaAsync.when(
        data: (listSiswa) {
          if (listSiswa.isEmpty) {
            return const Center(child: Text("Belum ada data siswa"));
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(siswaListProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listSiswa.length,
              itemBuilder: (context, index) {
                final siswa = listSiswa[index];
                final waliKelas = siswa.namaWaliKelas ?? 'Belum ada wali kelas';
                final namaKelas = siswa.namaKelas ?? 'Tanpa Kelas';

                final isLaki = siswa.jenisKelamin == 'L';

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => EnrollKurikulumDialog(siswa: siswa),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isLaki ? Colors.blue.withValues(alpha: 0.1) : Colors.pink.withValues(alpha: 0.1),
                      child: Icon(
                        isLaki ? Icons.face : Icons.face_3,
                        color: isLaki ? Colors.blue : Colors.pink,
                      ),
                    ),
                    title: Text(
                        siswa.namaLengkap,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Kelas: $namaKelas", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        Text("Wali: $waliKelas", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        if (siswa.nisn != null)
                          Text("NISN: ${siswa.nisn}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => SiswaFormScreen(siswa: siswa.toJson()),
                        ));
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SiswaFormScreen()));
        },
      ),
    );
  }
}