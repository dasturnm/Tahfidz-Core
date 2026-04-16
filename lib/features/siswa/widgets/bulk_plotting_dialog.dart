// Lokasi: lib/features/siswa/widgets/bulk_plotting_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/siswa_provider.dart';
import '../../kelas/providers/kelas_provider.dart';

class BulkPlottingDialog extends ConsumerStatefulWidget {
  const BulkPlottingDialog({super.key});

  @override
  ConsumerState<BulkPlottingDialog> createState() => _BulkPlottingDialogState();
}

class _BulkPlottingDialogState extends ConsumerState<BulkPlottingDialog> {
  String? _selectedKelasId; // PERBAIKAN: Label Kelas
  final List<String> _selectedSiswaIds = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Pastikan data kelas dan siswa terbaru sudah dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // FIX: Menggunakan notifier dari siswaListProvider sesuai arsitektur modern
      ref.read(siswaListProvider.notifier).fetchSiswa();
    });
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Menggunakan siswaListProvider (AsyncValue) hasil generator
    final siswaState = ref.watch(siswaListProvider);
    // FIX: Menggunakan kelasListProvider (AsyncValue)
    final kelasAsync = ref.watch(kelasListProvider);

    // Filter siswa berdasarkan pencarian
    // FIX: Mengakses list data melalui siswaState.value
    final filteredSiswa = (siswaState.value ?? []).where((s) {
      return s.namaLengkap.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text(
        'Plotting Siswa Masal',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. PILIH KELAS TUJUAN
            const Text(
              "Pilih Unit Kelas Tujuan:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedKelasId,
                  hint: const Text("Pilih UNIT KELAS"),
                  isExpanded: true,
                  // FIX: Menangani data list dari AsyncValue (kelasListProvider)
                  items: (kelasAsync.value ?? []).map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedKelasId = val),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // 2. SEARCH & PILIH SISWA
            TextField(
              decoration: InputDecoration(
                hintText: "Cari nama siswa...",
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_selectedSiswaIds.length} siswa Terpilih",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedSiswaIds.length == filteredSiswa.length) {
                        _selectedSiswaIds.clear();
                      } else {
                        _selectedSiswaIds.clear();
                        _selectedSiswaIds.addAll(filteredSiswa.map((e) => e.id!));
                      }
                    });
                  },
                  child: Text(_selectedSiswaIds.length == filteredSiswa.length ? "Batal Semua" : "Pilih Semua", style: const TextStyle(fontSize: 11)),
                )
              ],
            ),

            // LIST SISWA DENGAN CHECKBOX
            Flexible(
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: filteredSiswa.isEmpty
                    ? const Center(child: Text("Data tidak ditemukan", style: TextStyle(fontSize: 12, color: Colors.grey)))
                    : ListView.builder(
                  itemCount: filteredSiswa.length,
                  itemBuilder: (context, index) {
                    final s = filteredSiswa[index];
                    final isChecked = _selectedSiswaIds.contains(s.id);
                    return CheckboxListTile(
                      value: isChecked,
                      title: Text(s.namaLengkap, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(s.kelas?.name ?? "Belum Ada Kelas", style: const TextStyle(fontSize: 10)), // PERBAIKAN: Relasi Kelas
                      activeColor: const Color(0xFF4F46E5),
                      dense: true,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedSiswaIds.add(s.id!);
                          } else {
                            _selectedSiswaIds.remove(s.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: (_selectedKelasId == null || _selectedSiswaIds.isEmpty || siswaState.isLoading)
              ? null
              : _handleBulkPlotting,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: siswaState.isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('SIMPAN PLOTTING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _handleBulkPlotting() async {
    // FIX: Memanggil aksi melalui notifier siswaListProvider
    final success = await ref.read(siswaListProvider.notifier).bulkAssignToKelas(
      _selectedSiswaIds,
      _selectedKelasId,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil memindahkan siswa!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          // FIX: Mengambil pesan error dari state AsyncValue
          SnackBar(content: Text("Gagal: ${ref.read(siswaListProvider).error}"), backgroundColor: Colors.red),
        );
      }
    }
  }
}