import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/staff_provider.dart';
import 'staff_form_screen.dart';
import 'staff_assignment_screen.dart';
import 'staff_detail_screen.dart'; // Import layar detail profil

class AllStaffTableScreen extends ConsumerWidget {
  const AllStaffTableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffListProvider);
    final searchQuery = ref.watch(staffSearchProvider).toLowerCase();

    return staffAsync.when(
      data: (listStaff) {
        // Filter data berdasarkan input pencarian
        final filteredList = listStaff.where((s) {
          return s.nama.toLowerCase().contains(searchQuery) ||
              (s.id?.toLowerCase().contains(searchQuery) ?? false);
        }).toList();

        if (filteredList.isEmpty) {
          return const Center(child: Text("Belum ada data personil"));
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(staffListProvider.future),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                columns: const [
                  DataColumn(label: Text('NAMA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                  DataColumn(label: Text('ROLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                  DataColumn(label: Text('JABATAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                  DataColumn(label: Text('CABANG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                  DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                  DataColumn(label: Text('AKSI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                ],
                rows: filteredList.map((staff) {
                  return DataRow(cells: [
                    DataCell(Text(staff.nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: staff.role == 'guru' ? Colors.blue[50] : Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(staff.role == 'guru' ? "GURU" : "ADMIN", style: TextStyle(color: staff.role == 'guru' ? Colors.blue : Colors.purple, fontSize: 9, fontWeight: FontWeight.bold)),
                    )),
                    DataCell(Text(staff.namaJabatan ?? '-', style: const TextStyle(fontSize: 11))),
                    DataCell(Text(staff.namaCabang ?? '-', style: const TextStyle(fontSize: 11))),
                    DataCell(CircleAvatar(backgroundColor: staff.isActive ? Colors.green : Colors.red, radius: 5)),
                    DataCell(
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (value) {
                          if (value == 'lihat_detail') {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => StaffDetailScreen(staff: staff.toJson()),
                            ));
                          } else if (value == 'edit_bio') {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => StaffFormScreen(staff: staff.toJson()),
                            ));
                          } else if (value == 'kelola_jabatan') {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => StaffAssignmentScreen(staff: staff.toJson()),
                            ));
                          }
                        },
                        itemBuilder: (context) => const <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'lihat_detail',
                            child: Row(
                              children: [
                                Icon(Icons.visibility_outlined, color: Colors.blue, size: 20),
                                SizedBox(width: 12),
                                Text('Lihat Detail', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'edit_bio',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, color: Colors.teal, size: 20), // FIX: Menggunakan ikon standar
                                SizedBox(width: 12),
                                Text('Edit Biodata', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'kelola_jabatan',
                            child: Row(
                              children: [
                                Icon(Icons.work_history_outlined, color: Colors.orange, size: 20),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Kelola Jabatan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    Text('Mutasi, Promosi, atau Rangkap', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Error: $e")),
    );
  }
}