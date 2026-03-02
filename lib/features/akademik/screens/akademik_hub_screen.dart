import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../kurikulum/models/kurikulum_model.dart'; //
import '../kurikulum/providers/kurikulum_provider.dart'; //

// --- IMPORT NAVIGASI ---
import '../kurikulum/screens/level_list_screen.dart'; // Import untuk navigasi jenjang

class AkademikHubScreen extends ConsumerWidget {
  const AkademikHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Manajemen Akademik", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // 1. Header Modern dengan Dropdown Kurikulum
            _buildModernHeader(context),

            // 2. Tab Bar Navigation (Struktur, Pool, Penempatan)
            _buildTabBar(),

            // 3. Tab Content Area
            Expanded(
              child: TabBarView(
                children: [
                  _buildStrukturKurikulumTab(context, ref),
                  const Center(child: Text("Pool Modul Global (Segera Hadir)")),
                  const Center(child: Text("Penempatan Kelas (Segera Hadir)")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildModernHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16), // Padding atas dikurangi agar lebih compact
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teks "Manajemen Akademik" dihapus karena sudah ada di AppBar
                Text(
                  "Digitalisasi Blueprint Pendidikan Al-Qur'an",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12), // Font lebih kecil
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Filter Kurikulum dibuat JAUH lebih kecil
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            height: 32, // Tinggi dipersempit
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: "tahfidz_2026",
                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                items: const [
                  DropdownMenuItem(value: "tahfidz_2026", child: Text("TA 2026", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                ],
                onChanged: (val) {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          isScrollable: true,
          dividerColor: Colors.transparent,
          indicatorColor: const Color(0xFF10B981),
          labelColor: const Color(0xFF10B981),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          indicator: UnderlineTabIndicator(
            borderSide: const BorderSide(width: 3.0, color: Color(0xFF10B981)),
            insets: const EdgeInsets.symmetric(horizontal: 16.0),
            borderRadius: BorderRadius.circular(3),
          ),
          tabs: const [
            Tab(child: Row(children: [Icon(Icons.account_tree_outlined, size: 18), SizedBox(width: 8), Text("Struktur Kurikulum")])),
            Tab(child: Row(children: [Icon(Icons.layers_outlined, size: 18), SizedBox(width: 8), Text("Pool Modul Global")])),
            Tab(child: Row(children: [Icon(Icons.grid_view_outlined, size: 18), SizedBox(width: 8), Text("Penempatan Kelas")])),
          ],
        ),
      ),
    );
  }

  Widget _buildStrukturKurikulumTab(BuildContext context, WidgetRef ref) {
    final jenjangsAsync = ref.watch(jenjangListProvider("tahfidz_2026"));

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("1. Jenjang Pendidikan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Fase pendidikan makro kurikulum.", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _showAddJenjangDialog(context, ref, "tahfidz_2026"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(44, 44),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 24),
        jenjangsAsync.when(
          data: (list) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) => _buildJenjangCard(context, list[index]),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Gagal memuat data: $err")),
        ),
      ],
    );
  }

  // --- DIALOG TAMBAH JENJANG (SESUAI PROTOTIPE) ---

  void _showAddJenjangDialog(BuildContext context, WidgetRef ref, String kurikulumId) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.all(32),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_tree_outlined, color: Color(0xFF10B981), size: 28),
                    SizedBox(width: 12),
                    Text("Tambah Jenjang", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 32),

                const Text("NAMA JENJANG", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Contoh: Jenjang Tahfidz Lanjutan",
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),

                const SizedBox(height: 24),

                const Text("DESKRIPSI SINGKAT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Tujuan atau kriteria jenjang ini...",
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        if (nameController.text.isEmpty) return;

                        final newJenjang = JenjangModel(
                          kurikulumId: kurikulumId,
                          namaJenjang: nameController.text.trim(),
                          deskripsi: descController.text.trim(),
                        ); //

                        await ref.read(jenjangListProvider(kurikulumId).notifier).saveJenjang(newJenjang); //

                        if (context.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        print("Error: $e");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("Simpan Jenjang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJenjangCard(BuildContext context, JenjangModel item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LevelListScreen(jenjang: item)),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.account_tree_outlined, color: Color(0xFF10B981), size: 24),
            ),
            const SizedBox(height: 12),
            Text(item.namaJenjang, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Expanded(
              child: Text(item.deskripsi ?? "", style: TextStyle(color: Colors.grey[500], fontSize: 12, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${item.levels.length} LEVEL", style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11)),
                const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF10B981)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}