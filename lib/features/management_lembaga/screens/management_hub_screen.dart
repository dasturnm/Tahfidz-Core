import 'package:flutter/material.dart';
import 'lembaga_profile_screen.dart';
import 'cabang_list_screen.dart';
import 'divisi_screen.dart';
import 'jabatan_list_screen.dart';


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
        length: 4,
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
                    "Kelola informasi pusat, cabang, serta struktur organisasi.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                isScrollable: true,
                indicatorColor: const Color(0xFF10B981),
                labelColor: const Color(0xFF10B981),
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                indicatorWeight: 3,
                tabs: [
                  const Tab(child: Row(children: [Icon(Icons.business_outlined, size: 18), SizedBox(width: 8), Text("Profil")])),
                  const Tab(child: Row(children: [Icon(Icons.location_city_outlined, size: 18), SizedBox(width: 8), Text("Cabang")])),
                  const Tab(child: Row(children: [Icon(Icons.account_tree_outlined, size: 18), SizedBox(width: 8), Text("Divisi")])),
                  const Tab(child: Row(children: [Icon(Icons.work_outline, size: 18), SizedBox(width: 8), Text("Jabatan")])),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  const LembagaProfileScreen(),
                  const CabangListScreen(),
                  const DivisiListScreen(),
                  const JabatanListScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}