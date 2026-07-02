// Lokasi: lib/features/akademik/evaluasi/screens/kesiapan_ujian_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/kesiapan_ujian_provider.dart';
import '../../kurikulum/models/kurikulum_model.dart';

class KesiapanUjianScreen extends ConsumerWidget {
  const KesiapanUjianScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau list kesiapan ujian secara reaktif
    final kesiapanAsync = ref.watch(kesiapanUjianListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Daftar Kesiapan Ujian"),
        backgroundColor: const Color(0xFF3B82F6), // Biru Akademik sesuai AGENTS.md
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: kesiapanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
        error: (err, stack) => Center(
          child: Text("Gagal memuat data: $err", style: const TextStyle(color: Colors.red)),
        ),
        data: (siswaList) {
          if (siswaList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Belum ada santri di daftar kesiapan ujian.", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: siswaList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final siswa = siswaList[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFF3B82F6),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              siswa.namaLengkap,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "Kelas: ${siswa.kelasId ?? 'Belum Diplot'}",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                const SizedBox(width: 8),
                                // TAMBAHAN: Badge Informasi Polimorfik Tipe Ujian (Tasmi' / UKL)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (index % 2 == 0)
                                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                        : const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    (index % 2 == 0) ? "TASMI'" : "UKL",
                                    style: TextStyle(
                                      color: (index % 2 == 0) ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      locale: const Locale('id'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Menentukan tipe evaluasi secara dinamis untuk pengujian link
                          final String tipeKesiapanUjian = (index % 2 == 0) ? 'TASMI' : 'UKL';

                          // Dummy Modul untuk pengetesan form dari Admin Setting
                          final dummyModul = ModulModel(
                            id: "dummy-modul-id",
                            levelId: siswa.levelId ?? "level-id",
                            namaModul: tipeKesiapanUjian == 'TASMI' ? "Ujian Juz Eksklusif" : "Ujian Kenaikan Tingkat",
                            tipe: tipeKesiapanUjian,
                            bobotItqon: 50,
                            bobotMakhraj: 25,
                            bobotTajwid: 25,
                            kkm: 80,
                            urutan: 1,
                          );

                          // Berpindah ke Form Penilaian dengan membawa Extra Arguments lengkap
                          context.push(
                            '/akademik/tasmi',
                            extra: {
                              'siswaId': siswa.id,
                              'namaSiswa': siswa.namaLengkap,
                              'modul': dummyModul,
                              'tipeEvaluasi': tipeKesiapanUjian,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text("Uji", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}