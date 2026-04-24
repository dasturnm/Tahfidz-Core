// Lokasi: lib/features/siswa/screens/siswa_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/siswa_provider.dart';
import 'siswa_form_screen.dart';
import '../widgets/enroll_kurikulum_dialog.dart';

class SiswaListScreen extends ConsumerWidget {
  const SiswaListScreen({super.key});

  void _handleImport(BuildContext context, WidgetRef ref) async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Import Data Siswa"),
        content: const Text(
            "Gunakan template resmi untuk menghindari kesalahan data.\n\nUrutan Kolom:\nNama, NISN, Email, No HP, JK, Tgl Lahir, Alamat, Status, Password."),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(siswaListProvider.notifier).downloadTemplate();
              Navigator.pop(ctx);
            },
            child: const Text("Unduh Template", style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'import'),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981)),
            child:
            const Text("Pilih File", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (action != 'import') return;

    if (!context.mounted) return;

    // Menjalankan fungsi import yang sudah terhubung ke SiswaService
    await ref.read(siswaListProvider.notifier).importSiswaCsv();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Proses import selesai"),
      backgroundColor: Color(0xFF10B981),
    ));
  }

  void _handleExport(BuildContext context, WidgetRef ref) async {
    try {
      // Memanggil fungsi export dari provider
      await ref.read(siswaListProvider.notifier).exportSiswa();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // REAKTIF: Watch data siswa (v2026.03.22)
    final state = ref.watch(siswaListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Data Siswa"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'import') _handleImport(context, ref);
              if (value == 'export') _handleExport(context, ref);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(children: [
                  Icon(Icons.upload_file, color: Colors.green),
                  SizedBox(width: 10),
                  Text("Import CSV")
                ]),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(children: [
                  Icon(Icons.download, color: Colors.blue),
                  SizedBox(width: 10),
                  Text("Export CSV")
                ]),
              ),
            ],
          ),
        ],
      ),
      // Standard Emas UI: AsyncValue.when (Aturan v2026.03.22)
      body: state.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF10B981))),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              err.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text("Belum ada data siswa"));
          }
          return RefreshIndicator(
            color: const Color(0xFF10B981),
            onRefresh: () => ref.refresh(siswaListProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final siswa = data[index];
                // FIX: Menggunakan waliKelas sesuai properti di KelasModel (v2026.03.22)
                final waliKelas = siswa.kelas?.waliKelas?.namaLengkap ??
                    'Belum ada wali kelas';
                // FIX: Menggunakan namaKelas sesuai standarisasi model terbaru
                final namaKelas = siswa.kelas?.namaKelas ?? 'Tanpa Kelas';
                final isLaki = siswa.jenisKelamin == 'L';

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    visualDensity: VisualDensity.compact,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            EnrollKurikulumDialog(siswa: siswa),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: isLaki
                          ? Colors.blue.withValues(alpha: 0.1)
                          : Colors.pink.withValues(alpha: 0.1),
                      child: Icon(
                        isLaki ? Icons.face : Icons.face_3,
                        color: isLaki ? Colors.blue : Colors.pink,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      siswa.namaLengkap,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Kelas: $namaKelas",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981)),
                        ),
                        Text(
                          "Wali: $waliKelas",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      constraints: const BoxConstraints(maxWidth: 32),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                      onPressed: () {
                        if (!context.mounted) return;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SiswaFormScreen(
                                  existingSiswa: siswa),
                            ));
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          if (!context.mounted) return;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SiswaFormScreen()));
        },
      ),
    );
  }
}