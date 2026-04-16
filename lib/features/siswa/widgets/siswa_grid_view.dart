// Lokasi: lib/features/siswa/widgets/siswa_grid_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart'; // Tambahan untuk integrasi WA
import '../providers/siswa_provider.dart';
// PERBAIKAN: Menghapus import '../screens/siswa_form_screen.dart'; yang tidak digunakan
import '../screens/siswa_detail_screen.dart';

class SiswaGridView extends ConsumerWidget {
  const SiswaGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX: Menggunakan siswaListProvider hasil generator
    final state = ref.watch(siswaListProvider);
    final siswaList = state.value ?? [];

    // FIX: Menyesuaikan pengecekan loading dan data dari AsyncValue
    if (state.isLoading && siswaList.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)));
    }

    if (siswaList.isEmpty) {
      return const Center(child: Text("Belum ada data siswa"));
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 100), // Ruang agar tidak tertutup FAB
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 kolom untuk tampilan grid
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 240, // Tinggi kartu dikunci agar seragam
      ),
      itemCount: siswaList.length,
      itemBuilder: (context, index) {
        final siswa = siswaList[index];
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

              // 2. INFORMASI SISWA
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
              onTap: () async {
                // Ambil nomor HP dari model (asumsi field: noHp sesuai SiswaModel)
                String phone = siswa.noHp ?? '';
                if (phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nomor WhatsApp tidak tersedia")),
                  );
                  return;
                }

                // 1. Bersihkan karakter non-digit
                phone = phone.replaceAll(RegExp(r'\D'), '');

                // 2. Format ke standar internasional (Indonesia: 62)
                if (phone.startsWith('0')) {
                  phone = '62${phone.substring(1)}';
                }

                // 3. Buat template pesan otomatis
                final message = Uri.encodeComponent(
                    "Assalamu'alaikum, Bapak/Ibu Wali dari ${siswa.namaLengkap}. "
                        "Kami dari tim Tahfidz ingin menginfokan perkembangan hafalan..."
                );

                final uri = Uri.parse("https://wa.me/$phone?text=$message");

                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Tidak bisa membuka WhatsApp")),
                    );
                  }
                }
              },
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
                  builder: (context) => SiswaDetailScreen(siswa: siswa),
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