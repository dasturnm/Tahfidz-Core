import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import '../providers/kurikulum_provider.dart';
import 'level_detail_screen.dart';

class LevelListScreen extends ConsumerWidget {
  final JenjangModel jenjang;

  const LevelListScreen({super.key, required this.jenjang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch daftar level berdasarkan jenjangId
    final levelAsync = ref.watch(levelListProvider(jenjang.id!));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Manajemen Akademik"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF10B981),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildBreadcrumbHeader(context, ref),
          Expanded(
            child: levelAsync.when(
              data: (levels) => levels.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return _buildLevelCard(context, ref, level);
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
                  "JENJANG ${jenjang.namaJenjang.toUpperCase()}",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "2. Tingkatan (Level)",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddLevelDialog(context, ref),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text(
              "BUAT LEVEL",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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

  // --- DIALOG BUAT LEVEL ---

  void _showAddLevelDialog(BuildContext context, WidgetRef ref, {LevelModel? levelToEdit}) {
    final nameController = TextEditingController(text: levelToEdit?.namaLevel);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
                  const Icon(Icons.stairs_outlined, color: Color(0xFF10B981), size: 28),
                  const SizedBox(width: 12),
                  Text(
                      levelToEdit == null ? "Buat Tingkatan (Level)" : "Edit Tingkatan",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text("NAMA LEVEL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Contoh: Level 3 (Juz 28)",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;

                    final levelData = LevelModel(
                      id: levelToEdit?.id,
                      jenjangId: jenjang.id!,
                      namaLevel: nameController.text.trim(),
                      urutan: levelToEdit?.urutan ?? 0,
                    );

                    await ref.read(levelListProvider(jenjang.id!).notifier).saveLevel(levelData);

                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                      levelToEdit == null ? "Simpan Level" : "Update Level",
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
    );
  }

  Widget _buildLevelCard(BuildContext context, WidgetRef ref, LevelModel level) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            "${level.urutan}",
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          level.namaLevel,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "${level.modules.length} MODUL TERPASANG",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ),
        trailing: _buildTrailingMenu(context, ref, level),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LevelDetailScreen(level: level),
            ),
          );
        },
      ),
    );
  }

  // --- MENU AKSI CARD ---
  Widget _buildTrailingMenu(BuildContext context, WidgetRef ref, LevelModel level) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Color(0xFFE2E8F0)),
      onSelected: (value) async {
        if (value == 'edit') {
          _showAddLevelDialog(context, ref, levelToEdit: level);
        } else if (value == 'delete') {
          _showDeleteConfirm(context, ref, level);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text("Edit")])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text("Hapus", style: TextStyle(color: Colors.red))])),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, LevelModel level) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Tingkatan?"),
        content: Text("Seluruh modul di dalam level '${level.namaLevel}' juga akan terhapus. Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
              onPressed: () async {
                await ref.read(levelListProvider(jenjang.id!).notifier).deleteLevel(level.id!);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stairs_outlined, size: 80, color: Color(0xFFF1F5F9)),
          SizedBox(height: 16),
          Text(
            "Belum ada tingkatan/level.",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}