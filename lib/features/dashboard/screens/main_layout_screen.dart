import 'package:flutter/material.dart';
import '../../management_lembaga/screens/management_hub_screen.dart';
import '../../program/screens/program_list_screen.dart';
import 'dashboard_admin_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardAdminScreen(),
    const ManagementHubScreen(),
    const ProgramListScreen(),
    const Center(child: Text("Akademik Screen")),
    const Center(child: Text("Siswa Screen")),
    const Center(child: Text("Keuangan Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Tentukan apakah kita harus menggunakan mode Mobile (Drawer)
    final bool isMobile = screenWidth < 1000;

    return Scaffold(
      // FIX: Jika layar sempit, Sidebar dipindah ke Drawer
      appBar: isMobile
          ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF10B981)),
        title: _buildLogo(isSmall: true),
      )
          : null,
      drawer: isMobile ? Drawer(child: _buildSidebarContent()) : null,
      body: Row(
        children: [
          // FIX: Tampilkan Sidebar permanen HANYA jika layar cukup lebar
          if (!isMobile) _buildSidebarContent(),

          // --- MAIN CONTENT AREA ---
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Container(
      width: 260,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          const SizedBox(height: 40),
          const Text("MAIN MENU", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildMenuItem(0, Icons.dashboard_outlined, "Dashboard"),
          _buildMenuItem(1, Icons.business_outlined, "Lembaga"),
          _buildMenuItem(2, Icons.assignment_outlined, "Program"),
          _buildMenuItem(3, Icons.school_outlined, "Akademik"),
          _buildMenuItem(4, Icons.people_outlined, "Siswa"),
          _buildMenuItem(5, Icons.account_balance_wallet_outlined, "Keuangan"),
          const Spacer(),
          _buildUserCard(),
        ],
      ),
    );
  }

  Widget _buildLogo({bool isSmall = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(12)),
          child: Text(
            "T",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isSmall ? 16 : 20),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Tahfidz Core",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmall ? 14 : 16, color: const Color(0xFF0F172A)),
            ),
            const Text(
              "ECOSYSTEM",
              style: TextStyle(fontSize: 8, color: Color(0xFF10B981), letterSpacing: 1.5),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        // Jika di mobile, tutup drawer setelah klik menu
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF10B981) : Colors.grey[600], size: 22),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isSelected ? const Color(0xFF10B981) : Colors.grey[600], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Row(
            children: [
              CircleAvatar(backgroundColor: Color(0xFFCCFBF1), child: Text("A", style: TextStyle(color: Color(0xFF10B981)))),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ustadz Ahmad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text("ADMIN", style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text("Sign Out", style: TextStyle(fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }
}