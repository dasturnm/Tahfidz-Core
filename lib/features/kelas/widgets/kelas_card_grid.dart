// Lokasi: lib/features/kelas/widgets/kelas_card_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kelas_provider.dart';
import '../screens/kelas_form_screen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kelasProvider).fetchKelas();
    });
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
            Text("Apakah Anda yakin ingin menghapus kelas '${kelas.name}'?"),
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
                final success = await ref.read(kelasProvider).deleteKelas(kelas.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? "Kelas dihapus" : "Gagal menghapus")),
                  );
                }
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
    final state = ref.watch(kelasProvider);

    if (state.isLoading && state.kelas.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)));
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 32),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 280, // Ukuran tetap agar rapi
      ),
      itemCount: state.kelas.length + 1,
      itemBuilder: (context, index) {
        if (index == state.kelas.length) return _buildAddClassCard();
        final kelas = state.kelas[index];
        return _buildClassCard(kelas);
      },
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
              Text(kelas.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              _buildGenderTag(kelas.program?.namaProgram ?? 'IKHWAN'),
              const Spacer(),
              _buildDetailRow('GURU', kelas.waliKelas?.namaLengkap ?? '-', Icons.person_outline, isTeal: false),
              _buildDetailRow('WAKTU', kelas.waktuBelajar ?? '-', Icons.access_time_rounded),
              _buildDetailRow('RUANGAN', kelas.ruangan ?? '-', Icons.business_rounded),
              _buildCapacityRow(kelas.kapasitas ?? 15),
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
      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.home_work_rounded, color: Color(0xFF0D9488), size: 22),
    );
  }

  Widget _buildGenderTag(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF0D9488), shape: BoxShape.circle)),
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
          Icon(icon, size: 12, color: isTeal ? const Color(0xFF0D9488) : const Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  Widget _buildCapacityRow(int max) {
    return Row(
      children: [
        const Text('KAPASITAS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
        const Spacer(),
        _buildDotProgress(),
        const SizedBox(width: 8),
        Text('0 / $max', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
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