// Lokasi: lib/features/akademik/kurikulum/widgets/add_kurikulum_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import '../providers/kurikulum_provider.dart';
// FIX: Menggunakan Absolute Import untuk menghindari uri_does_not_exist
import 'package:tahfidz_core/features/program/providers/program_provider.dart';

class AddKurikulumSheet {
  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required String lembagaId,
    KurikulumModel? kurikulum,
    required Color slate,
  }) {
    final nameController = TextEditingController(text: kurikulum?.namaKurikulum);
    bool isLinear = kurikulum?.isLinear ?? false;
    String? selectedProgramId = kurikulum?.programId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // FIX: Tambahkan Consumer agar Bottom Sheet bisa mendengar update dari Provider
      builder: (ctx) => Consumer(
        builder: (ctx, sheetRef, _) => StatefulBuilder(
          builder: (context, setState) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
                left: 32,
                right: 32,
                top: 32),
            // FIX: Tambahkan SingleChildScrollView agar tidak overflow saat keyboard muncul
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kurikulum == null ? "Buat Blueprint Baru" : "Edit Blueprint",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 32),

                  // FIX: Label diletakkan di luar agar SELALU MUNCUL
                  const Text(
                    "PILIH PROGRAM",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // Tambah Dropdown Program (REVISI: Penanganan Stuck Loading & Empty State)
                  // FIX: Gunakan sheetRef, bukan ref parent
                  sheetRef.watch(programNotifierProvider).when(
                    data: (programs) {
                      if (programs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "⚠️ Belum ada Program aktif. Buat Program terlebih dahulu.",
                            style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        initialValue: selectedProgramId, // FIX: Menggunakan value agar reaktif saat setState
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none),
                        ),
                        items: programs.map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.namaProgram),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedProgramId = val),
                      );
                    },
                    loading: () => Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: LinearProgressIndicator(
                          minHeight: 2,
                          // FIX: Menggunakan property color (tipe Color) untuk menghindari error Animation
                          color: slate.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    error: (err, __) => Text(
                      "Gagal memuat program: $err",
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: "NAMA KURIKULUM",
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Mode Linear",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Tanpa jenjang bertingkat/level."),
                    value: isLinear,
                    onChanged: (val) => setState(() => isLinear = val),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty) return;

                        final data = KurikulumModel(
                          id: kurikulum?.id,
                          lembagaId: lembagaId,
                          tahunAjaranId: kurikulum?.tahunAjaranId, // Mencegah data loss
                          programId: selectedProgramId, // Menggunakan pilihan dari dropdown
                          namaKurikulum: nameController.text.trim(),
                          isLinear: isLinear,
                          jenjang: kurikulum?.jenjang ?? [],
                        );

                        // FIX: Gunakan sheetRef untuk operasi baca/tulis state
                        await sheetRef
                            .read(kurikulumListProvider(lembagaId).notifier)
                            .saveKurikulum(data);
                        sheetRef.invalidate(kurikulumListProvider(lembagaId));

                        // 🔥 FIX: Refresh juga ProgramProvider agar status "KURIKULUM BELUM DIATUR" di UI hilang
                        sheetRef.invalidate(programNotifierProvider);

                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: slate,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16))),
                      child: Text(kurikulum == null ? "SIMPAN" : "PERBARUI",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void confirmDelete({
    required BuildContext context,
    required WidgetRef ref,
    required String lembagaId,
    required KurikulumModel kurikulum,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Kurikulum?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            "Apakah Anda yakin ingin menghapus '${kurikulum.namaKurikulum}'? Semua data jenjang, level, dan modul di dalamnya akan ikut terhapus."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(kurikulumListProvider(lembagaId).notifier)
                  .deleteKurikulum(kurikulum.id!);
              ref.invalidate(kurikulumListProvider(lembagaId));
              // 🔥 FIX: Refresh juga ProgramProvider saat kurikulum dihapus
              ref.invalidate(programNotifierProvider);
            },
            child: const Text("Hapus",
                style:
                TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}