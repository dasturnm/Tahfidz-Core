import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import '../providers/kurikulum_provider.dart';
import 'modul_detail_screen.dart'; // Ditambahkan: Import navigasi detail

class LevelDetailScreen extends ConsumerWidget {
  final LevelModel level;

  const LevelDetailScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch daftar modul di bawah level ini
    final modulAsync = ref.watch(modulListProvider(level.id!));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Manajemen Akademik", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildBreadcrumbHeader(context, ref), // Ditambahkan parameter ref
          Expanded(
            child: modulAsync.when(
              data: (modules) => modules.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final modul = modules[index];
                  return _buildModulCard(context, ref, modul);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "JENJANG TAHSIN / LEVEL ${level.namaLevel.toUpperCase()}",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "3. Unit Modul",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddModulDialog(context, ref),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text(
              "TAMBAH MODUL",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // --- DIALOG TAMBAH/EDIT MODUL ---

  void _showAddModulDialog(BuildContext context, WidgetRef ref, {ModulModel? modulToEdit}) {
    final nameController = TextEditingController(text: modulToEdit?.namaModul);
    final durationController = TextEditingController(text: modulToEdit?.durasiHari.toString() ?? "30");
    String selectedTipe = modulToEdit?.tipe ?? 'Hafalan';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: const EdgeInsets.all(32),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.layers_outlined, color: Color(0xFF10B981), size: 28),
                    const SizedBox(width: 12),
                    Text(
                        modulToEdit == null ? "Modul Baru" : "Edit Modul",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text("NAMA MODUL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Contoh: Iqro Jilid 1-3",
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("TIPE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: ['Hafalan', 'Tahsin', 'Teori', 'Ujian'].contains(selectedTipe) ? selectedTipe : 'Hafalan',
                                isExpanded: true,
                                items: ['Hafalan', 'Tahsin', 'Teori', 'Ujian'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onChanged: (v) => setDialogState(() => selectedTipe = v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("DURASI (HARI)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "30",
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty) return;

                      final modulData = ModulModel(
                        id: modulToEdit?.id,
                        levelId: level.id!,
                        namaModul: nameController.text.trim(),
                        tipe: selectedTipe.toUpperCase(),
                        durasiHari: int.tryParse(durationController.text) ?? 30,
                      );

                      await ref.read(modulListProvider(level.id!).notifier).saveModul(modulData);

                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                        modulToEdit == null ? "Simpan Modul" : "Update Modul",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
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

  Widget _buildModulCard(BuildContext context, WidgetRef ref, ModulModel modul) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModulDetailScreen(level: level, modul: modul),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris 1: Badge Tipe & Menu Aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      modul.tipe.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _buildTrailingMenu(context, ref, modul),
                ],
              ),
              const SizedBox(height: 20),
              // Baris 2: Nama Modul
              Text(
                modul.namaModul,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 20),
              // Baris 3: Footer (Durasi & Metrik)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${modul.durasiHari} Hari Belajar",
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.track_changes, size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        "${modul.targets.length} METRIK",
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MENU AKSI MODUL ---
  Widget _buildTrailingMenu(BuildContext context, WidgetRef ref, ModulModel modul) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, color: Color(0xFFE2E8F0)),
      onSelected: (value) async {
        if (value == 'edit') {
          _showAddModulDialog(context, ref, modulToEdit: modul);
        } else if (value == 'delete') {
          _showDeleteModulConfirm(context, ref, modul);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text("Edit")])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text("Hapus", style: TextStyle(color: Colors.red))])),
      ],
    );
  }

  void _showDeleteModulConfirm(BuildContext context, WidgetRef ref, ModulModel modul) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Unit Modul?"),
        content: Text("Modul '${modul.namaModul}' akan dihapus permanen dari kurikulum."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
              onPressed: () async {
                await ref.read(modulListProvider(level.id!).notifier).deleteModul(modul.id!);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 80, color: Colors.grey[100]),
          const SizedBox(height: 16),
          const Text(
            "Belum ada unit modul belajar.",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}