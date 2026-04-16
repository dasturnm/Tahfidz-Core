// Lokasi: lib/features/program/screens/agenda_akademik_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/agenda_provider.dart';
import '../providers/program_provider.dart';
import '../../../core/providers/app_context_provider.dart';
// FIX: Menggunakan absolute import agar sinkron dengan lokasi model yang baru
import 'package:tahfidz_core/features/program/models/agenda_model.dart';

class AgendaAkademikScreen extends ConsumerStatefulWidget {
  const AgendaAkademikScreen({super.key});

  @override
  ConsumerState<AgendaAkademikScreen> createState() => _AgendaAkademikScreenState();
}

class _AgendaAkademikScreenState extends ConsumerState<AgendaAkademikScreen> {
  String? _selectedProgramFilter;
  int? _selectedMonthFilter = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    final activeTA = ref.watch(appContextProvider).currentTahunAjaran;
    // FIX: Memberikan default value '' untuk menghindari error argument_type_not_assignable
    final agendasAsync = ref.watch(agendaNotifierProvider(
        tahunAjaranId: activeTA?.id ?? '',
        programId: _selectedProgramFilter
    ));
    final programsAsync = ref.watch(programNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAgendaDialog(context, ref),
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterBar(programsAsync),
          Expanded(
            child: agendasAsync.when(
              data: (agendas) {
                final filteredAgendas = agendas.where((a) {
                  bool matchMonth = _selectedMonthFilter == null || a.tanggalMulai.month == _selectedMonthFilter;
                  return matchMonth;
                }).toList();

                if (filteredAgendas.isEmpty) {
                  return const Center(child: Text("Tidak ada agenda yang ditemukan.", style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredAgendas.length,
                  itemBuilder: (context, index) {
                    final a = filteredAgendas[index];
                    final bool isLibur = a.statusHariBelajar == 'LIBUR';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isLibur ? Colors.red.withValues(alpha: 0.1) : const Color(0xFF10B981).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isLibur ? Icons.block : Icons.event_available,
                            color: isLibur ? Colors.red : const Color(0xFF10B981),
                            size: 20,
                          ),
                        ),
                        title: Text(a.namaAgenda, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "${a.tanggalMulai.day}/${a.tanggalMulai.month} - ${a.tanggalBerakhir.day}/${a.tanggalBerakhir.month}",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            if (a.keterangan != null && a.keterangan!.isNotEmpty)
                              Text(a.keterangan!, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'detail') _showDetailAgenda(a);
                            if (val == 'edit') _showAddAgendaDialog(context, ref, agenda: a);
                            if (val == 'delete') _confirmDelete(a.id ?? '');
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'detail', child: Text('Detail')),
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(AsyncValue programsAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildDropdownContainer(
              icon: Icons.calendar_month,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: _selectedMonthFilter,
                  hint: const Text("Pilih Bulan", style: TextStyle(fontSize: 12)),
                  items: <DropdownMenuItem<int?>>[
                    const DropdownMenuItem<int?>(value: null, child: Text("Semua Bulan", style: TextStyle(fontSize: 12))),
                    ...List.generate(12, (index) => DropdownMenuItem<int?>(
                      value: index + 1,
                      child: Text(_getMonthName(index + 1), style: const TextStyle(fontSize: 12)),
                    )),
                  ],
                  onChanged: (val) => setState(() => _selectedMonthFilter = val),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildDropdownContainer(
              icon: Icons.filter_list,
              child: programsAsync.when(
                data: (programs) => DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedProgramFilter,
                    hint: const Text("Filter Program", style: TextStyle(fontSize: 12)),
                    items: <DropdownMenuItem<String?>>[
                      const DropdownMenuItem<String?>(value: null, child: Text("Semua Program", style: TextStyle(fontSize: 12))),
                      ...programs.map((p) => DropdownMenuItem<String?>(
                        value: p.id,
                        child: Text(p.namaProgram, style: const TextStyle(fontSize: 12)),
                      )),
                    ],
                    onChanged: (val) => setState(() => _selectedProgramFilter = val),
                  ),
                ),
                loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const Text("Error"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({required IconData icon, required Widget child}) {
    return Container(
      height: 48,
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF10B981)),
          const SizedBox(width: 12),
          child,
        ],
      ),
    );
  }

  void _showDetailAgenda(AgendaModel agenda) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(agenda.namaAgenda, style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Rentang Waktu"),
            Text("${agenda.tanggalMulai.day}/${agenda.tanggalMulai.month} - ${agenda.tanggalBerakhir.day}/${agenda.tanggalBerakhir.month}"),
            const SizedBox(height: 16),
            _buildLabel("Status Hari"),
            Text(agenda.statusHariBelajar == 'LIBUR' ? "HARI LIBUR" : "HARI EFEKTIF"),
            const SizedBox(height: 16),
            _buildLabel("Informasi Operasional"),
            Text("• Siswa Libur: ${agenda.isSiswaLibur ? 'Ya' : 'Tidak'}"),
            Text("• Guru Tetap Masuk: ${agenda.isGuruMasuk ? 'Ya' : 'Tidak'}"),
            const SizedBox(height: 16),
            _buildLabel("Keterangan"),
            Text(agenda.keterangan?.isNotEmpty == true ? agenda.keterangan! : "-"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup")),
        ],
      ),
    );
  }

  void _showAddAgendaDialog(BuildContext context, WidgetRef ref, {AgendaModel? agenda}) {
    final activeTA = ref.read(appContextProvider).currentTahunAjaran;
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

    bool isRecurring = false;
    DateTime? untilDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final programs = ref.watch(programNotifierProvider).value ?? [];

          return AlertDialog(
            title: Text(isEdit ? "Edit Agenda" : "Buat Agenda Baru", style: const TextStyle(fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nama Agenda"),
                  TextField(controller: nameController, decoration: _inputDecor("Contoh: Rapat Rutin Guru")),
                  const SizedBox(height: 16),

                  _buildLabel("Jangkauan Agenda"),
                  DropdownButtonFormField<String>(
                    // FIX: Dropdown menggunakan 'value' bukan 'initialValue'
                    initialValue: scope,
                    items: const [
                      DropdownMenuItem(value: 'GLOBAL', child: Text("🌍 Seluruh Program")),
                      DropdownMenuItem(value: 'PROG_SPESIFIK', child: Text("🎯 Program Spesifik")),
                    ],
                    onChanged: (val) => setDialogState(() => scope = val!),
                    decoration: _inputDecor(""),
                  ),
                  const SizedBox(height: 12),

                  if (scope == 'PROG_SPESIFIK') ...[
                    _buildLabel("Pilih Program"),
                    DropdownButtonFormField<String>(
                      // FIX: Dropdown menggunakan 'value' bukan 'initialValue'
                      initialValue: targetProgramId,
                      items: programs.map((p) => DropdownMenuItem(value: p.id, child: Text(p.namaProgram))).toList(),
                      onChanged: (val) => setDialogState(() => targetProgramId = val),
                      decoration: _inputDecor("Pilih target program"),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildLabel("Keterangan"),
                  TextField(controller: keteranganController, maxLines: 2, decoration: _inputDecor("Detail agenda...")),
                  const SizedBox(height: 16),

                  _buildLabel("Rentang Tanggal"),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final range = await showDateRangePicker(context: context, firstDate: DateTime(2025), lastDate: DateTime(2030), initialDateRange: selectedRange);
                      if (range != null) setDialogState(() => selectedRange = range);
                    },
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Text(selectedRange == null ? "Pilih Tanggal" : "${selectedRange!.start.day}/${selectedRange!.start.month} - ${selectedRange!.end.day}/${selectedRange!.end.month}"),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  ),
                  const SizedBox(height: 16),

                  if (!isEdit) ...[
                    SwitchListTile(
                      title: const Text("Agenda Berulang?", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text("Ulangi setiap bulan", style: TextStyle(fontSize: 11)),
                      value: isRecurring,
                      dense: true,
                      onChanged: (val) => setDialogState(() => isRecurring = val),
                    ),
                    if (isRecurring)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(context: context, initialDate: selectedRange?.end.add(const Duration(days: 30)) ?? DateTime.now().add(const Duration(days: 30)), firstDate: DateTime.now(), lastDate: DateTime(2030));
                            if (date != null) setDialogState(() => untilDate = date);
                          },
                          icon: const Icon(Icons.repeat, size: 18),
                          label: Text(untilDate == null ? "Berulang Hingga Tanggal..." : "Hingga: ${untilDate!.day}/${untilDate!.month}/${untilDate!.year}"),
                          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                        ),
                      ),
                  ],

                  _buildLabel("Status Hari"),
                  DropdownButtonFormField<String>(
                    // FIX: Dropdown menggunakan 'value' bukan 'initialValue'
                    initialValue: status,
                    items: const [
                      DropdownMenuItem(value: 'EFEKTIF', child: Text("HARI EFEKTIF")),
                      DropdownMenuItem(value: 'LIBUR', child: Text("HARI LIBUR")),
                    ],
                    onChanged: (val) => setDialogState(() => status = val!),
                    decoration: _inputDecor(""),
                  ),
                  SwitchListTile(title: const Text("Siswa Libur", style: TextStyle(fontSize: 13)), value: isSiswaLibur, dense: true, onChanged: (val) => setDialogState(() => isSiswaLibur = val)),
                  SwitchListTile(title: const Text("Guru Tetap Masuk", style: TextStyle(fontSize: 13)), value: isGuruMasuk, dense: true, onChanged: (val) => setDialogState(() => isGuruMasuk = val)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty || selectedRange == null) return;
                  if (isRecurring && untilDate == null) return;

                  final lembagaId = ref.read(appContextProvider).lembaga?.id;

                  // FIX: Memastikan mapping ke AgendaModel menggunakan data yang valid
                  final updatedAgenda = AgendaModel(
                    id: isEdit ? agenda.id : null,
                    lembagaId: lembagaId ?? '',
                    tahunAjaranId: activeTA?.id,
                    namaAgenda: nameController.text.trim(),
                    tanggalMulai: selectedRange!.start,
                    tanggalBerakhir: selectedRange!.end,
                    statusHariBelajar: status,
                    scope: scope,
                    programId: scope == 'PROG_SPESIFIK' ? targetProgramId : null,
                    keterangan: keteranganController.text.trim(),
                    isSiswaLibur: isSiswaLibur,
                    isGuruMasuk: isGuruMasuk,
                  );

                  if (isEdit) {
                    await ref.read(agendaNotifierProvider(tahunAjaranId: activeTA?.id ?? '', programId: _selectedProgramFilter).notifier).updateAgenda(updatedAgenda);
                  } else {
                    await ref.read(agendaNotifierProvider(tahunAjaranId: activeTA?.id ?? '', programId: _selectedProgramFilter).notifier).addAgenda(
                      updatedAgenda,
                      isRecurring: isRecurring,
                      untilDate: untilDate,
                    );
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                child: const Text("Simpan", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Agenda?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(onPressed: () async {
            final activeTA = ref.read(appContextProvider).currentTahunAjaran;
            await ref.read(agendaNotifierProvider(tahunAjaranId: activeTA?.id ?? '', programId: _selectedProgramFilter).notifier).deleteAgenda(id);
            if (context.mounted) Navigator.pop(context);
          }, child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  String _getMonthName(int month) => ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month - 1];
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)));
  InputDecoration _inputDecor(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)));
}