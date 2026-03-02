import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/student_provider.dart';
import '../../kelas/providers/class_provider.dart';

class BulkPlottingDialog extends ConsumerStatefulWidget {
  const BulkPlottingDialog({super.key});

  @override
  ConsumerState<BulkPlottingDialog> createState() => _BulkPlottingDialogState();
}

class _BulkPlottingDialogState extends ConsumerState<BulkPlottingDialog> {
  String? _selectedClassId;
  final List<String> _selectedStudentIds = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Pastikan data kelas dan siswa terbaru sudah dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(classProvider).fetchClasses();
      ref.read(studentProvider).fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentProvider);
    final classState = ref.watch(classProvider);

    // Filter siswa berdasarkan pencarian
    final filteredStudents = studentState.students.where((s) {
      return s.namaLengkap.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text(
        'Plotting Santri Masal',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. PILIH KELAS TUJUAN
            const Text(
              "Pilih Kelas/Kelas Tujuan:",
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
                  value: _selectedClassId,
                  hint: const Text("Pilih UNIT KELAS"),
                  isExpanded: true,
                  items: classState.classes.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedClassId = val),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // 2. SEARCH & PILIH SISWA
            TextField(
              decoration: InputDecoration(
                hintText: "Cari nama santri...",
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
                  "${_selectedStudentIds.length} Santri Terpilih",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedStudentIds.length == filteredStudents.length) {
                        _selectedStudentIds.clear();
                      } else {
                        _selectedStudentIds.clear();
                        _selectedStudentIds.addAll(filteredStudents.map((e) => e.id!));
                      }
                    });
                  },
                  child: Text(_selectedStudentIds.length == filteredStudents.length ? "Batal Semua" : "Pilih Semua", style: const TextStyle(fontSize: 11)),
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
                child: filteredStudents.isEmpty
                    ? const Center(child: Text("Data tidak ditemukan", style: TextStyle(fontSize: 12, color: Colors.grey)))
                    : ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final s = filteredStudents[index];
                    final isChecked = _selectedStudentIds.contains(s.id);
                    return CheckboxListTile(
                      value: isChecked,
                      title: Text(s.namaLengkap, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(s.kelas?.name ?? "Belum Ada Kelas", style: const TextStyle(fontSize: 10)),
                      activeColor: const Color(0xFF4F46E5),
                      dense: true,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedStudentIds.add(s.id!);
                          } else {
                            _selectedStudentIds.remove(s.id);
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
          onPressed: (_selectedClassId == null || _selectedStudentIds.isEmpty || studentState.isLoading)
              ? null
              : _handleBulkPlotting,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: studentState.isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('SIMPAN PLOTTING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _handleBulkPlotting() async {
    final success = await ref.read(studentProvider).bulkAssignToClass(
      _selectedStudentIds,
      _selectedClassId,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil memindahkan santri!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${ref.read(studentProvider).errorMessage}"), backgroundColor: Colors.red),
        );
      }
    }
  }
}