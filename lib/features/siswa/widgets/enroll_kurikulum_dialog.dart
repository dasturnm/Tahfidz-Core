import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../program/providers/program_provider.dart';
import '../../kurikulum/providers/kurikulum_provider.dart';
import '../providers/siswa_provider.dart';
import '../models/siswa_model.dart';

class EnrollKurikulumDialog extends ConsumerStatefulWidget {
  final SiswaModel siswa;
  const EnrollKurikulumDialog({super.key, required this.siswa});

  @override
  ConsumerState<EnrollKurikulumDialog> createState() => _EnrollKurikulumDialogState();
}

class _EnrollKurikulumDialogState extends ConsumerState<EnrollKurikulumDialog> {
  String? _selectedProgramId;
  String? _selectedKurikulumId;
  String? _selectedLevelId;

  @override
  Widget build(BuildContext context) {
    // 1. Ambil semua program yang tersedia (FIX: Menggunakan programNotifierProvider)
    final programsAsync = ref.watch(programNotifierProvider);

    return AlertDialog(
      title: const Text("Pendaftaran Kurikulum", style: TextStyle(fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Mendaftarkan: ${widget.siswa.namaLengkap}",
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),

            // STEP 1: PILIH PROGRAM
            programsAsync.when(
              data: (programs) => DropdownButtonFormField<String>(
                decoration: _inputDecoration("Pilih Program"),
                items: programs.map((p) => DropdownMenuItem(value: p.id, child: Text(p.namaProgram))).toList(),
                onChanged: (val) => setState(() {
                  _selectedProgramId = val;
                  _selectedKurikulumId = null; // Reset anak-anaknya
                  _selectedLevelId = null;
                }),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text("Gagal memuat program"),
            ),

            const SizedBox(height: 16),

            // STEP 2: PILIH KURIKULUM (Hanya muncul jika program dipilih)
            if (_selectedProgramId != null)
              ref.watch(kurikulumListProvider(_selectedProgramId!)).when(
                data: (kurikulums) => DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Pilih Kurikulum"),
                  items: kurikulums.map((k) => DropdownMenuItem(value: k.id, child: Text(k.namaKurikulum))).toList(),
                  onChanged: (val) => setState(() {
                    _selectedKurikulumId = val;
                    _selectedLevelId = null;
                  }),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text("Gagal memuat kurikulum"),
              ),

            const SizedBox(height: 16),

            // STEP 3: PILIH LEVEL AWAL (Hanya muncul jika kurikulum dipilih)
            if (_selectedKurikulumId != null)
              ref.watch(levelListProvider(_selectedKurikulumId!)).when(
                data: (levels) => DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Mulai dari Level"),
                  items: levels.map((l) => DropdownMenuItem(value: l.id, child: Text("${l.urutan}. ${l.namaLevel}"))).toList(),
                  onChanged: (val) => setState(() => _selectedLevelId = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text("Gagal memuat level"),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: _selectedLevelId == null ? null : _handleEnroll,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
          child: const Text("Daftarkan Siswa", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  void _handleEnroll() async {
    if (_selectedKurikulumId == null || _selectedLevelId == null) return;

    // Tampilkan loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
    );

    try {
      await ref.read(siswaListProvider.notifier).updateKurikulum(
        siswaId: widget.siswa.id!,
        kurikulumId: _selectedKurikulumId!,
        levelId: _selectedLevelId!,
      );

      if (mounted) {
        Navigator.pop(context); // Tutup loading
        Navigator.pop(context); // Tutup dialog pendaftaran
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil mendaftarkan siswa ke kurikulum!"),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mendaftarkan: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}