// Lokasi: lib/features/management_lembaga/screens/management_hub_screen.dart

import 'package:flutter/material.dart';
import 'lembaga_profile_screen.dart';
import 'cabang_list_screen.dart';
import 'divisi_list_screen.dart';
import 'jabatan_list_screen.dart';
import 'tahun_ajaran_screen.dart'; // Baru: Import Tahun Ajaran


class ManagementHubScreen extends StatelessWidget {
  const ManagementHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Manajemen Lembaga"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 5, // FIX: Sinkron dengan jumlah Tab & View
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Manajemen Lembaga",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Kelola informasi pusat, cabang, serta struktur organisasi Anda.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                isScrollable: true,
                indicatorColor: Color(0xFF10B981),
                labelColor: Color(0xFF10B981),
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                indicatorWeight: 3,
                tabs: [
                  Tab(child: Row(children: [Icon(Icons.business_outlined, size: 18), SizedBox(width: 8), Text("Profil")])),
                  Tab(child: Row(children: [Icon(Icons.location_city_outlined, size: 18), SizedBox(width: 8), Text("Cabang")])),
                  Tab(child: Row(children: [Icon(Icons.calendar_today_outlined, size: 18), SizedBox(width: 8), Text("Tahun Ajaran")])), // Baru
                  Tab(child: Row(children: [Icon(Icons.account_tree_outlined, size: 18), SizedBox(width: 8), Text("Divisi")])),
                  Tab(child: Row(children: [Icon(Icons.work_outline, size: 18), SizedBox(width: 8), Text("Jabatan")])),
                ],
              ),
            ),

            // FIX: Menggunakan Expanded agar TabBarView memiliki ruang
            const Expanded(
              child: TabBarView(
                children: [
                  LembagaProfileScreen(),
                  CabangListScreen(),
                  TahunAjaranScreen(), // Baru
                  DivisiListScreen(),
                  JabatanListScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}