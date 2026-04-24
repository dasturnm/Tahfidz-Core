// Lokasi: lib/shared/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tahfidz_core/core/constants/app_routes.dart';
import 'package:tahfidz_core/core/constants/app_roles.dart';
import '../../core/providers/app_context_provider.dart';
import '../../features/auth/providers/auth_provider.dart'; // TAMBAHAN: Untuk fungsi Logout

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil state utuh untuk akses flag isInitialized
    final contextState = ref.watch(appContextProvider);
    final String role = contextState.role ?? '';
    final String namaLembaga = contextState.lembaga?.namaLembaga ?? "Tahfidz Core";
    final bool isInitialized = contextState.isInitialized;

    // SAFE UPDATE: Logika reaktif untuk displayName agar tidak stuck di 'User'
    final profile = contextState.profile;
    final String displayName = (profile?.namaLengkap != null && profile!.namaLengkap.isNotEmpty)
        ? profile.namaLengkap
        : (contextState.isLoading ? "Memuat profil..." : "User");
    final initial = (displayName != "Memuat profil..." && displayName != "User")
        ? displayName[0].toUpperCase()
        : "?";

    // OPTIMASI: Guarding - Tampilkan loading hanya saat fetch pertama kali
    if (!isInitialized && contextState.isLoading) {
      return const Drawer(child: Center(child: CircularProgressIndicator.adaptive()));
    }

    // Tambahkan 'OWNER' ke dalam kategori Admin
    final bool isAdmin = role == AppRoles.admin || role == AppRoles.kepalaCabang || role == 'OWNER' || role == 'admin';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF10B981)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(initial, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 24)),
            ),
            accountName: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(role.isEmpty ? "Belum Terkonfigurasi" : "Akses: ${role.toUpperCase()} • $namaLembaga"),
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

                // KELOMPOK 1: MANAJEMEN LEMBAGA
                if (isAdmin || contextState.lembaga == null) ...[
                  const Divider(height: 8),
                  _buildSectionHeader("KONFIGURASI LEMBAGA"),
                  _buildDrawerItem(
                    icon: Icons.business_outlined,
                    label: "Manajemen Lembaga",
                    onTap: () => _navigatePath(context, AppRouteNames.setupLembaga), // Langsung ke Hub
                  ),
                ],

                // KELOMPOK 2: BLUEPRINT AKADEMIK
                if (contextState.lembaga != null && (isAdmin || role == AppRoles.guru)) ...[
                  const Divider(height: 8),
                  _buildSectionHeader("BLUEPRINT AKADEMIK"),
                  _buildDrawerItem(
                    icon: Icons.menu_book_outlined,
                    label: "Program dan Kaldik",
                    onTap: () => _navigatePath(context, AppRouteNames.program),
                  ),
                  _buildDrawerItem(
                    icon: Icons.assignment_outlined,
                    label: "Kurikulum & Modul",
                    onTap: () => _navigatePath(context, AppRouteNames.kurikulum),
                  ),
                  _buildDrawerItem(
                    icon: Icons.my_library_books_outlined,
                    label: "Katalog Silabus",
                    onTap: () => _navigatePath(context, AppRouteNames.katalogSilabus),
                  ),
                ],

                // KELOMPOK 3: MANAJEMEN SDM & SISWA
                if (contextState.lembaga != null && (isAdmin || role == AppRoles.guru)) ...[
                  const Divider(height: 8),
                  _buildSectionHeader("MANAJEMEN SDM & SISWA"),
                  if (isAdmin)
                    _buildDrawerItem(
                      icon: Icons.people_alt_outlined,
                      label: "Guru & Staff",
                      onTap: () => _navigatePath(context, AppRouteNames.staf),
                    ),
                  _buildDrawerItem(
                    icon: Icons.meeting_room_outlined,
                    label: "Siswa & Kelas",
                    onTap: () => _navigatePath(context, AppRouteNames.kelas),
                  ),
                  _buildDrawerItem(
                    icon: Icons.co_present_outlined,
                    label: "Presensi",
                    onTap: () => _navigatePath(context, AppRouteNames.presensiSiswa),
                  ),
                ],

                // KELOMPOK 4: AKTIVITAS & OUTPUT
                if (contextState.lembaga != null) ...[
                  const Divider(height: 8),
                  _buildSectionHeader("AKTIVITAS & OUTPUT"),
                  if (isAdmin || role == AppRoles.guru || role == AppRoles.wali)
                    _buildDrawerItem(
                      icon: Icons.history_edu_rounded,
                      label: "Mutabaah Tahfidz",
                      onTap: () => _navigatePath(context, AppRouteNames.mutabaahHub),
                    ),
                  if (isAdmin || role == AppRoles.guru) ...[
                    _buildDrawerItem(
                      icon: Icons.verified_outlined,
                      label: "Ujian Tasmi'",
                      onTap: () => _navigatePath(context, AppRouteNames.tasmi),
                    ),
                    _buildDrawerItem(
                      icon: Icons.analytics_outlined,
                      label: "E-Rapor",
                      onTap: () => _navigatePath(context, AppRouteNames.eRapor),
                    ),
                    _buildDrawerItem(
                      icon: Icons.card_membership_outlined,
                      label: "E-Sertifikat",
                      onTap: () => _navigatePath(context, AppRouteNames.eSertifikat),
                    ),
                  ],
                  _buildDrawerItem(
                    icon: Icons.menu_book_outlined,
                    label: "Mushaf Digital",
                    onTap: () => _navigatePath(context, AppRouteNames.mushafIndex),
                  ),
                ],

                // KELOMPOK 5: FINANSIAL & SISTEM
                if (contextState.lembaga != null && (isAdmin || role == AppRoles.wali)) ...[
                  const Divider(height: 8),
                  _buildSectionHeader("FINANSIAL & SISTEM"),
                  _buildDrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: "Keuangan",
                    onTap: () => _navigatePath(context, AppRouteNames.keuanganHub),
                  ),
                ],

                const Divider(height: 8),
                _buildDrawerItem(
                  icon: Icons.logout,
                  label: "Logout",
                  onTap: () {
                    Navigator.pop(context); // Tutup drawer
                    ref.read(authProvider.notifier).logout(); // Panggil fungsi logout
                  },
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