import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/agenda_provider.dart';
import '../providers/program_provider.dart';
import '../../management_lembaga/providers/app_context_provider.dart';
import '../models/agenda_model.dart';

class AcademicCalendarTab extends ConsumerStatefulWidget {
  const AcademicCalendarTab({super.key});

  @override
  ConsumerState<AcademicCalendarTab> createState() => _AcademicCalendarTabState();
}

class _AcademicCalendarTabState extends ConsumerState<AcademicCalendarTab> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  String? _selectedProgramFilter;

  @override
  Widget build(BuildContext context) {
    final agendasAsync = ref.watch(agendaNotifierProvider);
    final programsAsync = ref.watch(programNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      // --- TOMBOL TAMBAH AGENDA ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAgendaDialog(context, ref),
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterBar(programsAsync),
          const SizedBox(height: 24),
          Expanded(
            child: screenWidth > 900
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildCalendarCard(agendasAsync)),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildAgendaSidebar(agendasAsync)),
              ],
            )
                : ListView(
              children: [
                _buildCalendarCard(agendasAsync),
                const SizedBox(height: 24),
                _buildAgendaSidebar(agendasAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI DIALOG TAMBAH AGENDA ---
  void _showAddAgendaDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    DateTimeRange? selectedRange;
    String status = 'EFEKTIF';
    String scope = 'GLOBAL';
    String? targetProgramId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Buat Agenda Baru", style: TextStyle(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Nama Agenda"),
                TextField(
                  controller: nameController,
                  decoration: _inputDecor("Contoh: Libur Ramadhan"),
                ),
                const SizedBox(height: 16),
                _buildLabel("Rentang Tanggal"),
                OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030),
                    );
                    if (range != null) setDialogState(() => selectedRange = range);
                  },
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(selectedRange == null
                      ? "Pilih Tanggal"
                      : "${selectedRange!.start.day}/${selectedRange!.start.month} - ${selectedRange!.end.day}/${selectedRange!.end.month}"),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                ),
                const SizedBox(height: 16),
                _buildLabel("Status Hari"),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  items: const [
                    DropdownMenuItem(value: 'EFEKTIF', child: Text("HARI EFEKTIF (Hijau)")),
                    DropdownMenuItem(value: 'LIBUR', child: Text("HARI LIBUR (Merah)")),
                  ],
                  onChanged: (val) => setDialogState(() => status = val!),
                  decoration: _inputDecor(""),
                ),
                const SizedBox(height: 16),
                _buildLabel("Cakupan (Scope)"),
                DropdownButtonFormField<String>(
                  initialValue: scope,
                  items: const [
                    DropdownMenuItem(value: 'GLOBAL', child: Text("Global (Semua)")),
                    DropdownMenuItem(value: 'PROG_SPESIFIK', child: Text("Program Spesifik")),
                  ],
                  onChanged: (val) => setDialogState(() => scope = val!),
                  decoration: _inputDecor(""),
                ),
                if (scope == 'PROG_SPESIFIK') ...[
                  const SizedBox(height: 16),
                  _buildLabel("Pilih Program"),
                  ref.watch(programNotifierProvider).when(
                    data: (progs) => DropdownButtonFormField<String>(
                      items: progs.map((p) => DropdownMenuItem(value: p.id, child: Text(p.namaProgram))).toList(),
                      onChanged: (val) => setDialogState(() => targetProgramId = val),
                      decoration: _inputDecor("Pilih program"),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text("Gagal memuat program"),
                  ),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || selectedRange == null) return;

                final lembagaId = ref.read(appContextProvider).lembaga?.id;
                final newAgenda = AgendaModel(
                  id: '',
                  lembagaId: lembagaId!,
                  namaAgenda: nameController.text.trim(),
                  tanggalMulai: selectedRange!.start,
                  tanggalBerakhir: selectedRange!.end,
                  statusHariBelajar: status,
                  scope: scope,
                  programId: targetProgramId,
                );

                await ref.read(agendaNotifierProvider.notifier).addAgenda(newAgenda);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG KONFIGURASI PERIODE ---
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

  Widget _buildFilterBar(AsyncValue programsAsync) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // --- CHIP KONFIGURASI TAHUN AJARAN ---
          GestureDetector(
            onTap: () => _showConfigPeriodeDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Color(0xFF10B981)),
                  SizedBox(width: 8),
                  Text("2023/2024 • GANJIL", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.edit, size: 12, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // --- CHIP FILTER PROGRAM ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_list, size: 16, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                programsAsync.when(
                  data: (programs) => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedProgramFilter,
                      hint: const Text("Filter Program", style: TextStyle(fontSize: 12)),
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      items: [
                        const DropdownMenuItem<String>(value: null, child: Text("Semua Program", style: TextStyle(fontSize: 12))),
                        ...programs.map<DropdownMenuItem<String>>((p) => DropdownMenuItem<String>(value: p.id, child: Text(p.namaProgram, style: const TextStyle(fontSize: 12)))).toList(),
                      ],
                      onChanged: (val) => setState(() => _selectedProgramFilter = val),
                    ),
                  ),
                  loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, __) => const Text("Error"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(AsyncValue<List<AgendaModel>> agendasAsync) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: agendasAsync.when(
        data: (agendas) => TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime(2025),
          lastDay: DateTime(2030),
          calendarFormat: _calendarFormat,
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final agenda = _getAgendaForDay(agendas, day);
              if (agenda == null) return null;

              final bool isLibur = agenda.statusHariBelajar == 'LIBUR';
              return Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isLibur ? Colors.red.withValues(alpha: 0.1) : const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isLibur ? Colors.red : const Color(0xFF10B981), width: 1.5),
                ),
                child: Text("${day.day}", style: TextStyle(color: isLibur ? Colors.red : const Color(0xFF10B981), fontWeight: FontWeight.bold)),
              );
            },
          ),
          onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  AgendaModel? _getAgendaForDay(List<AgendaModel> agendas, DateTime day) {
    // Normalisasi jam agar perbandingan tanggal akurat
    final date = DateTime(day.year, day.month, day.day);

    final filtered = agendas.where((a) {
      final start = DateTime(a.tanggalMulai.year, a.tanggalMulai.month, a.tanggalMulai.day);
      final end = DateTime(a.tanggalBerakhir.year, a.tanggalBerakhir.month, a.tanggalBerakhir.day);

      bool isMatchScope = (_selectedProgramFilter == null)
          ? a.scope == 'GLOBAL'
          : (a.programId == _selectedProgramFilter || a.scope == 'GLOBAL');

      bool isMatchDate = date.isAtSameMomentAs(start) ||
          date.isAtSameMomentAs(end) ||
          (date.isAfter(start) && date.isBefore(end));

      return isMatchScope && isMatchDate;
    }).toList();

    if (filtered.isEmpty) return null;

    // Prioritas: Jika ada status LIBUR, ambil itu. Jika tidak, ambil yang pertama.
    try {
      return filtered.firstWhere((a) => a.statusHariBelajar == 'LIBUR');
    } catch (_) {
      return filtered.first;
    }
  }

  Widget _buildAgendaSidebar(AsyncValue<List<AgendaModel>> agendasAsync) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("AGENDA AKADEMIK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 32),
          agendasAsync.when(
            data: (agendas) {
              final currentMonthAgendas = agendas.where((a) => a.tanggalMulai.month == _focusedDay.month).toList();
              if (currentMonthAgendas.isEmpty) return const Center(child: Text("Tidak ada agenda", style: TextStyle(fontSize: 12, color: Colors.grey)));

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentMonthAgendas.length,
                itemBuilder: (context, index) {
                  final a = currentMonthAgendas[index];
                  final bool isLibur = a.statusHariBelajar == 'LIBUR';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.circle, size: 10, color: isLibur ? Colors.red : const Color(0xFF10B981)),
                    title: Text(a.namaAgenda, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "${a.tanggalMulai.day} - ${a.tanggalBerakhir.day} ${_getMonthName(a.tanggalMulai.month)}",
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) => ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month - 1];
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)));
  InputDecoration _inputDecor(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)));
}