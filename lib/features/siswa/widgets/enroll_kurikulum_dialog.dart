// Lokasi: lib/features/siswa/widgets/enroll_kurikulum_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../program/providers/program_provider.dart';
import '../../akademik/kurikulum/providers/kurikulum_provider.dart';
// FIX: Tambahkan import untuk provider jenjang dan level yang sudah dipisah
import '../../akademik/kurikulum/providers/jenjang_provider.dart';
import '../../akademik/kurikulum/providers/level_provider.dart';
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
  String? _selectedJenjangId;
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
                  _selectedJenjangId = null;
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
                    _selectedJenjangId = null;
                    _selectedLevelId = null;
                  }),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text("Gagal memuat kurikulum"),
              ),

            const SizedBox(height: 16),

            // STEP 3: PILIH JENJANG (Hanya muncul jika kurikulum dipilih) - LOGIKA 4 LAPIS
            if (_selectedKurikulumId != null)
              ref.watch(jenjangListProvider(_selectedKurikulumId!)).when(
                data: (jenjang) => DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Pilih Jenjang"),
                  items: jenjang.map((j) => DropdownMenuItem(value: j.id, child: Text(j.namaJenjang))).toList(),
                  onChanged: (val) => setState(() {
                    _selectedJenjangId = val;
                    _selectedLevelId = null;
                  }),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text("Gagal memuat jenjang"),
              ),

            const SizedBox(height: 16),

            // STEP 4: PILIH LEVEL AWAL (Sekarang watch berdasarkan Jenjang)
            if (_selectedJenjangId != null)
              ref.watch(levelListProvider(_selectedJenjangId!)).when(
                data: (level) => DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Mulai dari Level"),
                  items: level.map((l) => DropdownMenuItem(value: l.id, child: Text("${l.urutan}. ${l.namaLevel}"))).toList(),
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
    if (_selectedKurikulumId == null || _selectedJenjangId == null || _selectedLevelId == null) return;

    // Tampilkan loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
    );

    try {
      // FIX: Menggunakan siswaListProvider.notifier (AsyncNotifier) untuk update data kurikulum
      await ref.read(siswaListProvider.notifier).updateSiswa(
        widget.siswa.copyWith(
          programId: _selectedProgramId,
        ),
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