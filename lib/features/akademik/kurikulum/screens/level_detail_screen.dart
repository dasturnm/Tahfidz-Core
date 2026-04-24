// Lokasi: lib/features/akademik/kurikulum/screens/level_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
// FIX: Update path import sesuai pemisahan provider
import '../providers/modul_provider.dart';
import 'modul_detail_screen.dart'; // Ditambahkan: Import navigasi detail
import 'modul_form_screen.dart'; // TAMBAHAN: Import navigasi form lengkap
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
        onPressed: () {
          // LANGSUNG NAVIGASI: Ke Form Lengkap untuk Tambah Modul Baru
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModulFormScreen(level: widget.level),
            ),
          );
        },
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
                // LANGSUNG NAVIGASI: Ke Form Lengkap untuk Edit
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModulFormScreen(level: widget.level, modul: modul),
                  ),
                );
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
                try {
                  await ref.read(modulListProvider(widget.level.id!).notifier).deleteModul(modul.id!);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Modul berhasil dihapus"), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text("Gagal menghapus modul: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
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
              "Klik tombol + untuk mulai menyusun unit modul belajar. Setiap unit bisa berisi cakupan materi, target pertemuan, and KKM kelulusan.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // LANGSUNG NAVIGASI: Ke Form Lengkap untuk Modul Pertama
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModulFormScreen(level: widget.level),
                  ),
                );
              },
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