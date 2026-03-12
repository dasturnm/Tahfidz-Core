import 'package:flutter/material.dart';
import 'program_list_screen.dart';
import 'agenda_akademik_screen.dart';
import '../widgets/academic_calendar_tab.dart';

class ProgramHubScreen extends StatelessWidget {
  const ProgramHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text("Manajemen Program"),
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Daftar Program"),
              Tab(text: "Agenda Akademik"),
              Tab(text: "Kalender Akademik"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProgramListScreen(),
            AgendaAkademikScreen(), // List View
            AcademicCalendarTab(),   // Calendar View
          ],
        ),
      ),
    );
  }
}