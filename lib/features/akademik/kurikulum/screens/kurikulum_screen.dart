// Lokasi: lib/features/akademik/kurikulum/screens/kurikulum_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kurikulum_provider.dart';
import '../models/kurikulum_model.dart';
import '../../../program/models/program_model.dart';
import 'kurikulum_detail_screen.dart';
import 'package:tahfidz_core/shared/widgets/app_drawer.dart';
import '../../../../core/providers/app_context_provider.dart';
import '../widgets/kurikulum_card.dart'; // Baru: Import KurikulumCard biru
import '../widgets/add_kurikulum_sheet.dart'; // FIX: Gunakan sheet yang mendukung pilihan program

class KurikulumScreen extends ConsumerWidget {
  final ProgramModel program;

  const KurikulumScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lembagaId = ref.watch(appContextProvider).lembaga?.id ?? ''; // TAMBAHAN: Ambil lembagaId
    // Watch daftar kurikulum berdasarkan programId
    final kurikulumAsync = ref.watch(kurikulumListProvider(lembagaId, programId: program.id)); // FIX: Sertakan Filter Program

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
                // FIX: Gunakan sheet untuk Edit
                AddKurikulumSheet.show(
                  context: context,
                  ref: ref,
                  lembagaId: lembagaId,
                  kurikulum: k,
                  slate: blueTheme,
                );
              },
              onDelete: () async {
                // FIX: Membaca provider dengan filter yang sama agar UI tersinkronisasi
                await ref.read(kurikulumListProvider(lembagaId, programId: program.id).notifier).deleteKurikulum(k.id!);
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddKurikulumSheet.show(
          context: context,
          ref: ref,
          lembagaId: lembagaId,
          // Template awal dengan programId terisi agar otomatis terpilih di dropdown
          kurikulum: KurikulumModel(lembagaId: lembagaId, programId: program.id, namaKurikulum: ''),
          slate: blueTheme,
        ),
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
}