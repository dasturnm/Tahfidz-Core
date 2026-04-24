// Lokasi: lib/features/siswa/screens/siswa_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/siswa_model.dart';
import 'siswa_form_screen.dart';

class SiswaDetailScreen extends StatelessWidget {
  final SiswaModel siswa;

  const SiswaDetailScreen({super.key, required this.siswa});

  @override
  Widget build(BuildContext context) {
    bool isLaki = siswa.jenisKelamin == 'L';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Profil Siswa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          // TOMBOL EDIT DI ATAS SESUAI PERMINTAAN
          TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => SiswaFormScreen(existingSiswa: siswa),
              ));
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text("Edit"),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF0D9488)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. HEADER PROFIL
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    // FIX: Mengganti withOpacity menjadi withValues untuk standar Flutter terbaru
                    backgroundColor: isLaki ? const Color(0xFF0D9488).withValues(alpha: 0.1) : const Color(0xFFFB7185).withValues(alpha: 0.1),
                    child: Text(
                      siswa.namaLengkap[0].toUpperCase(),
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: isLaki ? const Color(0xFF0D9488) : const Color(0xFFFB7185)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(siswa.namaLengkap, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  Text("NIS: ${siswa.nisn ?? '-'}", style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. KARTU INFORMASI AKADEMIK
            _buildInfoCard(
              title: "Informasi Akademik",
              items: [
                // FIX: Menggunakan namaKelas sesuai standarisasi model terbaru
                _buildInfoTile(Icons.home_work_rounded, "Unit kelas", siswa.kelas?.namaKelas ?? 'Belum ada kelas'),
                _buildInfoTile(Icons.auto_awesome_rounded, "Program", siswa.program?.namaProgram ?? '-'),
                _buildInfoTile(Icons.trending_up_rounded, "Total Hafalan", "${siswa.totalJuzHafalan.toStringAsFixed(1)} Juz"),
              ],
            ),

            const SizedBox(height: 16),

            // 3. KARTU STATUS
            _buildInfoCard(
              title: "Status Keanggotaan",
              items: [
                _buildInfoTile(
                  Icons.verified_user_rounded,
                  "Status",
                  siswa.status.toUpperCase(),
                  valueColor: siswa.status == 'aktif' ? const Color(0xFF16A34A) : Colors.red,
                ),
                _buildInfoTile(Icons.face_retouching_natural_rounded, "Jenis Kelamin", isLaki ? "Ikhwan (Laki-laki)" : "Akhwat (Perempuan)"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // FIX: Mengganti withOpacity menjadi withValues
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 0.5)),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor ?? const Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }
}