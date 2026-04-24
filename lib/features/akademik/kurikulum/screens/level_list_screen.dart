// Lokasi: lib/features/akademik/kurikulum/screens/level_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
// FIX: Update path import sesuai pemisahan provider
import '../providers/level_provider.dart';
import 'level_detail_screen.dart';
// Import widget pendukung (Pastikan file ini dibuat/ada di folder widgets)
import '../widgets/level_grid_view.dart';
import '../widgets/level_table_view.dart';

class LevelListScreen extends ConsumerStatefulWidget {
  final JenjangModel jenjang;
  final bool isLinear; // TAMBAHAN: Logika level tunggal

  const LevelListScreen({
    super.key,
    required this.jenjang,
    this.isLinear = false, // TAMBAHAN
  });

  @override
  ConsumerState<LevelListScreen> createState() => _LevelListScreenState();
}

class _LevelListScreenState extends ConsumerState<LevelListScreen> {
  bool _isGridView = true; // State untuk toggle tampilan
  final Color _emerald = const Color(0xFF10B981);
  final Color _slate = const Color(0xFF1E293B); // TAMBAHAN: Konsistensi Slate 2026

  @override
  Widget build(BuildContext context) {
    // Watch daftar level berdasarkan jenjangId
    final levelAsync = ref.watch(levelListProvider(widget.jenjang.id!));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Standar background modern
      appBar: AppBar(
        title: Text(widget.isLinear ? "Pengaturan Konten" : "Tingkatan Level"),
        backgroundColor: Colors.white,
        foregroundColor: _slate, // PERBAIKAN: Gunakan Slate
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
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
            child: levelAsync.when(
              data: (level) => level.isEmpty
                  ? _buildEmptyState()
                  : _isGridView
                  ? LevelGridView(
                level: level,
                primaryColor: _emerald,
                onAction: (level) => _showActionSheet(context, level),
                onTap: (level) => _navigateToDetail(context, level),
              )
                  : LevelTableView(
                level: level,
                primaryColor: _emerald,
                onAction: (level) => _showActionSheet(context, level),
                onTap: (level) => _navigateToDetail(context, level),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
      // PERBAIKAN: Mengikuti standar Hub, tombol plus di pojok kanan bawah
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLevelheet(context),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "JENJANG ${widget.jenjang.namaJenjang.toUpperCase()}",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.isLinear ? "Unit Materi" : "Daftar Level",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _slate),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MODERN ACTION MENU (BOTTOM SHEET) ---

  void _showActionSheet(BuildContext context, LevelModel level) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Untuk rounded corner
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
              level.namaLevel,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: _slate),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text("Edit Data", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _showAddLevelheet(context, levelToEdit: level);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirm(context, level);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- DIALOG BUAT LEVEL (CONVERTED TO SHEET) ---

  void _showAddLevelheet(BuildContext context, {LevelModel? levelToEdit}) {
    final nameController = TextEditingController(text: levelToEdit?.namaLevel);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                Icon(Icons.stairs_outlined, color: _emerald, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    // PERBAIKAN: Logika Level Tunggal
                    levelToEdit == null
                        ? (widget.isLinear ? "Siapkan Materi" : "Buat Level Baru")
                        : "Edit Konfigurasi",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _slate),
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.isLinear
                  ? "Menyiapkan kontainer materi untuk jenjang linier."
                  : "Tentukan cakupan materi untuk tingkatan ini.",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Text(
                widget.isLinear ? "NAMA KONTAINER" : "NAMA LEVEL",
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.isLinear ? "Contoh: Materi Utama" : "Contoh: Level 3",
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;

                  final levelData = LevelModel(
                    id: levelToEdit?.id,
                    kurikulumId: widget.jenjang.kurikulumId,
                    jenjangId: widget.jenjang.id!,
                    programId: levelToEdit?.programId,
                    namaLevel: nameController.text.trim(),
                    targetTotal: levelToEdit?.targetTotal ?? 0,
                    metrik: levelToEdit?.metrik ?? 'Juz',
                    urutan: levelToEdit?.urutan ?? 0,
                    isExamRequired: levelToEdit?.isExamRequired ?? false,
                    examConfig: levelToEdit?.examConfig,
                  );

                  await ref.read(levelListProvider(widget.jenjang.id!).notifier).saveLevel(levelData);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _emerald,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                    levelToEdit == null ? "SIMPAN" : "UPDATE",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, LevelModel level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelDetailScreen(level: level),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, LevelModel level) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Hapus Data?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Seluruh modul di dalamnya juga akan terhapus."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
              onPressed: () async {
                await ref.read(levelListProvider(widget.jenjang.id!).notifier).deleteLevel(level.id!);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stairs_outlined, size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            const Text("Konten Belum Diatur", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              widget.isLinear
                  ? "Klik tombol + untuk mulai mengatur modul pembelajaran yang akan dipelajari pada jenjang pendidikan ini."
                  : "Klik tombol + untuk menambah tingkatan materi (Level) pada jenjang pendidikan ini.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showAddLevelheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _slate,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                  widget.isLinear ? "Mulai Atur" : "Buat Level Pertama",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            )
          ],
        ),
      ),
    );
  }
}