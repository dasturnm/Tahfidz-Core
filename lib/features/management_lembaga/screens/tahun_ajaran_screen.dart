import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_context_provider.dart';
import '../models/tahun_ajaran_model.dart';
import '../providers/tahun_ajaran_provider.dart'; // Baru: Import notifier

class TahunAjaranScreen extends ConsumerStatefulWidget {
  const TahunAjaranScreen({super.key});

  @override
  ConsumerState<TahunAjaranScreen> createState() => _TahunAjaranScreenState();
}

class _TahunAjaranScreenState extends ConsumerState<TahunAjaranScreen> {
  // --- FUNGSI SET AKTIF ---
  Future<void> _setActiveYear(String taId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(tahunAjaranListProvider.notifier).setTahunAjaranAktif(taId);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text("Tahun ajaran aktif berhasil diperbarui!")),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text("Gagal memperbarui: $e")),
      );
    }
  }

  // --- FUNGSI DIALOG TAMBAH (SEMI-OTOMATIS) ---
  void _showAddTADialog() {
    final notifier = ref.read(tahunAjaranListProvider.notifier);
    final controller = TextEditingController(text: notifier.sarankanLabelTahun()); // Saran Otomatis
    DateTimeRange? selectedRange;
    String selectedSemester = "Ganjil";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Tambah Tahun Ajaran"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Label Tahun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Contoh: 2025/2026",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Semester", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedSemester,
                  items: const [
                    DropdownMenuItem(value: "Ganjil", child: Text("Ganjil")),
                    DropdownMenuItem(value: "Genap", child: Text("Genap")),
                  ],
                  onChanged: (val) => setDialogState(() => selectedSemester = val!),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                const Text("Rentang Waktu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                    );
                    if (range != null) setDialogState(() => selectedRange = range);
                  },
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(selectedRange == null
                      ? "Pilih Tanggal Mulai & Selesai"
                      : "${selectedRange!.start.day}/${selectedRange!.start.month}/${selectedRange!.start.year} - ${selectedRange!.end.day}/${selectedRange!.end.month}/${selectedRange!.end.year}"),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isEmpty || selectedRange == null) return;

                final lembagaId = ref.read(appContextProvider).lembaga?.id;
                final newTA = TahunAjaranModel(
                  id: '',
                  lembagaId: lembagaId!,
                  labelTahun: controller.text.trim(),
                  semester: selectedSemester,
                  tanggalMulai: selectedRange!.start,
                  tanggalSelesai: selectedRange!.end,
                  isAktif: false,
                );

                await ref.read(tahunAjaranListProvider.notifier).addTahunAjaran(newTA);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI EDIT & HAPUS ---
  void _showEditTADialog(TahunAjaranModel ta) {
    final controller = TextEditingController(text: ta.labelTahun);
    DateTimeRange? selectedRange = DateTimeRange(start: ta.tanggalMulai, end: ta.tanggalSelesai);
    String selectedSemester = ta.semester;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Tahun Ajaran"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Label Tahun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Semester", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedSemester,
                  items: const [
                    DropdownMenuItem(value: "Ganjil", child: Text("Ganjil")),
                    DropdownMenuItem(value: "Genap", child: Text("Genap")),
                  ],
                  onChanged: (val) => setDialogState(() => selectedSemester = val!),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                const Text("Rentang Waktu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      initialDateRange: selectedRange,
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                    );
                    if (range != null) setDialogState(() => selectedRange = range);
                  },
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text("${selectedRange!.start.day}/${selectedRange!.start.month}/${selectedRange!.start.year} - ${selectedRange!.end.day}/${selectedRange!.end.month}/${selectedRange!.end.year}"),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isEmpty) return;

                final updatedTA = TahunAjaranModel(
                  id: ta.id,
                  lembagaId: ta.lembagaId,
                  labelTahun: controller.text.trim(),
                  semester: selectedSemester,
                  tanggalMulai: selectedRange!.start,
                  tanggalSelesai: selectedRange!.end,
                  isAktif: ta.isAktif,
                );

                await ref.read(tahunAjaranListProvider.notifier).updateTahunAjaran(updatedTA);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Simpan Perubahan"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTA(String taId, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Tahun Ajaran"),
        content: Text("Yakin ingin menghapus $label?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(tahunAjaranListProvider.notifier).deleteTahunAjaran(taId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taAsync = ref.watch(tahunAjaranListProvider);
    final currentActiveId = ref.watch(appContextProvider).lembaga?.tahunAjaranAktifId;

    return Scaffold(
      appBar: AppBar(title: const Text("Tahun Ajaran")),
      body: taAsync.when(
        data: (tahunAjaranList) {
          if (tahunAjaranList.isEmpty) {
            return const Center(child: Text("Belum ada data tahun ajaran."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tahunAjaranList.length,
            itemBuilder: (context, index) {
              final ta = tahunAjaranList[index];
              final bool isAktif = ta.id == currentActiveId;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isAktif ? const Color(0xFF10B981) : Colors.grey.shade200,
                    width: isAktif ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  title: Text(ta.labelTahun, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Semester ${ta.semester}\n${ta.tanggalMulai.day}/${ta.tanggalMulai.month} - ${ta.tanggalSelesai.day}/${ta.tanggalSelesai.month}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isAktif
                          ? const Chip(
                        label: Text("AKTIF", style: TextStyle(color: Colors.white, fontSize: 10)),
                        backgroundColor: Color(0xFF10B981),
                      )
                          : TextButton(
                        onPressed: () => _setActiveYear(ta.id),
                        child: const Text("Set Aktif"),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (val) {
                          if (val == 'edit') {
                            _showEditTADialog(ta);
                          } else if (val == 'delete') {
                            _deleteTA(ta.id, ta.labelTahun);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text("Edit")),
                          const PopupMenuItem(value: 'delete', child: Text("Hapus", style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Gagal memuat data: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTADialog,
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}