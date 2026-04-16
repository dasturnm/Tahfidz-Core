// Lokasi: lib/features/dashboard/screens/main_layout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart'; // FIX: Sinkronisasi dengan Konstanta Rute
import '../../../core/providers/app_context_provider.dart';

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
    // 🔥 FIX: Memaksa aplikasi mengambil data lembaga & profile saat pertama kali masuk
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🛡️ GUARD: Pastikan widget masih aktif sebelum menggunakan ref
      if (!mounted) return;
      ref.read(appContextProvider.notifier).initContext();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch context untuk mendapatkan programId yang aktif
    final contextState = ref.watch(appContextProvider);

    // 🔄 FIX: Tampilkan loading screen jika context sedang inisialisasi agar data tidak null saat diakses child widget
    if (contextState.isLoading) {
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
          // SIDEBAR DESKTOP
          if (!isMobile) _buildSidebarContent(contextState),

          // MAIN CONTENT AREA
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

    return Container(
      width: 280, // Sedikit lebih lebar agar nyaman
      color: Colors.white,
      child: Column(
        children: [
          // 1. HEADER SIDEBAR (MENGADOPSI GAYA APP DRAWER)
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
                      color: Colors.white.withValues(alpha: 0.2), // PERBAIKAN: withValues
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

          // 2. MENU ITEMS DENGAN SECTION HEADER
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildMenuItem(0, Icons.dashboard_outlined, "Dashboard"),

                // MENU KHUSUS ADMIN & STAFF
                if (contextState.role == 'admin' || contextState.role == 'staff') ...[
                  const Divider(height: 16),
                  _buildSectionLabel("MANAJEMEN LEMBAGA"),
                  _buildMenuItem(1, Icons.business_outlined, "Profil Lembaga"),
                  _buildMenuItem(1, Icons.location_city_outlined, "Daftar Cabang"),
                  _buildMenuItem(1, Icons.calendar_today_outlined, "Tahun Ajaran"),
                  _buildMenuItem(1, Icons.account_tree_outlined, "Divisi & Jabatan"),

                  const Divider(height: 16),
                  _buildSectionLabel("GURU & STAFF"),
                  _buildMenuItem(2, Icons.badge_outlined, "SDM & Kepegawaian"),
                ],

                // MENU AKADEMIK (ADMIN, STAFF, GURU)
                if (contextState.role != 'siswa' && contextState.role != 'wali') ...[
                  const Divider(height: 16),
                  _buildSectionLabel("KONTEKS AKADEMIK"),
                  _buildMenuItem(3, Icons.assignment_outlined, "Program & Kalender"),
                  _buildMenuItem(4, Icons.school_outlined, "Kurikulum & Level"),
                ],

                const Divider(height: 16),
                _buildSectionLabel(contextState.role == 'siswa' || contextState.role == 'wali' ? "MENU UTAMA" : "KONTEKS TAHFIDZ"),
                if (contextState.role != 'siswa' && contextState.role != 'wali') ...[
                  _buildMenuItem(5, Icons.face_outlined, "Daftar Siswa"),
                  _buildMenuItem(9, Icons.meeting_room_outlined, "Manajemen Kelas"),
                ],
                _buildMenuItem(6, contextState.role == 'siswa' || contextState.role == 'wali' ? Icons.history : Icons.history_edu_rounded, "Riwayat Mutabaah"),
                _buildMenuItem(8, Icons.menu_book_outlined, "Mushaf Al-Qur'an"),

                if (contextState.role == 'admin') ...[
                  const Divider(height: 16),
                  _buildSectionLabel("ADMINISTRASI"),
                  _buildMenuItem(7, Icons.account_balance_wallet_outlined, "Keuangan"),
                ],
              ],
            ),
          ),

          // 3. USER CARD AT THE BOTTOM
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

    // Sinkronisasi Indeks dengan URL GoRouter menggunakan AppRouteNames
    final Map<int, String> indexToPath = {
      0: AppRouteNames.dashboard,
      1: '/setup-lembaga',
      2: '/staf',
      3: '/akademik/program',
      4: AppRouteNames.kurikulum,
      5: AppRouteNames.siswa,
      6: AppRouteNames.mutabaahHub,
      7: AppRouteNames.keuanganHub,
      8: '/mushaf-index',
      9: '/kelas',
    };

    bool isSelected = indexToPath[index] == location;
    // FIX: Dashboard bisa berupa '/' (root) atau '/dashboard'
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
          color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.transparent, // PERBAIKAN: withValues
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
    final initial = profile?.namaLengkap.isNotEmpty == true ? profile!.namaLengkap[0].toUpperCase() : "?";

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
                Text(profile?.namaLengkap ?? "User", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                Text(contextState.role?.toUpperCase() ?? "GUEST", style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}