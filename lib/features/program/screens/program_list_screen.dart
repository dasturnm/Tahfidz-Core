import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/program_card.dart';
import '../models/program_model.dart';
import '../providers/program_provider.dart';
import '../widgets/academic_calendar_tab.dart';
import 'agenda_akademik_screen.dart'; // Baru: Import Agenda Screen
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
    _tabController = TabController(length: 3, vsync: this); // Update length jadi 3
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
                  const AgendaAkademikScreen(), // Baru: Sub Menu Agenda
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Manajemen Program", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text("Kurikulum, Jadwal Efektif, & Kalender.", style: TextStyle(color: Colors.grey)),
      ],
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
        Tab(text: "Agenda Akademik"), // Baru
        Tab(text: "Kalender Akademik"),
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