import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/staff_provider.dart';
import 'staff_form_screen.dart';
import 'staff_assignment_screen.dart'; // Import layar penugasan baru
import 'staff_detail_screen.dart'; // Import layar detail profil
import '../widgets/all_staff_grid_view.dart'; // NEW: Import widget modular

class StaffListScreen extends ConsumerWidget {
  final bool showAdminOnly; // Parameter untuk membedakan tab Guru/Admin
  const StaffListScreen({super.key, this.showAdminOnly = false});

  // --- 4. GANTI POPUP DENGAN MODAL BOTTOM SHEET ---
  void _showActionSheet(BuildContext context, dynamic staff, WidgetRef ref) {
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
                subtitle: const Text("Lihat profil lengkap personil"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffDetailScreen(staff: staff.toJson())));
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFF0FDF4), child: Icon(Icons.edit_outlined, color: Colors.teal)),
                title: const Text("Edit Biodata", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Ubah informasi dasar personil"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffFormScreen(staff: staff.toJson())));
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFFFF7ED), child: Icon(Icons.work_history_outlined, color: Colors.orange)),
                title: const Text("Kelola Jabatan", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Mutasi, Promosi, atau Rangkap"),
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau data dari staffListProvider & searchProvider
    final staffAsync = ref.watch(staffListProvider);
    final searchQuery = ref.watch(staffSearchProvider).toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: staffAsync.when(
        data: (listAll) {
          // Filter diperluas agar Admin/Owner masuk ke tab Staf Administrasi & Dukung Pencarian
          final listStaff = listAll.where((s) {
            final bool matchesRole = showAdminOnly ? s.role != 'guru' : s.role == 'guru';
            final bool matchesSearch = s.nama.toLowerCase().contains(searchQuery) ||
                (s.id.toLowerCase().contains(searchQuery) ?? false);
            return matchesRole && matchesSearch;
          }).toList();

          return listStaff.isEmpty
              ? _buildEmptyState() // 8. EMPTY STATE MENARIK
              : RefreshIndicator(
            onRefresh: () => ref.refresh(staffListProvider.future),
            // UPDATE: Menggunakan widget modular agar tampilan seragam (8 Poin Modern Desain)
            child: AllStaffGridView(
                staffList: listStaff,
                onActionTap: (staff) => _showActionSheet(context, staff, ref)
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
        error: (e, st) => Center(child: Text("Error: $e")),
      ),
    );
  }

  // --- WIDGET HELPER YANG MASIH DIGUNAKAN ---

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text("Belum ada data personil", style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Gunakan tombol + untuk menambah baru", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

// FUNGSI _buildSmallBadge DIHAPUS KARENA SUDAH ADA DI AllStaffGridView
// FUNGSI _buildActionButtons DIHAPUS KARENA SUDAH ADA DI AllStaffGridView