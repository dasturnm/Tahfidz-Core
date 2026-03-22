import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tahfidz_core/features/auth/providers/auth_provider.dart';
import 'package:tahfidz_core/core/constants/app_routes.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final userRole = auth.userRole;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF10B981)),
            child: Text('Tahfidz Core', style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          _buildItem(context, 'Dashboard', AppRouteNames.dashboard, Icons.dashboard_outlined),

          if (userRole == 'admin') ...[
            const Divider(),
            _buildItem(context, 'Data Siswa', AppRouteNames.siswa, Icons.people_outline),
            _buildItem(context, 'Input Mutabaah', AppRouteNames.mutabaahInput, Icons.menu_book_outlined),
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