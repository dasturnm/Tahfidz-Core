import 'package:flutter/material.dart';
import 'guru_list_screen.dart';

// Nanti Anda bisa import screen asli dari folder guru dan staff di sini:
// import '../../guru/screens/guru_list_screen.dart';
// import '../../staff/screens/staff_list_screen.dart';

class GuruStaffHubScreen extends StatelessWidget {
  const GuruStaffHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Jumlah Tab (Guru dan Staf)
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Manajemen Guru & Staf",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF10B981),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF10B981),
            indicatorWeight: 3,
            tabs: [
              Tab(
                  icon: Icon(Icons.school_outlined),
                  text: "Data Guru (Asatidz)"
              ),
              Tab(
                  icon: Icon(Icons.badge_outlined),
                  text: "Data Staf & Karyawan"
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // TODO: Ganti dengan widget Screen asli dari folder `guru`
            GuruListScreen(),

            // TODO: Ganti dengan widget Screen asli dari folder `staff`
            Center(
                child: Text(
                  "Halaman Daftar Staf Akan Tampil Di Sini",
                  style: TextStyle(color: Colors.grey),
                )
            ),
          ],
        ),
      ),
    );
  }
}