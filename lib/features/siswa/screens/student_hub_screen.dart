// Lokasi: lib/features/siswa/screens/student_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Widgets & Screens
import '../widgets/student_table_view.dart';
import '../widgets/student_grid_view.dart'; // File baru yang akan kita buat
import '../../kelas/widgets/class_card_grid.dart';
import '../../kelas/widgets/class_table_view.dart'; // Tambahan
import 'student_form_screen.dart';
import '../../kelas/screens/class_form_screen.dart';

// Dialogs
import '../widgets/import_student_dialog.dart';
import '../widgets/bulk_plotting_dialog.dart';
import '../widgets/attendance_print_dialog.dart';
import '../widgets/student_card_print_dialog.dart';

// Providers
import '../providers/student_provider.dart';
import '../../kelas/providers/class_provider.dart'; // Tambahan

class StudentHubScreen extends ConsumerStatefulWidget {
  const StudentHubScreen({super.key});

  @override
  ConsumerState<StudentHubScreen> createState() => _StudentHubScreenState();
}

class _StudentHubScreenState extends ConsumerState<StudentHubScreen> {
  int _activeTab = 0; // 0: Santri, 1: kelas
  bool _isStudentGridView = false;
  bool _isClassGridView = true;
  final TextEditingController _searchController = TextEditingController();

  // --- LOGIKA MENU ---
  void _showActionMenu() {
    final bool isSantri = _activeTab == 0;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),

          if (isSantri) ...[
            _buildMenuTile(Icons.person_add_rounded, "Tambah Santri Baru", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentFormScreen()));
            }),
            _buildMenuTile(Icons.upload_file_rounded, "Import Santri (CSV)", () {
              Navigator.pop(context);
              showDialog(context: context, builder: (context) => const ImportStudentDialog());
            }),
            _buildMenuTile(Icons.badge_rounded, "Cetak Kartu Santri", () {
              Navigator.pop(context);
              showDialog(context: context, builder: (context) => const StudentCardPrintDialog());
            }),
          ] else ...[
            _buildMenuTile(Icons.add_home_work_rounded, "Buat Unit Kelas", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ClassFormScreen()));
            }),
            _buildMenuTile(Icons.group_add_rounded, "Plotting Massal Siswa", () {
              Navigator.pop(context);
              showDialog(context: context, builder: (context) => const BulkPlottingDialog());
            }),
            _buildMenuTile(Icons.print_rounded, "Cetak Absensi Kelas", () {
              Navigator.pop(context);
              showDialog(context: context, builder: (context) => const AttendancePrintDialog());
            }),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- LOGIKA FILTER ---
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Filter & Urutkan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Fitur filter sedang dalam pengembangan.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("TUTUP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0D9488)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER (Title & Floating Action Logic)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _buildHeader(),
            ),

            // 2. TABS (Database vs Unit)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: _buildCustomTabs(),
            ),

            // 3. SEARCH & FILTER BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSearchAndFilterRow(),
            ),

            const SizedBox(height: 24),

            // 4. MAIN CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildMainContent(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: MediaQuery.of(context).size.width < 600
          ? FloatingActionButton(
        onPressed: _showActionMenu,
        backgroundColor: const Color(0xFF0D9488),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : FloatingActionButton.extended(
        onPressed: _showActionMenu,
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(_activeTab == 0 ? "TAMBAH SANTRI" : "TAMBAH KELAS",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Siswa & Kelas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
        Text(_activeTab == 0
            ? 'Manajemen database santri dan pencatatan hafalan.'
            : 'Pengaturan unit kelas dan pembagian Guru.',
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      children: [
        // Search Bar
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                if (_activeTab == 0) {
                  ref.read(studentProvider.notifier).searchStudents(val);
                } else {
                  ref.read(classProvider.notifier).searchClasses(val); // Aktifkan pencarian kelas
                }
              },
              decoration: const InputDecoration(
                hintText: "Cari nama, NIS, atau kelas...",
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Filter Button
        _buildIconButton(Icons.filter_list_rounded, () => _showFilterBottomSheet()),
        const SizedBox(width: 8),
        // Toggle View Button
        _buildIconButton(
            (_activeTab == 0 ? _isStudentGridView : _isClassGridView) ? Icons.view_list_rounded : Icons.grid_view_rounded,
                () {
              setState(() {
                if (_activeTab == 0) {
                  _isStudentGridView = !_isStudentGridView;
                } else {
                  _isClassGridView = !_isClassGridView;
                }
              });
            }
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Icon(icon, color: const Color(0xFF64748B), size: 20),
      ),
    );
  }

  Widget _buildCustomTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'DATABASE SANTRI', Icons.people_alt_rounded),
          _buildTabItem(1, 'UNIT KELAS', Icons.home_work_rounded),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? const Color(0xFF0D9488) : Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF0D9488) : Colors.grey
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_activeTab == 0) {
      return _isStudentGridView ? const StudentGridView() : const StudentTableView();
    } else {
      return _isClassGridView ? const ClassCardGrid() : const ClassTableView();
    }
  }
}