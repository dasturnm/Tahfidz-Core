import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kurikulum_provider.dart';
import '../models/kurikulum_model.dart';
import 'level_form_screen.dart';

class KurikulumDetailScreen extends ConsumerWidget {
  final KurikulumModel kurikulum;

  const KurikulumDetailScreen({super.key, required this.kurikulum});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelAsync = ref.watch(levelListProvider(kurikulum.id!));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(kurikulum.namaKurikulum),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: levelAsync.when(
        data: (levels) => levels.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: levels.length,
          itemBuilder: (context, index) {
            final level = levels[index];
            return _buildLevelCard(context, level);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LevelFormScreen(kurikulumId: kurikulum.id!),
            ),
          );
        },
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add_road, color: Colors.white), // Diganti dari add_step
        label: const Text("Tambah Level", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, LevelModel level) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
          child: Text(
            "${level.urutan}",
            style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(level.namaLevel, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Target: ${level.targetHafalan ?? 'Belum diatur'}"),
        trailing: const Icon(Icons.edit_note, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LevelFormScreen(
                kurikulumId: kurikulum.id!,
                level: level,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stairs_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("Belum ada tingkatan/level.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}