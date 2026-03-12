import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import '../providers/kurikulum_provider.dart';
// Import widget pendukung (Pastikan file ini dibuat di folder widgets)
import '../widgets/metrik_grid_view.dart';
import '../widgets/metrik_table_view.dart';
import '../widgets/target_metrik_dialog.dart';

class ModulDetailScreen extends ConsumerStatefulWidget {
  final LevelModel level;
  final ModulModel modul;

  const ModulDetailScreen({super.key, required this.level, required this.modul});

  @override
  ConsumerState<ModulDetailScreen> createState() => _ModulDetailScreenState();
}

class _ModulDetailScreenState extends ConsumerState<ModulDetailScreen> {
  bool _isGridView = true; // State toggle tampilan
  final Color _emerald = const Color(0xFF10B981);
  final Color _slate = const Color(0xFF1E293B); // TAMBAHAN: Konsistensi Slate 2026

  @override
  Widget build(BuildContext context) {
    // Watch daftar metrik untuk modul ini
    final metrikAsync = ref.watch(targetMetrikListProvider(widget.modul.id!));

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
            child: metrikAsync.when(
              data: (targets) => targets.isEmpty
                  ? _buildEmptyState(context)
                  : _isGridView
                  ? MetrikGridView(
                targets: targets,
                onAction: (target) => _showMetrikActionSheet(context, target),
              )
                  : MetrikTableView(
                targets: targets,
                onAction: (target) => _showMetrikActionSheet(context, target),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
      // PERBAIKAN: Menggunakan FAB icon agar konsisten dengan Hub dan Level List
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMetrikSheet(context),
        backgroundColor: _slate,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBreadcrumbHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 24), // PERBAIKAN: Padding konsisten Hub
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "LEVEL ${widget.level.namaLevel.toUpperCase()}",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: _emerald,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.modul.namaModul,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _slate),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBadge(widget.modul.tipe, _emerald),
              const SizedBox(width: 8),
              _buildBadge("${widget.modul.durasiHari} Hari", const Color(0xFF64748B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05), // PERBAIKAN: withValues
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.1)), // PERBAIKAN: withValues
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  // --- MODERN ACTION MENU (BOTTOM SHEET) ---

  void _showMetrikActionSheet(BuildContext context, TargetMetrikModel target) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // PERBAIKAN: Background transparan
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)), // PERBAIKAN: Melengkung
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
              "Opsi Metrik",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: _slate),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text("Edit Metrik", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _showAddMetrikSheet(context, targetToEdit: target);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Hapus Metrik", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirm(context, target);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddMetrikSheet(BuildContext context, {TargetMetrikModel? targetToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // PERBAIKAN: Background transparan
      builder: (ctx) => TargetMetrikDialog(
        modul: widget.modul,
        targetToEdit: targetToEdit,
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, TargetMetrikModel target) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Hapus Target?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Data target metrik ini akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
              onPressed: () async {
                await ref.read(targetMetrikListProvider(widget.modul.id!).notifier).deleteTarget(target.id!);
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.ads_click, size: 80, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          const Text("Belum ada target metrik pengujian.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddMetrikSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _slate,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Buat Metrik Pertama", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}