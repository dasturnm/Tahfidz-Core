// Lokasi: lib/features/akademik/evaluasi/screens/riwayat_evaluasi_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/riwayat_evaluasi_provider.dart';
import 'package:intl/intl.dart';

class RiwayatEvaluasiScreen extends ConsumerWidget {
  final String siswaId;
  final String namaSiswa;

  const RiwayatEvaluasiScreen({
    super.key,
    required this.siswaId,
    required this.namaSiswa,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau provider yang mengambil data berdasarkan siswaId
    final riwayatAsync = ref.watch(riwayatEvaluasiProvider(siswaId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Riwayat Ujian"),
        backgroundColor: const Color(0xFF3B82F6), // Biru Akademik
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Informasi Siswa
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SANTRI", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(namaSiswa, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List Riwayat Ujian
          Expanded(
            child: riwayatAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text("Terjadi kesalahan:\n$error", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                ),
              ),
              data: (riwayatList) {
                if (riwayatList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("Belum ada riwayat ujian formal.", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: riwayatList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final record = riwayatList[index];
                    final isLulus = record.isLulus;

                    // Format Tanggal
                    String tanggalStr = "-";
                    if (record.tanggalEvaluasi != null) {
                      tanggalStr = DateFormat('dd MMM yyyy, HH:mm').format(record.tanggalEvaluasi!);
                    }

                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))
                          ]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "UJIAN ${record.tipeEvaluasi}",
                                    style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                                Text(tanggalStr, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(record.namaModul ?? "Modul Tidak Diketahui", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text("Penguji: ${record.namaGuru ?? '-'}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),

                            const Divider(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Nilai Akhir", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    Text(
                                      record.nilaiAkhir.toStringAsFixed(1),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      isLulus ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                                      color: isLulus ? const Color(0xFF10B981) : Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isLulus ? "LULUS" : "REMEDIAL",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isLulus ? const Color(0xFF10B981) : Colors.red,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}