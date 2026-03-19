import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import 'add_kurikulum_sheet.dart';

class KurikulumTableView extends ConsumerWidget {
  final List<KurikulumModel> list;
  final String lembagaId;
  final Color emerald;
  final Color slate;
  final Function(KurikulumModel) onSelect;

  const KurikulumTableView({
    super.key,
    required this.list,
    required this.lembagaId,
    required this.emerald,
    required this.slate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(), // Wajib untuk RefreshIndicator
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final k = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    k.namaKurikulum,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildBadge(k.isLinear ? "LINEAR" : "HIERARKI", k.isLinear ? Colors.orange : emerald),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "${k.jenjang.length} Jng | ${k.totalLevel} Lvl | ${k.totalModul} Mod",
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
              onSelected: (val) async {
                if (val == 'edit') {
                  AddKurikulumSheet.show(
                    context: context,
                    ref: ref,
                    lembagaId: lembagaId,
                    kurikulum: k,
                    slate: slate,
                  );
                }
                if (val == 'delete') {
                  AddKurikulumSheet.confirmDelete(
                    context: context,
                    ref: ref,
                    lembagaId: lembagaId,
                    kurikulum: k,
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text("Edit")),
                const PopupMenuItem(value: 'delete', child: Text("Hapus", style: TextStyle(color: Colors.red))),
              ],
            ),
            onTap: () => onSelect(k),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}