// Lokasi: lib/features/siswa/widgets/student_grid_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/student_provider.dart';
// PERBAIKAN: Menghapus import '../screens/student_form_screen.dart'; yang tidak digunakan
import '../screens/student_detail_screen.dart';

class StudentGridView extends ConsumerWidget {
  const StudentGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentProvider);

    if (state.isLoading && state.students.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)));
    }

    if (state.students.isEmpty) {
      return const Center(child: Text("Belum ada data santri"));
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 100), // Ruang agar tidak tertutup FAB
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 kolom untuk tampilan grid
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 240, // Tinggi kartu dikunci agar seragam
      ),
      itemCount: state.students.length,
      itemBuilder: (context, index) {
        final siswa = state.students[index];
        bool isLakiLaki = siswa.jenisKelamin == 'L';
        String inisial = siswa.namaLengkap.isNotEmpty ? siswa.namaLengkap[0].toUpperCase() : '?';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)), // PERBAIKAN: withValues
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03), // PERBAIKAN: withValues
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BAGIAN ATAS (Avatar & Status)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAvatar(inisial, isLakiLaki),
                    _buildStatusBadge(siswa.status),
                  ],
                ),
              ),

              // 2. INFORMASI SANTRI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      siswa.namaLengkap,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "NIS: ${siswa.nisn ?? '-'}",
                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildClassInfo(siswa.kelas?.name ?? 'Tanpa Kelas'),
                  ],
                ),
              ),

              const Spacer(),

              // 3. PROGRESS BAR KECIL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("PROGRESS", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text("${siswa.totalJuzHafalan.toStringAsFixed(1)} Juz",
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF0D9488))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (siswa.totalJuzHafalan / 30).clamp(0.0, 1.0),
                      backgroundColor: const Color(0xFFF1F5F9),
                      color: const Color(0xFF0D9488),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. TOMBOL AKSI (WHATSAPP & DETAIL)
              _buildActionButtons(context, siswa),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String inisial, bool isLaki) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isLaki ? const Color(0xFF0D9488).withValues(alpha: 0.1) : const Color(0xFFFB7185).withValues(alpha: 0.1), // PERBAIKAN: withValues
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        inisial,
        style: TextStyle(
          color: isLaki ? const Color(0xFF0D9488) : const Color(0xFFFB7185),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isAktif = status.toLowerCase() == 'aktif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAktif ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: isAktif ? const Color(0xFF16A34A) : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildClassInfo(String className) {
    return Row(
      children: [
        const Icon(Icons.home_work_rounded, size: 12, color: Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            className,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic siswa) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          // Tombol WhatsApp
          Expanded(
            child: InkWell(
              onTap: () {}, // Tambahkan logic url_launcher nanti
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: const Text("WHATSAPP",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),
              ),
            ),
          ),
          Container(width: 1, height: 20, color: const Color(0xFFF1F5F9)),
          // Tombol Detail/Edit
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => StudentDetailScreen(siswa: siswa),
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: const Text("DETAIL",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}