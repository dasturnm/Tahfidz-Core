// Lokasi: lib/features/kelas/widgets/kelas_card_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kelas_provider.dart';
import '../screens/kelas_form_screen.dart';
import '../../siswa/providers/siswa_provider.dart'; // TAMBAHAN: Provider Siswa
import 'kelas_detail_dialog.dart'; // Import dialog baru

class ClassCardGrid extends ConsumerStatefulWidget {
  const ClassCardGrid({super.key});

  @override
  ConsumerState<ClassCardGrid> createState() => _ClassCardGridState();
}

class _ClassCardGridState extends ConsumerState<ClassCardGrid> {
  @override
  void initState() {
    super.initState();
    // FIX: fetchKelas() dihapus karena KelasListProvider (AsyncNotifier) otomatis fetch data
  }

  // --- LOGIKA HAPUS DENGAN PASSWORD ---
  void _showDeleteConfirmation(dynamic kelas) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Konfirmasi Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FIX: Menggunakan namaKelas sesuai standarisasi model terbaru
            Text("Apakah Anda yakin ingin menghapus kelas '${kelas.namaKelas}'?"),
            const SizedBox(height: 16),
            const Text("Masukkan Password Konfirmasi:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password Admin",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("BATAL")),
          ElevatedButton(
            onPressed: () async {
              // Contoh validasi sederhana, ganti dengan logic password yang benar
              if (passwordController.text == "admin123") {
                // FIX: Memanggil notifier untuk aksi delete
                await ref.read(kelasListProvider.notifier).deleteKelas(kelas.id);
                final success = !ref.read(kelasListProvider).hasError;

                // FIX: Menggunakan context.mounted check untuk menghindari async gap (use_build_context_synchronously)
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? "Kelas dihapus" : "Gagal menghapus")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Salah!")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("HAPUS"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Standard Emas UI: AsyncValue.when (Aturan v2026.03.22)
    final state = ref.watch(kelasListProvider);
    const academicColor = Color(0xFF3B82F6); // Biru Akademik (Aturan 8)

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator(color: academicColor)),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(err.toString(), style: const TextStyle(color: Colors.red)),
        ),
      ),
      data: (classes) => GridView.builder(
        padding: const EdgeInsets.only(bottom: 32),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          mainAxisExtent: 280, // Ukuran tetap agar rapi
        ),
        itemCount: classes.length + 1,
        itemBuilder: (context, index) {
          if (index == classes.length) return _buildAddClassCard();
          final kelas = classes[index];
          return _buildClassCard(kelas);
        },
      ),
    );
  }

  Widget _buildClassCard(kelas) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.08)), // PERBAIKAN: withValues
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10))], // PERBAIKAN: withValues
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ClassDetailDialog(kelas: kelas), // PERBAIKAN: Nama Class sinkron dengan dialog
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconBox(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Color(0xFFCBD5E1), size: 20),
                    onSelected: (val) {
                      if (val == 'edit') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => KelasFormScreen(existingKelas: kelas)));
                      } else if (val == 'delete') {
                        _showDeleteConfirmation(kelas);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text("Edit")])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 18), SizedBox(width: 8), Text("Hapus", style: TextStyle(color: Colors.red))])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // FIX: Menggunakan namaKelas sesuai standarisasi model terbaru
              Text(kelas.namaKelas, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              _buildGenderTag(kelas.program?.namaProgram ?? 'IKHWAN'),
              const Spacer(),
              _buildDetailRow('GURU', kelas.waliKelas?.namaLengkap ?? '-', Icons.person_outline, isTeal: false),
              _buildDetailRow('WAKTU', kelas.waktuBelajar ?? '-', Icons.access_time_rounded),
              _buildDetailRow('RUANGAN', kelas.ruangan ?? '-', Icons.business_rounded),
              // FIX: Menyisipkan jumlah siswa dari siswaListProvider
              Builder(
                  builder: (context) {
                    final studentCount = (ref.watch(siswaListProvider).value ?? [])
                        .where((s) => s.kelasId == kelas.id)
                        .length;
                    return _buildCapacityRow(studentCount, kelas.kapasitas ?? 15);
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SUB-WIDGETS SESUAI GAMBAR 3 ---
  Widget _buildIconBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.home_work_rounded, color: Color(0xFF3B82F6), size: 22),
    );
  }

  Widget _buildGenderTag(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {bool isTeal = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
          const Spacer(),
          Icon(icon, size: 12, color: isTeal ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  // FIX: Menerima parameter current agar nilai tidak di-hardcode '0'
  Widget _buildCapacityRow(int current, int max) {
    return Row(
      children: [
        const Text('KAPASITAS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
        const Spacer(),
        _buildDotProgress(),
        const SizedBox(width: 8),
        Text('$current / $max', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildDotProgress() {
    return Row(children: List.generate(3, (i) => Container(margin: const EdgeInsets.only(left: 2), width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle))));
  }

  Widget _buildAddClassCard() {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KelasFormScreen())),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFCBD5E1), width: 1)),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_rounded, color: Color(0xFF94A3B8), size: 32), SizedBox(height: 12), Text('BUAT KELAS BARU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.0))]),
      ),
    );
  }
}