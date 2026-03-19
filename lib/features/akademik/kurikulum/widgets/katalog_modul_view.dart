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
    var allModul = kurikulumList
        .expand((k) => k.jenjang) // PERBAIKAN: Singular jenjang
        .expand((j) => j.level)
        .expand((l) => l.modul) // PERBAIKAN: Singular modul
        .where((m) => m.namaModul.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    // PERBAIKAN: Sorting Global Modul (Fix Case Sensitivity)
    if (sortBy == "A-Z") {
      allModul.sort((a, b) => a.namaModul.toLowerCase().compareTo(b.namaModul.toLowerCase()));
    } else if (sortBy == "Terbaru") {
      // Karena data dibongkar dari parent yang sudah disortir,
      // kita reversed hasil expand-nya saja untuk tetap konsisten.
      allModul = allModul.reversed.toList();
    }

    if (allModul.isEmpty) return _buildEmptyState();

    return isGridView ? _buildGridView(allModul) : _buildTableView(allModul);
  }

  // ... sisa widget helper tetap identik 100% ...
  Widget _buildGridView(List<ModulModel> modul) { // PERBAIKAN: lowerCamelCase
    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: modul.length,
      itemBuilder: (context, index) => _buildModulCard(modul[index]),
    );
  }

  Widget _buildTableView(List<ModulModel> modul) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      itemCount: modul.length,
      itemBuilder: (context, index) {
        final m = modul[index];
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
              decoration: BoxDecoration(color: emerald.withValues(alpha: 0.1), shape: BoxShape.circle), // PERBAIKAN: withValues
              child: Icon(Icons.layers_outlined, color: emerald, size: 20),
            ),
            title: Text(m.namaModul, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            subtitle: Text("${m.targetPertemuan} Pertemuan • ${m.jenisMetrik}"),
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
            decoration: BoxDecoration(color: emerald.withValues(alpha: 0.1), shape: BoxShape.circle), // PERBAIKAN: withValues
            child: Icon(Icons.layers_outlined, color: emerald, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.namaModul, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text("${m.targetPertemuan} Pertemuan • KKM ${m.kkm.toInt()}%", style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), // PERBAIKAN: withValues
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_clear_outlined, size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            const Text("Katalog Modul Kosong", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
                searchQuery.isEmpty
                    ? "Daftar modul dari seluruh kurikulum akan muncul di sini. Silakan tambahkan jenjang dan unit modul pada tab 'Kurikulum' untuk mengisi katalog ini."
                    : "Modul dengan kata kunci '$searchQuery' tidak ditemukan.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)
            ),
          ],
        ),
      ),
    );
  }
}