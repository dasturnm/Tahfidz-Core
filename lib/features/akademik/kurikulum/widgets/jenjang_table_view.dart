// lib/features/akademik/kurikulum/widgets/jenjang_table_view.dart

import 'package:flutter/material.dart';
import '../models/kurikulum_model.dart';

class JenjangTableView extends StatelessWidget {
  final List<JenjangModel> jenjangs;
  final Function(JenjangModel) onTap;

  const JenjangTableView({
    super.key,
    required this.jenjangs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color emerald = Color(0xFF10B981);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text("NAMA JENJANG", style: _headerStyle)),
            DataColumn(label: Text("INFO", style: _headerStyle)),
            DataColumn(label: Text("AKSI", style: _headerStyle)),
          ],
          rows: jenjangs.map((j) {
            return DataRow(cells: [
              DataCell(
                  Text(j.namaJenjang,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: emerald.withValues(alpha: 0.1), // PERBAIKAN: withValues
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text("${j.level.length} Level",
                      style: const TextStyle(color: emerald, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onPressed: () => onTap(j),
                ),
              ),
            ]);
          }).toList(),
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