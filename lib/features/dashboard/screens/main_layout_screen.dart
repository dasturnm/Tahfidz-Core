// Lokasi: lib/features/dashboard/screens/main_layout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tahfidz_core/core/constants/app_roles.dart'; // TAMBAHKAN INI
import '../../../core/constants/app_routes.dart';
import '../../../core/providers/app_context_provider.dart';
import '../../auth/providers/auth_provider.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  final Widget child;
  const MainLayoutScreen({super.key, required this.child});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(appContextProvider.notifier).initContext();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contextState = ref.watch(appContextProvider);

    if (!contextState.isInitialized && contextState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF10B981)),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1000;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Tahfidz Core", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      )
          : null,
      drawer: isMobile ? Drawer(child: _buildSidebarContent(contextState)) : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebarContent(contextState),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(AppContextState contextState) {
    final activeTA = contextState.currentTahunAjaran;
    final namaLembaga = contextState.lembaga?.namaLembaga ?? "Tahfidz Core";

    // 🛡️ SYNC ROLE LOGIC: Disamakan dengan AppDrawer
    final String role = contextState.role ?? '';
    final bool isAdmin = role == AppRoles.admin || role == AppRoles.kepalaCabang || role == 'OWNER' || role == 'admin';

    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.mosque, color: Color(0xFF10B981), size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  namaLembaga,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (activeTA != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${activeTA.labelTahun} • ${activeTA.semester.toUpperCase()}",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildMenuItem(0, Icons.dashboard_outlined, "Dashboard"),

                // KELOMPOK 1: MANAJEMEN LEMBAGA
                if (isAdmin || contextState.lembaga == null) ...[
                  const Divider(height: 8),
                  _buildSectionLabel("KONFIGURASI LEMBAGA"),
                  _buildMenuItem(1, Icons.business_outlined, "Manajemen Lembaga"), // Langsung mengarah ke Hub
                ],

                // KELOMPOK 2: BLUEPRINT AKADEMIK
                if (contextState.lembaga != null && (isAdmin || role == AppRoles.guru)) ...[
                  const Divider(height: 8),
                  _buildSectionLabel("BLUEPRINT AKADEMIK"),
                  _buildMenuItem(3, Icons.menu_book_outlined, "Program dan Kaldik"),
                  _buildMenuItem(4, Icons.assignment_outlined, "Kurikulum & Modul"),
                  _buildMenuItem(17, Icons.my_library_books_outlined, "Katalog Silabus"),
                ],

                // KELOMPOK 3: MANAJEMEN SUMBER DAYA
                if (contextState.lembaga != null && (isAdmin || role == AppRoles.guru)) ...[
                  const Divider(height: 8),
                  _buildSectionLabel("MANAJEMEN SDM & SISWA"),
                  if (isAdmin) _buildMenuItem(2, Icons.people_alt_outlined, "Guru & Staff"),
                  _buildMenuItem(9, Icons.meeting_room_outlined, "Siswa & Kelas"),
                  _buildMenuItem(20, Icons.co_present_outlined, "Presensi"),
                ],

                // KELOMPOK 4: AKTIVITAS & OUTPUT
                if (contextState.lembaga != null) ...[
                  const Divider(height: 8),
                  _buildSectionLabel("AKTIVITAS & OUTPUT"),
                  if (isAdmin || role == AppRoles.guru || role == AppRoles.wali)
                    _buildMenuItem(6, Icons.history_edu_rounded, "Mutabaah Tahfidz"),
                  if (isAdmin || role == AppRoles.guru) ...[
                    _buildMenuItem(10, Icons.verified_outlined, "Ujian Tasmi'"),
                    _buildMenuItem(18, Icons.analytics_outlined, "E-Rapor"),
                    _buildMenuItem(19, Icons.card_membership_outlined, "E-Sertifikat"),
                  ],
                  _buildMenuItem(8, Icons.menu_book_outlined, "Mushaf Digital"),
                ],

                // KELOMPOK 5: FINANSIAL & SISTEM
                if (contextState.lembaga != null && (isAdmin || role == AppRoles.wali)) ...[
                  const Divider(height: 8),
                  _buildSectionLabel("FINANSIAL & SISTEM"),
                  _buildMenuItem(7, Icons.account_balance_wallet_outlined, "Keuangan"),
                ],
              ],
            ),
          ),

          _buildUserCard(contextState),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    final location = GoRouterState.of(context).matchedLocation;

    final Map<int, String> indexToPath = {
      0: AppRouteNames.dashboard,
      1: AppRouteNames.setupLembaga, // Mengarah ke Management Hub (5 Tab)
      2: AppRouteNames.staf,
      3: AppRouteNames.program,
      4: AppRouteNames.kurikulum,
      6: AppRouteNames.mutabaahHub,
      7: AppRouteNames.keuanganHub,
      8: AppRouteNames.mushafIndex,
      9: AppRouteNames.kelas,
      10: AppRouteNames.tasmi,
      17: AppRouteNames.katalogSilabus,
      18: AppRouteNames.eRapor,
      19: AppRouteNames.eSertifikat,
      20: AppRouteNames.presensiSiswa,
    };

    bool isSelected = indexToPath[index] == location;
    if (index == 0 && (location == AppRouteNames.dashboard || location == '/dashboard')) isSelected = true;

    return InkWell(
      onTap: () {
        if (indexToPath.containsKey(index)) {
          context.go(indexToPath[index]!);
        }
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF10B981) : Colors.grey[600], size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF10B981) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(AppContextState contextState) {
    final profile = contextState.profile;

    // Tampilkan "Memuat..." jika data profil belum sedia, agar tidak langsung mem-fallback ke "User"
    final String displayName = (profile?.namaLengkap != null && profile!.namaLengkap.isNotEmpty)
        ? profile.namaLengkap
        : (contextState.isLoading ? "Memuat profil..." : "User");

    final initial = (displayName != "Memuat profil..." && displayName != "User")
        ? displayName[0].toUpperCase()
        : "?";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFCCFBF1),
            child: Text(initial, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                Text(contextState.isLoading ? "..." : (contextState.role?.toUpperCase() ?? "GUEST"), style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
            onPressed: () {
              // Pemanggilan standar logout provider
              ref.read(authProvider.notifier).logout();
            },
          )
        ],
      ),
    );
  }
}