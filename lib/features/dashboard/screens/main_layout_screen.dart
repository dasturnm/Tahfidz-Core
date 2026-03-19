import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../management_lembaga/providers/app_context_provider.dart';
import '../../management_lembaga/screens/management_hub_screen.dart';
import '../../program/screens/program_list_screen.dart';
import '../../akademik/screens/akademik_hub_screen.dart';
import '../../guru_staff/screens/staff_hub_screen.dart';
import 'dashboard_admin_screen.dart';
import '../../siswa/screens/Siswa_hub_screen.dart';
import '../../mutabaah/screens/mutabaah_hub_screen.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Watch context untuk mendapatkan programId yang aktif
    final contextState = ref.watch(appContextProvider);

    // Daftar Layar Utama (Sub-Menu) dipindahkan ke sini agar bisa akses contextState
    final List<Widget> screens = [
      const DashboardAdminScreen(),
      const ManagementHubScreen(),
      const StaffHubScreen(),
      const ProgramListScreen(),
      AkademikHubScreen(lembagaId: contextState.lembaga?.id ?? ""), // PERBAIKAN: Gunakan lembagaId
      const SiswaHubScreen(),
      const MutabaahHubScreen(),
      const Center(child: Text("Keuangan Screen")),
    ];

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
              child: screens[_selectedIndex], // Menggunakan variabel lokal screens
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

                const Divider(height: 16),
                _buildSectionLabel("MANAJEMEN LEMBAGA"),
                _buildMenuItem(1, Icons.business_outlined, "Profil Lembaga"),
                _buildMenuItem(1, Icons.location_city_outlined, "Daftar Cabang"),
                _buildMenuItem(1, Icons.calendar_today_outlined, "Tahun Ajaran"),
                _buildMenuItem(1, Icons.account_tree_outlined, "Divisi & Jabatan"),

                const Divider(height: 16),
                _buildSectionLabel("GURU & STAFF"),
                _buildMenuItem(2, Icons.badge_outlined, "SDM & Kepegawaian"),

                const Divider(height: 16),
                _buildSectionLabel("KONTEKS AKADEMIK"),
                _buildMenuItem(3, Icons.assignment_outlined, "Program & Kalender"),
                _buildMenuItem(4, Icons.school_outlined, "Kurikulum & Level"),

                const Divider(height: 16),
                _buildSectionLabel("DATA SISWA"),
                _buildMenuItem(5, Icons.face_outlined, "Daftar Siswa"),
                _buildMenuItem(5, Icons.meeting_room_outlined, "Manajemen Kelas"),
                _buildMenuItem(6, Icons.history_edu_rounded, "Mutabaah Siswa"),

                const Divider(height: 16),
                _buildSectionLabel("ADMINISTRASI"),
                _buildMenuItem(7, Icons.account_balance_wallet_outlined, "Keuangan"),
              ],
            ),
          ),

          // 3. USER CARD AT THE BOTTOM
          _buildUserCard(),
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
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
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

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFCCFBF1),
            child: Text("A", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ustadz Ahmad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("Administrator", style: TextStyle(color: Colors.grey, fontSize: 11)),
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