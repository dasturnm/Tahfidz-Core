// lib/features/akademik/kurikulum/widgets/modul_table_view.dart

import 'package:flutter/material.dart';
import '../models/kurikulum_model.dart';

class ModulTableView extends StatelessWidget {
  final List<ModulModel> modul;
  final Function(ModulModel) onAction;
  final Function(ModulModel) onTap;

  const ModulTableView({
    super.key,
    required this.modul,
    required this.onAction,
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
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          columns: const [
            DataColumn(label: Text("MODUL / MATERI", style: _headerStyle)),
            DataColumn(label: Text("TIPE", style: _headerStyle)),
            DataColumn(label: Text("TARGET", style: _headerStyle)),
            DataColumn(label: Text("AKSI", style: _headerStyle)),
          ],
          rows: modul.map((m) {
            return DataRow(cells: [
              DataCell(
                  InkWell(
                      onTap: () => onTap(m),
                      child: Text(m.namaModul, style: const TextStyle(fontWeight: FontWeight.bold, color: emerald))
                  )
              ),
              DataCell(Text(m.tipe)),
              DataCell(Text("${m.targetPertemuan} Pertemuan")),
              DataCell(
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                    onPressed: () => onAction(m),
                  )
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  static const _headerStyle = TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey);
}