// Lokasi: lib/features/kelas/widgets/class_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kelas_model.dart';
import '../../siswa/providers/student_provider.dart';
import '../../siswa/models/student_model.dart';

class ClassDetailDialog extends ConsumerWidget {
  final KelasModel kelas;
  const ClassDetailDialog({super.key, required this.kelas});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER - HIJAU SESUAI GAMBAR
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                  color: Color(0xFF0D9488),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28))
              ),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.home_work, color: Color(0xFF0D9488))
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kelas.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        // PERBAIKAN: Menggunakan namaLengkap (camelCase)
                        Text(
                            "Guru: ${kelas.waliKelas?.namaLengkap ?? '-'} • RUANG: ${kelas.ruangan ?? '-'}",
                            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white)
                  ),
                ],
              ),
            ),

            // LIST SANTRI
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        "DAFTAR SANTRI",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.0)
                    ),
                    const SizedBox(height: 16),
                    _buildStudentTable(ref),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTable(WidgetRef ref) {
    final students = ref.watch(studentProvider).getStudentsInClass(kelas.id ?? '');

    if (students.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(Icons.group_off_rounded, color: Color(0xFFCBD5E1), size: 40),
              SizedBox(height: 8),
              Text(
                  "Belum ada santri di kelas ini",
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildTableHeader(),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: students.length,
          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
          itemBuilder: (context, index) {
            return _buildStudentRow(index + 1, students[index]);
          },
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 30, child: Text("NO", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey))),
          Expanded(child: Text("NAMA SANTRI", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey))),
          SizedBox(width: 80, child: Text("PROGRES", textAlign: TextAlign.right, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildStudentRow(int index, StudentModel siswa) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          SizedBox(
              width: 30,
              child: Text(
                  index.toString(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))
              )
          ),
          Expanded(
              child: Text(
                siswa.namaLengkap,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
          ),
          SizedBox(
              width: 80,
              child: Text(
                  "${siswa.totalJuzHafalan.toStringAsFixed(1)} JUZ",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF0D9488))
              )
          ),
        ],
      ),
    );
  }
}