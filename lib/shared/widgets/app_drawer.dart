// Lokasi: lib/shared/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // TAMBAHKAN INI
import 'package:tahfidz_core/core/constants/app_routes.dart'; // TAMBAHKAN INI
import '../../core/providers/app_context_provider.dart';
// Import Screen yang sudah kita buat
import '../../features/management_lembaga/screens/lembaga_profile_screen.dart';
import '../../features/management_lembaga/screens/cabang_list_screen.dart';
import '../../features/management_lembaga/screens/tahun_ajaran_screen.dart';
import '../../features/management_lembaga/screens/divisi_list_screen.dart';
import '../../features/program/widgets/academic_calendar_tab.dart'; // Baru: Import Kalender
import '../../features/program/screens/agenda_akademik_screen.dart'; // Baru: Import Agenda Screen

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextState = ref.watch(appContextProvider);
    final namaLembaga = contextState.lembaga?.namaLembaga ?? "Tahfidz Core";

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF10B981)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.mosque, color: Color(0xFF10B981), size: 40),
            ),
            accountName: Text(
              namaLembaga,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text("Administrator System"),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  label: "Dashboard",
                  onTap: () => _navigatePath(context, AppRouteNames.dashboard),
                ),

                const Divider(),
                _buildSectionHeader("MANAJEMEN LEMBAGA"),
                _buildDrawerItem(
                  icon: Icons.business_outlined,
                  label: "Profil Lembaga",
                  onTap: () => _navigate(context, const LembagaProfileScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.location_city_outlined,
                  label: "Daftar Cabang",
                  onTap: () => _navigate(context, const CabangListScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.calendar_today_outlined,
                  label: "Tahun Ajaran",
                  onTap: () => _navigate(context, const TahunAjaranScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.account_tree_outlined,
                  label: "Divisi & Jabatan",
                  onTap: () => _navigate(context, const DivisiListScreen()),
                ),

                const Divider(),
                _buildSectionHeader("KONTEKS AKADEMIK"),
                _buildDrawerItem(
                  icon: Icons.menu_book_outlined,
                  label: "Program Belajar",
                  onTap: () => _navigatePath(context, '/akademik/program'),
                ),
                _buildDrawerItem( // Baru: Menu Agenda Akademik (List View)
                  icon: Icons.format_list_bulleted, // Ikon diperbarui
                  label: "Agenda Akademik",
                  onTap: () => _navigate(context, const AgendaAkademikScreen()),
                ),
                _buildDrawerItem( // Baru: Menu Kalender Akademik (Calendar View)
                  icon: Icons.event_note, // Ikon diperbarui ke Solid
                  label: "Kalender Akademik",
                  onTap: () => _navigate(context, const AcademicCalendarTab()),
                ),
                _buildDrawerItem(
                  icon: Icons.assignment_outlined,
                  label: "Kurikulum & Level",
                  onTap: () => _navigatePath(context, AppRouteNames.kurikulum),
                ),

                const Divider(),
                _buildSectionHeader("GURU & STAFF"),
                _buildDrawerItem(
                  icon: Icons.people_alt_outlined,
                  label: "Guru & Staff",
                  onTap: () => _navigatePath(context, '/staf'),
                ),

                const Divider(),
                _buildSectionHeader("DATA SISWA"),
                _buildDrawerItem(
                  icon: Icons.face_outlined,
                  label: "Daftar Siswa",
                  onTap: () => _navigatePath(context, AppRouteNames.siswa),
                ),
                _buildDrawerItem(
                  icon: Icons.meeting_room_outlined,
                  label: "Manajemen Kelas",
                  onTap: () => _navigatePath(context, '/kelas'),
                ),

                // FIX: Tambahkan Section Mutabaah untuk menghilangkan silang merah
                const Divider(),
                _buildSectionHeader("AKTIVITAS & KEUANGAN"),
                _buildDrawerItem(
                  icon: Icons.edit_note_outlined,
                  label: "Mutabaah Tahfidz",
                  onTap: () => _navigatePath(context, AppRouteNames.mutabaahHub),
                ),
                _buildDrawerItem(
                  icon: Icons.payments_outlined,
                  label: "Keuangan",
                  onTap: () => _navigatePath(context, AppRouteNames.keuanganHub),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Tahfidz Core v1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Navigasi lama (menggunakan Widget)
  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  // SAFE UPDATE: Navigasi baru menggunakan GoRouter Path
  void _navigatePath(BuildContext context, String path) {
    Navigator.pop(context);
    context.go(path);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700], size: 24),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}