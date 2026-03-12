// lib/features/akademik/kurikulum/widgets/metrik_table_view.dart

import 'package:flutter/material.dart';
import '../models/kurikulum_model.dart';

class MetrikTableView extends StatelessWidget {
  final List<TargetMetrikModel> targets;
  final Function(TargetMetrikModel) onAction;

  const MetrikTableView({
    super.key,
    required this.targets,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    const Color emerald = Color(0xFF10B981);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            dataRowMaxHeight: 65,
            columns: const [
              DataColumn(label: Text("TIPE", style: _headerStyle)),
              DataColumn(label: Text("MULAI", style: _headerStyle)),
              DataColumn(label: Text("AKHIR", style: _headerStyle)),
              DataColumn(label: Text("KKM", style: _headerStyle)),
              DataColumn(label: Text("AKSI", style: _headerStyle)),
            ],
            rows: targets.map((target) {
              return DataRow(cells: [
                DataCell(Text(target.jenisMetrik,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: emerald))),
                DataCell(Text(target.mulai)),
                DataCell(Text(target.akhir)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: emerald.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text("${target.kkm.toInt()}%",
                        style: const TextStyle(color: emerald, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () => onAction(target),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.blueGrey,
    letterSpacing: 1.1,
  );
}