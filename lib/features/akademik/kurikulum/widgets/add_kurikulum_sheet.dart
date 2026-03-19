import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import '../providers/kurikulum_provider.dart';

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
              left: 32,
              right: 32,
              top: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(kurikulum == null ? "Buat Blueprint Baru" : "Edit Blueprint",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 32),
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
                      programId: kurikulum?.programId, // Mencegah data loss
                      namaKurikulum: nameController.text.trim(),
                      isLinear: isLinear,
                      jenjang: kurikulum?.jenjang ?? [],
                    );

                    await ref
                        .read(kurikulumListProvider(lembagaId).notifier)
                        .saveKurikulum(data);
                    ref.invalidate(kurikulumListProvider(lembagaId));

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