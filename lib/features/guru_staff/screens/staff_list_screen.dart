import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/staff_provider.dart';
import 'staff_form_screen.dart';
import 'staff_assignment_screen.dart'; // Import layar penugasan baru
import 'staff_detail_screen.dart'; // Import layar detail profil

class StaffListScreen extends ConsumerWidget {
  final bool showAdminOnly; // Parameter untuk membedakan tab Guru/Admin
  const StaffListScreen({super.key, this.showAdminOnly = false});

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
                (s.id?.toLowerCase().contains(searchQuery) ?? false);
            return matchesRole && matchesSearch;
          }).toList();

          return listStaff.isEmpty
              ? Center(child: Text("Belum ada data ${showAdminOnly ? 'Staf Administrasi' : 'Guru & Pengajar'}"))
              : RefreshIndicator(
            onRefresh: () => ref.refresh(staffListProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listStaff.length,
              itemBuilder: (context, index) {
                final staff = listStaff[index];
                final bool isAktif = staff.isActive;

                // Ambil data assignments untuk deteksi Hybrid/Global
                final List assignments = staff.assignments ?? [];
                final bool isGlobal = assignments.any((as) => as['cabang_id'] == 'GLOBAL' || (as['cabang']?['nama_cabang'] ?? '').contains('Pusat'));
                final bool isHybrid = assignments.length > 1;

                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        // TOP ROW: BADGES
                        Row(
                          children: [
                            if (isGlobal)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(20)),
                                child: const Row(
                                  children: [
                                    Icon(Icons.public, size: 12, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Text("GLOBAL", style: TextStyle(color: Color(0xFFB45309), fontSize: 8, fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            if (isHybrid) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                child: const Text("HYBRID", style: TextStyle(color: Color(0xFF10B981), fontSize: 8, fontWeight: FontWeight.w900)),
                              ),
                            ],
                            const Spacer(),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
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
                          ],
                        ),
                        // PROFILE SECTION
                        const SizedBox(height: 16),
                        Hero(
                          tag: 'profile_${staff.id}',
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  (() {
                                    final initials = staff.nama.trim().split(' ').where((n) => n.isNotEmpty).map((n) => n[0]).join('');
                                    return initials.toUpperCase().substring(0, initials.length >= 2 ? 2 : initials.length);
                                  })(),
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.grey),
                                ),
                              ),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: CircleAvatar(backgroundColor: isAktif ? Colors.green : Colors.red, radius: 6),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          staff.nama,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "NIP: ${staff.id?.substring(0, 8).toUpperCase() ?? '-'}",
                          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        // ASSIGNMENT CHIP
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                child: Icon(
                                  showAdminOnly ? Icons.admin_panel_settings : Icons.school,
                                  size: 16,
                                  color: Colors.teal[600],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(staff.namaJabatan ?? 'Staf', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF334155))),
                                    Text(staff.namaCabang ?? '-', style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ACTION BUTTONS
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.phone, size: 14),
                                label: const Text("KONTAK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey[700],
                                  side: BorderSide(color: Colors.grey.shade200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Mengarahkan ke StaffDetailScreen untuk melihat profil lengkap
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => StaffDetailScreen(staff: staff.toJson()),
                                  ));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("DETAIL PROFIL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Database Error: $e",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}