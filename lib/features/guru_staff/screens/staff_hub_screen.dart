import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tahfidz_core/services/guru_dan_staff_bulk_service.dart';
import 'package:tahfidz_core/features/management_lembaga/providers/app_context_provider.dart';
import 'package:tahfidz_core/features/guru_staff/providers/staff_provider.dart';
import 'staff_list_screen.dart';
import 'staff_form_screen.dart';
import 'all_staff_table_screen.dart'; // Import file baru untuk tabel
import '../widgets/assignment_timeline_wrapper.dart'; // Import Wrapper Timeline

class StaffHubScreen extends ConsumerWidget {
  const StaffHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4, // Dikembalikan menjadi 4 (Menghapus Absensi)
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
            isScrollable: true, // Mendukung scroll tab di layar mobile
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
            // SEARCH & FILTER BAR
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
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.filter_list, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // DATA LIST AREA
            Expanded(
              child: TabBarView(
                children: const [
                  AllStaffTableScreen(), // Tab 1: View Tabel (Semua)
                  StaffListScreen(),     // Tab 2: View Card Guru
                  StaffListScreen(showAdminOnly: true), // Tab 3: View Card Admin
                  AssignmentTimelineWrapper(), // Tab 4: Riwayat Penugasan Terintegrasi
                ],
              ),
            ),
          ],
        ),
        // FLOATING ACTION BUTTON
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF10B981),
          onPressed: () => _showMassActionSheet(context, ref),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
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