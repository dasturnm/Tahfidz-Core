import 'package:flutter/material.dart';

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildStatCard(screenWidth, "TOTAL SISWA", "24", "+2 Siswa Baru", Icons.people_outline, Colors.blue),
                _buildStatCard(screenWidth, "RATA-RATA HAFALAN", "4.2 Juz", "On Track Target", Icons.book_outlined, const Color(0xFF10B981)),
                _buildStatCard(screenWidth, "SISWA LULUS UJIAN", "12", "Bulan Februari", Icons.workspace_premium_outlined, Colors.purple),
                _buildStatCard(screenWidth, "DURASI kelas", "2.5 Jam", "Harian Efektif", Icons.timer_outlined, Colors.orange),
              ],
            ),

            const SizedBox(height: 32),

            screenWidth > 900
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildActivityChart()),
                const SizedBox(width: 32),
                Expanded(flex: 1, child: _buildTopSiswaList()),
              ],
            )
                : Column(
              children: [
                _buildActivityChart(),
                const SizedBox(height: 32),
                _buildTopSiswaList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // FIX: Mengganti Row dengan Wrap agar Header tidak overflow di layar sempit
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ahlan wa Sahlan, Ustadz! 👋",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              "Berikut ringkasan ekosistem Tahfidz Anda hari ini.",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        _buildLiveBadge(),
      ],
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
          SizedBox(width: 8),
          Text("LIVE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        ],
      ),
    );
  }

  Widget _buildStatCard(double screenWidth, String title, String value, String sub, IconData icon, Color color) {
    // FIX: Hitung lebar berdasarkan area konten (lebar layar - estimasi sidebar)
    double contentArea = screenWidth > 900 ? screenWidth - 260 : screenWidth;
    double cardWidth = screenWidth > 1200
        ? (contentArea - 120) / 4
        : screenWidth > 600 ? (contentArea - 80) / 2 : contentArea - 64;

    return Container(
      width: cardWidth > 200 ? cardWidth : 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              const Text("LIVE", style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(sub, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Aktivitas Mingguan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Perbandingan Ziyadah vs Murojaah", style: TextStyle(color: Colors.grey, fontSize: 13)),
          Spacer(),
          Center(child: Text("[Bar Chart Widget]", style: TextStyle(color: Colors.grey))),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildTopSiswaList() {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 400,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Top Siswa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildSiswaItem("1", "Abdurrahman Al-Fatih", "12 JUZ", "95%"),
          _buildSiswaItem("2", "Siti Maryam", "8 JUZ", "88%"),
          _buildSiswaItem("3", "Muhammad Ali", "5 JUZ", "82%"),
          _buildSiswaItem("4", "Zaid bin Tsabit", "15 JUZ", "78%"),
        ],
      ),
    );
  }

  Widget _buildSiswaItem(String rank, String name, String juz, String percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Text(rank, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                Text(juz, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(percent, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
        ],
      ),
    );
  }
}