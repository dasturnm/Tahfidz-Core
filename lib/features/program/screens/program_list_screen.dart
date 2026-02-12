import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/program_card.dart';
import '../models/program_model.dart';
import '../providers/program_provider.dart';
import '../widgets/academic_calendar_tab.dart';
import 'program_form_screen.dart';

class ProgramListScreen extends ConsumerStatefulWidget {
  const ProgramListScreen({super.key});

  @override
  ConsumerState<ProgramListScreen> createState() => _ProgramListScreenState();
}

class _ProgramListScreenState extends ConsumerState<ProgramListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Listener untuk memperbarui UI saat tab berpindah (agar FAB berubah)
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final programsAsync = ref.watch(programNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // --- FAB DINAMIS (Sesuai Tab) ---
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgramFormScreen())),
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null, // FAB Agenda sudah ada di dalam AcademicCalendarTab atau dikontrol di sini
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildTabBar(),
            const SizedBox(height: 32),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  programsAsync.when(
                    data: (programs) => _buildKatalogGrid(programs),
                    loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                    error: (err, stack) => Center(child: Text("Gagal memuat data: $err")),
                  ),
                  const AcademicCalendarTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Manajemen Program", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Kurikulum, Jadwal Efektif, & Kalender.", style: TextStyle(color: Colors.grey)),
          ],
        ),
        IconButton(
          onPressed: () => _showConfigPeriodeDialog(context),
          icon: const Icon(Icons.settings_suggest_outlined, color: Color(0xFF10B981)),
          tooltip: "Konfigurasi Periode",
        ),
      ],
    );
  }

  // --- DIALOG KONFIGURASI PERIODE (Gambar 3) ---
  void _showConfigPeriodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.settings_suggest_outlined, size: 48, color: Color(0xFF10B981)),
            const SizedBox(height: 16),
            const Text("Konfigurasi Periode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("TAHUN AJARAN & SEMESTER", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 24),
            const Align(alignment: Alignment.centerLeft, child: Text("TAHUN AJARAN AKTIF", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: "2023/2024",
              decoration: InputDecoration(
                filled: true, fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: const [DropdownMenuItem(value: "2023/2024", child: Text("2023/2024"))],
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),
            const Align(alignment: Alignment.centerLeft, child: Text("SEMESTER AKTIF", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Semester Ganjil", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("Semester Genap", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Simpan Konfigurasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: const Color(0xFF10B981),
      labelColor: const Color(0xFF10B981),
      unselectedLabelColor: Colors.grey,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: "Daftar Katalog Program"),
        Tab(text: "Kalender Akademik & Event"),
      ],
    );
  }

  Widget _buildKatalogGrid(List<ProgramModel> programs) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 550,
        mainAxisExtent: 340,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        return ProgramCard(program: program);
      },
    );
  }
}