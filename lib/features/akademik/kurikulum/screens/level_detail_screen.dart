// Lokasi: lib/features/akademik/kurikulum/screens/level_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
// FIX: Update path import sesuai pemisahan provider
import '../providers/modul_provider.dart';
import 'modul_detail_screen.dart'; // Ditambahkan: Import navigasi detail
// Import widget pendukung (Pastikan file ini dibuat di folder widgets)
import '../widgets/modul_grid_view.dart';
import '../widgets/modul_table_view.dart';

class LevelDetailScreen extends ConsumerStatefulWidget {
  final LevelModel level;

  const LevelDetailScreen({super.key, required this.level});

  @override
  ConsumerState<LevelDetailScreen> createState() => _LevelDetailScreenState();
}

class _LevelDetailScreenState extends ConsumerState<LevelDetailScreen> {
  bool _isGridView = true; // State toggle tampilan
  final Color _emerald = const Color(0xFF10B981);
  final Color _slate = const Color(0xFF1E293B); // TAMBAHAN: Konsistensi Slate 2026

  @override
  Widget build(BuildContext context) {
    // Watch daftar modul di bawah level ini
    final modulAsync = ref.watch(modulListProvider(widget.level.id!));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Manajemen Akademik"),
        backgroundColor: Colors.white, // PERBAIKAN: Gunakan tema terang Hub
        foregroundColor: _slate, // PERBAIKAN: Gunakan Slate
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded), // PERBAIKAN: Rounded icon
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // TOGGLE VIEW BUTTON
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: "Ganti Tampilan",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildBreadcrumbHeader(context),
          Expanded(
            child: modulAsync.when(
              data: (modul) => modul.isEmpty
                  ? _buildEmptyState(context)
                  : _isGridView
                  ? ModulGridView(
                modul: modul,
                onAction: (m) => _showModulActionSheet(context, m),
                onTap: (m) => _navigateToModulDetail(context, m),
              )
                  : ModulTableView(
                modul: modul,
                onAction: (m) => _showModulActionSheet(context, m),
                onTap: (m) => _navigateToModulDetail(context, m),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddModulSheet(context),
        backgroundColor: _slate,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBreadcrumbHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _emerald.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.layers_outlined, color: _emerald, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LEVEL ${widget.level.namaLevel.toUpperCase()}",
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1),
              ),
              Text(
                "Unit Modul Belajar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _slate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- MODERN ACTION MENU (BOTTOM SHEET) ---

  void _showModulActionSheet(BuildContext context, ModulModel modul) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // PERBAIKAN: Untuk rounded corner
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              modul.namaModul,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: _slate),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text("Edit Modul", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _showAddModulSheet(context, modulToEdit: modul);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Hapus Modul", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteModulConfirm(context, modul);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- MODAL TAMBAH/EDIT MODUL ---

  void _showAddModulSheet(BuildContext context, {ModulModel? modulToEdit}) {
    final nameController = TextEditingController(text: modulToEdit?.namaModul);
    final durationController = TextEditingController(text: modulToEdit?.targetPertemuan.toString() ?? "30");
    // Fallback: Jika data lama 'HAFALAN', konversi ke 'TAHFIDZ'
    String selectedTipe = (modulToEdit?.tipe == 'HAFALAN') ? 'TAHFIDZ' : (modulToEdit?.tipe ?? 'BELAJAR BACA');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // PERBAIKAN: Melengkung
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            left: 32,
            right: 32,
            top: 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.layers_outlined, color: _emerald, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        modulToEdit == null ? "Buat Modul" : "Edit Modul",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _slate)
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 12),
              const Text("Tentukan unit belajar untuk level ini.", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 32),
              const Text("NAMA MODUL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Contoh: Iqro Jilid 1-3",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("TIPE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: ['BELAJAR BACA', 'TAJWID', 'TAHSIN', 'TAHFIDZ', 'MATAN', 'HADITS', 'ADAB'].contains(selectedTipe.toUpperCase()) ? selectedTipe.toUpperCase() : 'BELAJAR BACA',
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                              style: TextStyle(color: _slate, fontWeight: FontWeight.bold, fontSize: 14),
                              items: ['BELAJAR BACA', 'TAJWID', 'TAHSIN', 'TAHFIDZ', 'MATAN', 'HADITS', 'ADAB'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (v) => setDialogState(() => selectedTipe = v!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("TARGET PERTEMUAN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontWeight: FontWeight.bold, color: _slate),
                          decoration: InputDecoration(
                            hintText: "30",
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;

                    final modulData = ModulModel(
                      id: modulToEdit?.id,
                      levelId: widget.level.id!,
                      namaModul: nameController.text.trim(),
                      tipe: selectedTipe.toUpperCase(),
                      targetPertemuan: int.tryParse(durationController.text) ?? 30,
                      silabus: modulToEdit?.silabus,
                      isSystemGenerated: modulToEdit?.isSystemGenerated ?? false,
                      jenisMetrik: modulToEdit?.jenisMetrik ?? 'HALAMAN',
                      mulaiKoordinat: modulToEdit?.mulaiKoordinat,
                      akhirKoordinat: modulToEdit?.akhirKoordinat,
                      kkm: modulToEdit?.kkm ?? 80,
                    );

                    await ref.read(modulListProvider(widget.level.id!).notifier).saveModul(modulData);

                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _slate, // PERBAIKAN: Tombol Slate
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                      modulToEdit == null ? "SIMPAN MODUL" : "UPDATE MODUL",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToModulDetail(BuildContext context, ModulModel modul) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModulDetailScreen(level: widget.level, modul: modul),
      ),
    );
  }

  void _showDeleteModulConfirm(BuildContext context, ModulModel modul) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Hapus Unit Modul?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Modul '${modul.namaModul}' akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
              onPressed: () async {
                await ref.read(modulListProvider(widget.level.id!).notifier).deleteModul(modul.id!);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories_outlined, size: 64, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
            const Text("Belum Ada Unit Modul", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 8),
            const Text(
              "Klik tombol + untuk mulai menyusun unit modul belajar. Setiap unit bisa berisi cakupan materi, target pertemuan, dan KKM kelulusan.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showAddModulSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _slate,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Buat Modul Pertama", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}