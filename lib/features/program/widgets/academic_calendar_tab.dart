import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/agenda_provider.dart';
import '../providers/program_provider.dart';
import '../providers/kalender_provider.dart'; // Baru: Import Kalender
import '../../management_lembaga/providers/tahun_ajaran_notifier.dart'; // FIX: Jalur diperbaiki
import '../../management_lembaga/providers/app_context_provider.dart';
import '../models/agenda_model.dart';

class AcademicCalendarTab extends ConsumerStatefulWidget {
  const AcademicCalendarTab({super.key});

  @override
  ConsumerState<AcademicCalendarTab> createState() => _AcademicCalendarTabState();
}

class _AcademicCalendarTabState extends ConsumerState<AcademicCalendarTab> {
  DateTime _focusedDay = DateTime.now();
  String? _selectedProgramFilter;

  @override
  Widget build(BuildContext context) {
    // UPDATE: Gunakan CalendarNotifier untuk tampilan bulanan agar lebih ringan
    final agendasAsync = ref.watch(calendarNotifierProvider(_focusedDay));
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

  // --- FUNGSI DIALOG TAMBAH AGENDA (DUAL MODE: ADD/EDIT) ---
  void _showAddAgendaDialog(BuildContext context, WidgetRef ref, {AgendaModel? agenda}) {
    final activeTA = ref.read(appContextProvider).currentTahunAjaran; // Tambah Konteks TA
    final isEdit = agenda != null;
    final nameController = TextEditingController(text: agenda?.namaAgenda);
    final keteranganController = TextEditingController(text: agenda?.keterangan);
    DateTimeRange? selectedRange = isEdit
        ? DateTimeRange(start: agenda.tanggalMulai, end: agenda.tanggalBerakhir)
        : null;
    String status = agenda?.statusHariBelajar ?? 'EFEKTIF';
    String scope = agenda?.scope ?? 'GLOBAL';
    String? targetProgramId = agenda?.programId;
    bool isSiswaLibur = agenda?.isSiswaLibur ?? false;
    bool isGuruMasuk = agenda?.isGuruMasuk ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? "Edit Agenda" : "Buat Agenda Baru", style: const TextStyle(fontWeight: FontWeight.bold)),
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
                _buildLabel("Keterangan (Opsional)"),
                TextField(
                  controller: keteranganController,
                  maxLines: 2,
                  decoration: _inputDecor("Tambahkan detail agenda..."),
                ),
                const SizedBox(height: 16),
                _buildLabel("Rentang Tanggal"),
                OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030),
                      initialDateRange: selectedRange,
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
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'EFEKTIF', child: Text("HARI EFEKTIF (Hijau)")),
                    DropdownMenuItem(value: 'LIBUR', child: Text("HARI LIBUR (Merah)")),
                  ],
                  onChanged: (val) => setDialogState(() => status = val!),
                  decoration: _inputDecor(""),
                ),
                const SizedBox(height: 16),
                _buildLabel("Pengaturan Operasional"),
                SwitchListTile(
                  title: const Text("Siswa Libur", style: TextStyle(fontSize: 13)),
                  value: isSiswaLibur,
                  dense: true,
                  onChanged: (val) => setDialogState(() => isSiswaLibur = val),
                ),
                SwitchListTile(
                  title: const Text("Guru/Staff Tetap Masuk", style: TextStyle(fontSize: 13)),
                  value: isGuruMasuk,
                  dense: true,
                  onChanged: (val) => setDialogState(() => isGuruMasuk = val),
                ),
                const SizedBox(height: 16),
                _buildLabel("Cakupan (Scope)"),
                DropdownButtonFormField<String>(
                  value: scope,
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
                      value: targetProgramId,
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
                final updatedAgenda = AgendaModel(
                  id: isEdit ? agenda.id : '',
                  lembagaId: lembagaId!,
                  tahunAjaranId: activeTA!.id, // UPDATE: Parameter wajib baru
                  namaAgenda: nameController.text.trim(),
                  tanggalMulai: selectedRange!.start,
                  tanggalBerakhir: selectedRange!.end,
                  statusHariBelajar: status,
                  scope: scope,
                  programId: targetProgramId,
                  keterangan: keteranganController.text.trim(),
                  isSiswaLibur: isSiswaLibur,
                  isGuruMasuk: isGuruMasuk,
                );

                if (isEdit) {
                  // UPDATE: Pemanggilan Family Provider (Aman karena activeTA sudah dipastikan dengan !)
                  await ref.read(agendaNotifierProvider(tahunAjaranId: activeTA.id, programId: _selectedProgramFilter).notifier).updateAgenda(updatedAgenda);
                } else {
                  // UPDATE: Pemanggilan Family Provider (Aman)
                  await ref.read(agendaNotifierProvider(tahunAjaranId: activeTA.id, programId: _selectedProgramFilter).notifier).addAgenda(updatedAgenda);
                }

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

  // --- PICKER TAHUN AJARAN (Membuat tombol di Gambar 3 berfungsi) ---
  void _showYearSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final taAsync = ref.watch(tahunAjaranNotifierProvider);
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Pilih Tahun Ajaran Aktif", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                taAsync.when(
                  data: (list) => ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final ta = list[index];
                      return ListTile(
                        leading: const Icon(Icons.calendar_today, color: Color(0xFF10B981)),
                        title: Text(ta.labelTahun, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Semester ${ta.semester}"),
                        onTap: () async {
                          await ref.read(tahunAjaranNotifierProvider.notifier).setTahunAjaranAktif(ta.id);
                          if (context.mounted) Navigator.pop(context);
                        },
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text("Error: $err"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(AsyncValue programsAsync) {
    final activeTA = ref.watch(appContextProvider).currentTahunAjaran;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // --- CHIP KONFIGURASI TAHUN AJARAN (BERFUNGSI) ---
          GestureDetector(
            onTap: () => _showYearSelectionSheet(context),
            child: Container(
              height: 48,
              constraints: const BoxConstraints(minWidth: 160), // Merapikan ukuran box
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 12),
                  Text(
                      activeTA != null
                          ? "${activeTA.labelTahun} • ${activeTA.semester.toUpperCase()}"
                          : "Pilih Tahun Ajaran",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // --- CHIP FILTER PROGRAM ---
          Container(
            height: 48,
            constraints: const BoxConstraints(minWidth: 160), // Merapikan ukuran box agar simetris
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_list, size: 16, color: Color(0xFF10B981)),
                const SizedBox(width: 12),
                programsAsync.when(
                  data: (programs) => DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedProgramFilter,
                      hint: const Text("Filter Program", style: TextStyle(fontSize: 12)),
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      items: <DropdownMenuItem<String?>>[
                        const DropdownMenuItem<String?>(value: null, child: Text("Semua Program", style: TextStyle(fontSize: 12))),
                        ...programs.map<DropdownMenuItem<String?>>((p) => DropdownMenuItem<String?>(value: p.id, child: Text(p.namaProgram, style: const TextStyle(fontSize: 12)))).toList(),
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
          calendarFormat: CalendarFormat.month,
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
          onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  AgendaModel? _getAgendaForDay(List<AgendaModel> agendas, DateTime day) {
    final date = DateTime(day.year, day.month, day.day);

    final filtered = agendas.where((a) {
      final start = DateTime(a.tanggalMulai.year, a.tanggalMulai.month, a.tanggalMulai.day);
      final end = DateTime(a.tanggalBerakhir.year, a.tanggalBerakhir.month, a.tanggalBerakhir.day);

      bool isMatchScope = (_selectedProgramFilter == null)
          ? true
          : (a.scope.toUpperCase() == 'GLOBAL' || a.programId == _selectedProgramFilter);

      bool isMatchDate = date.isAtSameMomentAs(start) ||
          date.isAtSameMomentAs(end) ||
          (date.isAfter(start) && date.isBefore(end));

      return isMatchScope && isMatchDate;
    }).toList();

    if (filtered.isEmpty) return null;

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
          const Text("AGENDA BULAN INI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 32),
          agendasAsync.when(
            data: (agendas) {
              final filteredAgendas = agendas.where((a) {
                // Cek filter Program (Filter waktu sudah dilakukan di provider)
                bool matchProg = (_selectedProgramFilter == null) ||
                    (a.scope.toUpperCase() == 'GLOBAL' || a.programId == _selectedProgramFilter);

                return matchProg;
              }).toList();

              if (filteredAgendas.isEmpty) return const Center(child: Text("Tidak ada agenda", style: TextStyle(fontSize: 12, color: Colors.grey)));

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredAgendas.length,
                itemBuilder: (context, index) {
                  final a = filteredAgendas[index];
                  final bool isLibur = a.statusHariBelajar == 'LIBUR';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.circle, size: 10, color: isLibur ? Colors.red : const Color(0xFF10B981)),
                    title: Text(a.namaAgenda, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "${a.tanggalMulai.day}/${a.tanggalMulai.month} - ${a.tanggalBerakhir.day}/${a.tanggalBerakhir.month}",
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18),
                      onSelected: (val) {
                        if (val == 'detail') _showDetailAgenda(a);
                        if (val == 'edit') _showAddAgendaDialog(context, ref, agenda: a);
                        if (val == 'delete') _confirmDelete(a.id);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'detail', child: Text('Detail')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                      ],
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

  void _showDetailAgenda(AgendaModel agenda) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(agenda.namaAgenda, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tanggal: ${agenda.tanggalMulai.day}/${agenda.tanggalMulai.month} - ${agenda.tanggalBerakhir.day}/${agenda.tanggalBerakhir.month}"),
            const SizedBox(height: 8),
            Text("Status: ${agenda.statusHariBelajar}"),
            const SizedBox(height: 8),
            Text("Siswa Libur: ${agenda.isSiswaLibur ? 'YA' : 'TIDAK'}"),
            Text("Guru Masuk: ${agenda.isGuruMasuk ? 'YA' : 'TIDAK'}"),
            const SizedBox(height: 12),
            const Text("Keterangan:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(agenda.keterangan ?? "Tidak ada keterangan"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Agenda?"),
        content: const Text("Data yang dihapus tidak dapat dikembalikan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              final activeTA = ref.read(appContextProvider).currentTahunAjaran; // Konteks TA
              // PERBAIKAN: Menghapus tanda tanya ganda '?' yang memicu warning
              if (activeTA != null) {
                await ref.read(agendaNotifierProvider(tahunAjaranId: activeTA.id, programId: _selectedProgramFilter).notifier).deleteAgenda(id);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)));
  InputDecoration _inputDecor(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)));
}