// Lokasi: lib/features/akademik/kurikulum/screens/kurikulum_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kurikulum_provider.dart';
import '../models/kurikulum_model.dart';
import '../widgets/kurikulum_card.dart';
import '../widgets/add_kurikulum_sheet.dart'; // FIX: Import sheet terpusat

class KurikulumListScreen extends ConsumerWidget {
  final String lembagaId;
  final bool isGridView;
  final String searchQuery;
  final Function(KurikulumModel) onSelect;

  const KurikulumListScreen({
    super.key,
    required this.lembagaId,
    required this.isGridView,
    required this.searchQuery,
    required this.onSelect,
  });

  final Color _emerald = const Color(0xFF10B981);
  final Color _slate = const Color(0xFF1E293B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau provider dengan parameter pencarian (Poin 3)
    final kurikulumAsync = ref.watch(kurikulumListProvider(lembagaId, search: searchQuery));

    return Scaffold(
      backgroundColor: Colors.transparent, // Agar menyatu dengan Hub
      body: kurikulumAsync.when(
        data: (list) {
          if (list.isEmpty) return _buildEmptyState(context);

          return isGridView
              ? _buildKurikulumGrid(context, list, ref)
              : _buildKurikulumTable(context, list, ref);
        },
        loading: () => Center(child: CircularProgressIndicator(color: _emerald)),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddKurikulumSheet.show(
          context: context,
          ref: ref,
          lembagaId: lembagaId,
          slate: _slate,
        ), // FIX: Menggunakan form standar yang mendukung pilihan Program
        backgroundColor: _slate,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // PERBAIKAN POIN 4 & 5: Implementasi Tabel Kurikulum
  Widget _buildKurikulumTable(BuildContext context, List<KurikulumModel> list, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: const Color(0xFFF1F5F9)),
          child: DataTable(
            horizontalMargin: 24,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text("NAMA KURIKULUM", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8)))),
              DataColumn(label: Text("STRUKTUR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8)))),
              DataColumn(label: Text("STATUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8)))),
              DataColumn(label: Text("", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8)))),
            ],
            rows: list.map((k) => DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(k.namaKurikulum, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: k.isLinear ? Colors.orange.withValues(alpha: 0.1) : _emerald.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              k.isLinear ? "LINEAR" : "HIERARKI",
                              style: TextStyle(color: k.isLinear ? Colors.orange : _emerald, fontSize: 8, fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: k.promotionPolicy == 'flexible' ? Colors.blue.withValues(alpha: 0.1) : Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              k.promotionPolicy == 'flexible' ? "BEBAS" : "SEKUENSIAL",
                              style: TextStyle(color: k.promotionPolicy == 'flexible' ? Colors.blue : Colors.purple, fontSize: 8, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // POIN 5: Menampilkan ringkasan statistik (Level, Modul, Metrik)
                DataCell(Text(
                    "${k.totalLevel} Lvl, ${k.totalModul} Mod, ${k.totalTarget} Metrik", // PERBAIKAN: Sync ke getter 'totalModul'
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))
                )),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: k.isActive ? _emerald.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    k.isActive ? "AKTIF" : "DRAFT",
                    style: TextStyle(color: k.isActive ? _emerald : Colors.grey, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                )),
                DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                          onPressed: () => onSelect(k),
                        ),
                      ],
                    )
                ),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildKurikulumGrid(BuildContext context, List<KurikulumModel> list, WidgetRef ref) {
    double width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 1200 ? 3 : (width > 800 ? 2 : 1);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final k = list[index];
        return KurikulumCard(
          kurikulum: k,
          onTap: () => onSelect(k),
          onDelete: () => ref.read(kurikulumListProvider(lembagaId, search: searchQuery).notifier).deleteKurikulum(k.id!),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_motion_rounded, size: 64, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? "Belum ada kurikulum."
                : "Tidak ditemukan hasil untuk '$searchQuery'",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}