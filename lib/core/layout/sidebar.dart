// Lokasi: lib/core/layout/sidebar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tahfidz_core/features/auth/providers/auth_provider.dart';
import 'package:tahfidz_core/core/constants/app_routes.dart';
import 'package:tahfidz_core/core/constants/app_roles.dart'; // TAMBAHKAN INI

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final userRole = auth.userRole; // FIX: Menghapus ?? '' karena userRole tidak bisa null
    final bool isAdmin = userRole == AppRoles.admin || userRole == AppRoles.kepalaCabang || userRole == 'OWNER' || userRole == 'admin';
    final bool isGuru = userRole == AppRoles.guru;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF10B981)),
            child: Text('Tahfidz Core', style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          _buildItem(context, 'Dashboard', AppRouteNames.dashboard, Icons.dashboard_outlined),

          if (isAdmin) ...[
            const Divider(),
            _buildItem(context, 'Profil Lembaga', AppRouteNames.profilLembaga, Icons.business_outlined),
            _buildItem(context, 'Guru & Staff', AppRouteNames.staf, Icons.people_alt_outlined),
          ],

          if (isAdmin || isGuru) ...[
            const Divider(),
            _buildItem(context, 'Program Belajar', AppRouteNames.program, Icons.menu_book_outlined),
            _buildItem(context, 'Kurikulum & Level', AppRouteNames.kurikulum, Icons.assignment_outlined),
            const Divider(),
            _buildItem(context, 'Data Siswa', AppRouteNames.siswa, Icons.people_outline),
            _buildItem(context, 'Manajemen Kelas', AppRouteNames.kelas, Icons.meeting_room_outlined),
            // FIX: Mengarahkan ke Hub agar user bisa mengakses Monitoring & Ranking, bukan hanya Input
            _buildItem(context, 'Mutabaah Tahfidz', AppRouteNames.mutabaahHub, Icons.history_edu_rounded),
            _buildItem(context, 'Mushaf Digital', AppRouteNames.mushafIndex, Icons.menu_book_rounded),
          ],

          if (isAdmin) ...[
            const Divider(),
            // FIX: Menampilkan menu Keuangan yang sebelumnya belum terdaftar
            _buildItem(context, 'Manajemen Keuangan', AppRouteNames.keuanganHub, Icons.payments_outlined),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, String route, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => context.go(route),
    );
  }
}