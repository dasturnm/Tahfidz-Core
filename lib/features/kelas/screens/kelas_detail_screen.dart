// Lokasi: lib/features/kelas/screens/class_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kelas_model.dart';
import '../../siswa/models/siswa_model.dart';
import '../../siswa/providers/siswa_provider.dart';

class ClassDetailScreen extends ConsumerStatefulWidget {
  final KelasModel kelas;

  const ClassDetailScreen({super.key, required this.kelas});

  @override
  ConsumerState<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends ConsumerState<ClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Memastikan data siswa terbaru ditarik saat masuk ke halaman ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(siswaProvider).fetchSiswa();
    });
  }

  // Fungsi untuk mengeluarkan siswa dari kelas ini
  Future<void> _removeSiswa(SiswaModel siswa) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluarkan Siswa?'),
        content: Text('Apakah Anda yakin ingin mengeluarkan ${siswa.namaLengkap} dari Kelas ${widget.kelas.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluarkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Set kelasId menjadi null untuk mengeluarkan
      await ref.read(siswaProvider).assignSiswaToKelas(siswa.id!, null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${siswa.namaLengkap} berhasil dikeluarkan'), backgroundColor: const Color(0xFF4F46E5)),
        );
      }
    }
  }

  // --- MODAL PLOTTING (Memasukkan siswa yang belum punya kelas) ---
  void _showPlottingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlottingModal(kelas: widget.kelas),
    );
  }

  @override
  Widget build(BuildContext context) {
    final siswaState = ref.watch(siswaProvider);

    // Memfilter hanya siswa yang kelasId-nya sama dengan ID kelas ini
    final siswaInClass = siswaState.getSiswaInKelas(widget.kelas.id!);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.kelas.name,
              style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 18),
            ),
            Text(
              '${siswaInClass.length} Siswa Terdaftar',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: siswaState.isLoading && siswaInClass.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
          : Column(
        children: [
          // INFO WALI KELAS & PROGRAM
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(25))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.person_pin_rounded, color: Color(0xFF4F46E5)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Guru / Wali Kelas', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                      const SizedBox(height: 4),
                      Text(widget.kelas.waliKelas?.namaLengkap ?? 'Belum Ditentukan', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // DAFTAR SISWA
          Expanded(
            child: siswaInClass.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('BELUM ADA SISWA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: Colors.grey.shade400)),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: siswaInClass.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final siswa = siswaInClass[index];
                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withAlpha(25))),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: siswa.jenisKelamin == 'L' ? const Color(0xFF14B8A6) : const Color(0xFFFB7185),
                      child: Text(siswa.namaLengkap[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(siswa.namaLengkap, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Hafalan: ${siswa.totalJuzHafalan.toStringAsFixed(1)} Juz', style: const TextStyle(color: Color(0xFF0D9488), fontSize: 12, fontWeight: FontWeight.w900)),
                    trailing: IconButton(
                      icon: const Icon(Icons.output_rounded, color: Color(0xFFEF4444)),
                      tooltip: 'Keluarkan dari kelas',
                      onPressed: () => _removeSiswa(siswa),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // TOMBOL PLOTTING
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPlottingModal,
        backgroundColor: const Color(0xFF4F46E5), // Indigo
        icon: const Icon(Icons.group_add_rounded, color: Colors.white),
        label: const Text('PLOTTING SISWA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.white)),
      ),
    );
  }
}

// --- WIDGET BOTTOM SHEET MODAL UNTUK PLOTTING ---
class _PlottingModal extends ConsumerStatefulWidget {
  final KelasModel kelas;
  const _PlottingModal({required this.kelas});

  @override
  ConsumerState<_PlottingModal> createState() => _PlottingModalState();
}

class _PlottingModalState extends ConsumerState<_PlottingModal> {
  // Menyimpan daftar ID siswa yang dipilih untuk di-plot secara massal
  final Set<String> _selectedSiswaIds = {};
  bool _isProcessing = false;

  Future<void> _submitPlotting() async {
    if (_selectedSiswaIds.isEmpty) return;

    setState(() => _isProcessing = true);
    final provider = ref.read(siswaProvider);

    // Proses plotting satu per satu
    for (String id in _selectedSiswaIds) {
      await provider.assignSiswaToKelas(id, widget.kelas.id);
    }

    setState(() => _isProcessing = false);
    if (mounted) {
      Navigator.pop(context); // Tutup modal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedSiswaIds.length} Siswa berhasil ditambahkan!'), backgroundColor: const Color(0xFF4F46E5)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil daftar siswa yang BELUM punya kelas dari provider
    final unassignedSiswa = ref.watch(siswaProvider).unassignedSiswa;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // 85% tinggi layar
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle Bar (Garis kecil di atas modal)
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            width: 48,
            height: 6,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
          ),

          // Header Modal
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih Siswa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                    Text('Siswa tanpa kelas: ${unassignedSiswa.length}', style: const TextStyle(color: Color(0xFF64748B))),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Fitur Pilih Semua
                    setState(() {
                      if (_selectedSiswaIds.length == unassignedSiswa.length) {
                        _selectedSiswaIds.clear();
                      } else {
                        _selectedSiswaIds.addAll(unassignedSiswa.map((s) => s.id!));
                      }
                    });
                  },
                  child: Text(
                    _selectedSiswaIds.length == unassignedSiswa.length ? 'Batal Pilih Semua' : 'Pilih Semua',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                  ),
                )
              ],
            ),
          ),

          // Daftar Siswa Unassigned
          Expanded(
            child: unassignedSiswa.isEmpty
                ? const Center(child: Text('Semua siswa sudah masuk kelas.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))
                : ListView.builder(
              itemCount: unassignedSiswa.length,
              itemBuilder: (context, index) {
                final siswa = unassignedSiswa[index];
                final isSelected = _selectedSiswaIds.contains(siswa.id);

                return CheckboxListTile(
                  value: isSelected,
                  activeColor: const Color(0xFF4F46E5),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedSiswaIds.add(siswa.id!);
                      } else {
                        _selectedSiswaIds.remove(siswa.id);
                      }
                    });
                  },
                  title: Text(siswa.namaLengkap, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(siswa.program?.namaProgram ?? 'Tanpa Program', style: const TextStyle(fontSize: 12)),
                  secondary: CircleAvatar(
                    backgroundColor: siswa.jenisKelamin == 'L' ? const Color(0xFF14B8A6) : const Color(0xFFFB7185),
                    child: Text(siswa.namaLengkap[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                );
              },
            ),
          ),

          // Tombol Simpan Plotting
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedSiswaIds.isEmpty || _isProcessing ? null : _submitPlotting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'TAMBAHKAN ${_selectedSiswaIds.length} SISWA',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}