import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahfidz_core/services/guru_dan_staff_bulk_service.dart';
import 'package:tahfidz_core/features/management_lembaga/providers/app_context_provider.dart';
import 'package:tahfidz_core/features/guru_staff/providers/staff_provider.dart';
import 'staff_form_screen.dart';
// PERBAIKAN: Baris import all_staff_table_screen.dart DIHAPUS karena file akan dihapus
import '../widgets/assignment_timeline_wrapper.dart';
import '../widgets/all_staff_grid_view.dart';
import '../widgets/all_staff_table_view.dart';
import 'staff_assignment_screen.dart';
import 'staff_detail_screen.dart';

class StaffHubScreen extends ConsumerStatefulWidget {
  const StaffHubScreen({super.key});

  @override
  ConsumerState<StaffHubScreen> createState() => _StaffHubScreenState();
}

class _StaffHubScreenState extends ConsumerState<StaffHubScreen> {
  bool isGridView = true; // State untuk toggle tampilan

  // --- 2. FUNGSI FILTER (Aktifkan Filter) ---
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Filter Personil", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 20),
            const Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                FilterChip(label: const Text("Aktif"), onSelected: (b) {}, selected: true, selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2)),
                const SizedBox(width: 8),
                FilterChip(label: const Text("Non-Aktif"), onSelected: (b) {}),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Terapkan Filter", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- FUNGSI AKSI INDIVIDUAL (Untuk Grid/Table View) ---
  void _showStaffActionSheet(BuildContext context, dynamic staff, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFE0F2FE), child: Icon(Icons.visibility_outlined, color: Colors.blue)),
                title: const Text("Lihat Detail", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffDetailScreen(staff: staff.toJson())));
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFF0FDF4), child: Icon(Icons.edit_outlined, color: Colors.teal)),
                title: const Text("Edit Biodata", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffFormScreen(staff: staff.toJson())));
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFFFF7ED), child: Icon(Icons.work_history_outlined, color: Colors.orange)),
                title: const Text("Kelola Jabatan", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffAssignmentScreen(staff: staff.toJson())));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SDM & Personalia",
                style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 20),
              ),
              Text(
                "Manajemen terpadu personil organisasi",
                style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFF10B981),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF10B981),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: [
              Tab(text: "Semua Staf"),
              Tab(text: "Guru / Pengajar"),
              Tab(text: "Staf Administrasi"),
              Tab(text: "Riwayat Penugasan"),
            ],
          ),
        ),
        body: Column(
          children: [
            // 3. PERBAIKAN LETAK IKON: Kolom Pencarian | Filter | Ganti View
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onChanged: (val) => ref.read(staffSearchProvider.notifier).updateQuery(val),
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: "Cari personil...",
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // --- IKON FILTER (Sekarang Berfungsi) ---
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.filter_list, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // --- IKON GANTI VIEW ---
                  GestureDetector(
                    onTap: () => setState(() => isGridView = !isGridView),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Icon(
                        isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // DATA LIST AREA
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Semua Staf
                  _buildFilteredView(null),
                  // 1. PERBAIKAN VIEW GURU: Mengikuti Toggle
                  _buildFilteredView('guru'),
                  // 1. PERBAIKAN VIEW ADMIN: Mengikuti Toggle
                  _buildFilteredView('admin'),
                  // Tab 4: Riwayat Penugasan (Biasanya Timeline Tetap)
                  const AssignmentTimelineWrapper(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF10B981),
          onPressed: () => _showMassActionSheet(context, ref),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // HELPER UNTUK FILTER DATA & TOGGLE VIEW
  Widget _buildFilteredView(String? roleFilter) {
    return ref.watch(staffListProvider).when(
      data: (list) {
        final query = ref.watch(staffSearchProvider).toLowerCase();
        final filtered = list.where((s) {
          final bool matchesSearch = s.nama.toLowerCase().contains(query) || (s.id.toLowerCase().contains(query) ?? false);
          if (roleFilter == null) return matchesSearch;
          if (roleFilter == 'guru') return matchesSearch && s.role == 'guru';
          return matchesSearch && s.role != 'guru';
        }).toList();

        return isGridView
            ? AllStaffGridView(staffList: filtered, onActionTap: (staff) => _showStaffActionSheet(context, staff, ref))
            : AllStaffTableView(staffList: filtered, onActionTap: (staff) => _showStaffActionSheet(context, staff, ref));
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
      error: (e, _) => Center(child: Text("Error: $e")),
    );
  }

  void _showMassActionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const Text("Aksi Personalia", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF10B981)),
                title: const Text("Input Manual", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffFormScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file_outlined, color: Colors.indigo),
                title: const Text("Input Manual (CSV)", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(context);
                  final lembagaId = ref.read(appContextProvider).lembaga?.id ?? '';
                  await ref.read(guruDanStaffBulkServiceProvider).importDariCsv(
                    lembagaId: lembagaId,
                    defaultJabatanId: '',
                    defaultCabangId: '',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.download_for_offline_outlined, color: Colors.teal),
                title: const Text("Export Data (CSV)", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(context);
                  final listStaff = ref.read(staffListProvider).value ?? [];
                  await ref.read(guruDanStaffBulkServiceProvider).exportKeCsv(listStaff);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}