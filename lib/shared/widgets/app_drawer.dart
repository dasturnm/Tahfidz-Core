import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/management_lembaga/providers/app_context_provider.dart';
// Import Screen yang sudah kita buat
import '../../features/management_lembaga/screens/lembaga_profile_screen.dart';
import '../../features/management_lembaga/screens/cabang_list_screen.dart';
import '../../features/management_lembaga/screens/tahun_ajaran_screen.dart';
import '../../features/management_lembaga/screens/divisi_list_screen.dart';
import '../../features/guru_staff/screens/staff_list_screen.dart';
import '../../features/siswa/screens/student_hub_screen.dart';
import '../../features/program/screens/program_list_screen.dart';

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
                  onTap: () => Navigator.pop(context),
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
                  icon: Icons.account_tree_outlined,
                  label: "Divisi & Jabatan",
                  onTap: () => _navigate(context, const DivisiListScreen()),
                ),

                const Divider(),
                _buildSectionHeader("KONTEKS AKADEMIK"),
                _buildDrawerItem(
                  icon: Icons.calendar_today_outlined,
                  label: "Tahun Ajaran",
                  onTap: () => _navigate(context, const TahunAjaranScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.menu_book_outlined,
                  label: "Program Belajar",
                  onTap: () => _navigate(context, const ProgramListScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.assignment_outlined,
                  label: "Kurikulum & Level",
                  onTap: () => _navigate(context, const ProgramListScreen()),
                ),

                const Divider(),
                _buildSectionHeader("GURU & STAFF"),
                _buildDrawerItem(
                  icon: Icons.people_alt_outlined,
                  label: "Guru & Staff",
                  onTap: () => _navigate(context, const StaffListScreen()),
                ),

                const Divider(),
                _buildSectionHeader("DATA SANTRI"),
                _buildDrawerItem(
                  icon: Icons.face_outlined,
                  label: "Daftar Siswa",
                  onTap: () => _navigate(context, const StudentHubScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.meeting_room_outlined,
                  label: "Manajemen Kelas",
                  onTap: () => _navigate(context, const StudentHubScreen()),
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

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
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