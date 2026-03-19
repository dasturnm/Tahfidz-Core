// Lokasi: lib/features/akademik/kurikulum/widgets/pemetaan_kelas_view.dart

import 'package:flutter/material.dart';
import '../models/kurikulum_model.dart';

class PemetaanKelasView extends StatelessWidget {
  final List<KurikulumModel> kurikulumList;
  final Color emerald;
  final Color slate;
  final bool isGridView;
  final String sortBy; // TAMBAHAN

  const PemetaanKelasView({
    super.key,
    required this.kurikulumList,
    this.isGridView = true,
    this.emerald = const Color(0xFF10B981),
    this.slate = const Color(0xFF1E293B),
    this.sortBy = "Terbaru", // TAMBAHAN
  });

  @override
  Widget build(BuildContext context) {
    // Logic Mapping
    var activeMappings = <Map<String, dynamic>>[];
    for (var k in kurikulumList) {
      for (var j in k.jenjang) { // PERBAIKAN: Singular jenjang
        for (var l in j.level) {
          if (l.kelasId != null) {
            activeMappings.add({
              'kelas_name': l.namaKelas,
              'path': "${k.namaKurikulum} > ${j.namaJenjang} > ${l.namaLevel}",
              'is_linear': k.isLinear,
            });
          }
        }
      }
    }

    // PERBAIKAN: Sorting Global Kelas
    if (sortBy == "A-Z") {
      activeMappings.sort((a, b) => (a['kelas_name'] ?? "").toLowerCase().compareTo((b['kelas_name'] ?? "").toLowerCase()));
    } else if (sortBy == "Terbaru") {
      activeMappings = activeMappings.reversed.toList();
    }

    if (activeMappings.isEmpty) return _buildEmptyState();

    return isGridView ? _buildGridView(activeMappings) : _buildTableView(activeMappings);
  }

  Widget _buildGridView(List<Map<String, dynamic>> list) {
    return ListView.builder(
      padding: const EdgeInsets.all(32),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildMappingCard(list[index]),
    );
  }

  Widget _buildTableView(List<Map<String, dynamic>> list) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: slate.withValues(alpha: 0.05), shape: BoxShape.circle), // PERBAIKAN: withValues
              child: Icon(Icons.room_preferences_outlined, color: slate, size: 18),
            ),
            title: Text(item['kelas_name'] ?? "Kelas", style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            subtitle: Text(item['path'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: _buildBadge(item['is_linear'] ? "LINEAR" : "LEVELING", item['is_linear'] ? Colors.orange : emerald),
          ),
        );
      },
    );
  }

  Widget _buildMappingCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.room_preferences_outlined, color: slate, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item['kelas_name'] ?? "Kelas Tanpa Nama", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              _buildBadge(item['is_linear'] ? "LINEAR" : "LEVELING", item['is_linear'] ? Colors.orange : emerald),
            ],
          ),
          const SizedBox(height: 16),
          const Text("ALUR AKADEMIK", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(item['path'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), // PERBAIKAN: withValues
      child: Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.room_preferences_outlined, size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            const Text(
                "Belum Ada Pemetaan Kelas",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E293B))
            ),
            const SizedBox(height: 8),
            const Text(
              "Halaman ini menampilkan kelas yang sudah terhubung dengan kurikulum. Silakan hubungkan kelas melalui menu 'Manajemen Kelas' untuk melihat hasilnya di sini.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}