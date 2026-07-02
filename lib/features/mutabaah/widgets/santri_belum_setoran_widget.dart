import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/santri_belum_setoran_provider.dart';

class SantriBelumSetoranWidget extends ConsumerWidget {
  final String guruId;

  const SantriBelumSetoranWidget({super.key, required this.guruId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(santriBelumSetoranProvider(guruId));

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text("Gagal memuat data: $err"),
      data: (listSiswa) {
        if (listSiswa.isEmpty) {
          return const SizedBox.shrink(); // Sembunyikan jika semua sudah setoran
        }

        return Card(
          color: Colors.orange.shade50,
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                title: Text("${listSiswa.length} Santri Belum Setoran",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...listSiswa.map((s) => ListTile(
                title: Text(s.namaLengkap),
                dense: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Tambahkan navigasi ke profil/input mutabaah santri terkait
                },
              )),
            ],
          ),
        );
      },
    );
  }
}