// Lokasi: lib/features/kelas/widgets/kelas_table_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kelas_provider.dart';
import '../screens/kelas_form_screen.dart';
import '../../siswa/providers/siswa_provider.dart'; // TAMBAHAN: Import provider siswa

class ClassTableView extends ConsumerStatefulWidget {
  const ClassTableView({super.key});

  @override
  ConsumerState<ClassTableView> createState() => _ClassTableViewState();
}

class _ClassTableViewState extends ConsumerState<ClassTableView> {
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
    // FIX: Menggunakan kelasListProvider (AsyncValue)
    final state = ref.watch(kelasListProvider);
    final classes = state.value ?? [];

    if (state.isLoading && classes.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)), // PERBAIKAN: withValues
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02), // PERBAIKAN: withValues
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 650,
            child: Column(
              children: [
                _buildHeader(),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: classes.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF8FAFC)),
                    itemBuilder: (context, index) {
                      final kelas = classes[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // FIX: Menggunakan namaKelas sesuai standarisasi model terbaru
                                  Text(kelas.namaKelas,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1E293B))),
                                  Text(kelas.program?.namaProgram ?? 'UMUM',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(kelas.waliKelas?.namaLengkap ?? '-',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, size: 10, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(kelas.waktuBelajar ?? '-',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.business_rounded, size: 10, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(kelas.ruangan ?? '-',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Builder(builder: (context) {
                                // FIX: Menghitung jumlah siswa yang memiliki kelas_id sama dengan kelas ini
                                final studentCount = (ref.watch(siswaListProvider).value ?? [])
                                    .where((s) => s.kelasId == kelas.id)
                                    .length;

                                return Text("$studentCount/${kelas.kapasitas ?? 15}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)));
                              }),
                            ),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8), size: 20),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => KelasFormScreen(existingKelas: kelas)));
                                } else if (value == 'delete') {
                                  _showDeleteConfirmation(kelas);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: Colors.orange), SizedBox(width: 8), Text("Edit Kelas", style: TextStyle(fontSize: 13))]),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text("Hapus Kelas", style: TextStyle(color: Colors.red, fontSize: 13))]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFF8FAFC),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text("NAMA KELAS", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5))),
          Expanded(flex: 2, child: Text("GURU", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5))),
          Expanded(flex: 2, child: Text("WAKTU & RUANG", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5))),
          Expanded(flex: 1, child: Text("SLOT", textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5))),
          SizedBox(width: 40),
        ],
      ),
    );
  }
}