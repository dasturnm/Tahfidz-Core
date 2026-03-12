import 'package:flutter/material.dart';
import '../models/kurikulum_model.dart';

class KatalogModulView extends StatelessWidget {
  final List<KurikulumModel> kurikulumList;
  final String searchQuery;
  final Color emerald;
  final bool isGridView;
  final String sortBy; // TAMBAHAN

  const KatalogModulView({
    super.key,
    required this.kurikulumList,
    required this.searchQuery,
    this.isGridView = true,
    this.emerald = const Color(0xFF10B981),
    this.sortBy = "Terbaru", // TAMBAHAN
  });

  @override
  Widget build(BuildContext context) {
    // Logic Flattener
    var allModules = kurikulumList
        .expand((k) => k.jenjangs)
        .expand((j) => j.levels)
        .expand((l) => l.modules)
        .where((m) => m.namaModul.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    // PERBAIKAN: Sorting Global Modul
    if (sortBy == "A-Z") {
      allModules.sort((a, b) => a.namaModul.toLowerCase().compareTo(b.namaModul.toLowerCase()));
    } else if (sortBy == "Terbaru") {
      // Karena data dibongkar dari parent yang sudah disortir,
      // kita reversed hasil expand-nya saja untuk tetap konsisten.
      allModules = allModules.reversed.toList();
    }

    if (allModules.isEmpty) return _buildEmptyState();

    return isGridView ? _buildGridView(allModules) : _buildTableView(allModules);
  }

  // ... sisa widget helper tetap identik 100% ...
  Widget _buildGridView(List<ModulModel> modules) {
    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: modules.length,
      itemBuilder: (context, index) => _buildModulCard(modules[index]),
    );
  }

  Widget _buildTableView(List<ModulModel> modules) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final m = modules[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: emerald.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.layers_outlined, color: emerald, size: 20),
            ),
            title: Text(m.namaModul, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            subtitle: Text("${m.targets.length} Metrik"),
            trailing: _buildBadge(m.tipe, Colors.blue),
          ),
        );
      },
    );
  }

  Widget _buildModulCard(ModulModel m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: emerald.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.layers_outlined, color: emerald, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.namaModul, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text("${m.targets.length} Metrik Pencapaian", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          _buildBadge(m.tipe, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(searchQuery.isEmpty ? "Belum ada materi di katalog." : "Materi tidak ditemukan.", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}