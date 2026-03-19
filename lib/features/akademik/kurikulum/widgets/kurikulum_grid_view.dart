import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import 'kurikulum_card.dart';
import 'add_kurikulum_sheet.dart';

class KurikulumGridView extends ConsumerWidget {
  final List<KurikulumModel> list;
  final String lembagaId;
  final Color slate;
  final Function(KurikulumModel) onSelect;

  const KurikulumGridView({
    super.key,
    required this.list,
    required this.lembagaId,
    required this.slate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(), // Wajib untuk RefreshIndicator
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // Disesuaikan untuk mobile
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final k = list[index];
        return KurikulumCard(
          kurikulum: k,
          onTap: () => onSelect(k),
          onEdit: () => AddKurikulumSheet.show(
            context: context,
            ref: ref,
            lembagaId: lembagaId,
            kurikulum: k,
            slate: slate,
          ),
          onDelete: () => AddKurikulumSheet.confirmDelete(
            context: context,
            ref: ref,
            lembagaId: lembagaId,
            kurikulum: k,
          ),
        );
      },
    );
  }
}