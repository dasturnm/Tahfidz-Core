// lib/features/akademik/kurikulum/widgets/level_table_view.dart

import 'package:flutter/material.dart';
import '../models/kurikulum_model.dart';

class LevelTableView extends StatelessWidget {
  final List<LevelModel> level;
  final Color primaryColor;
  final Function(LevelModel) onAction;
  final Function(LevelModel) onTap;

  const LevelTableView({
    super.key,
    required this.level,
    required this.primaryColor,
    required this.onAction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            dataRowMaxHeight: 70,
            dividerThickness: 1,
            columns: [
              DataColumn(label: _buildHeader("NO")),
              DataColumn(label: _buildHeader("NAMA LEVEL")),
              DataColumn(label: _buildHeader("TARGET")),
              DataColumn(label: _buildHeader("MODUL")),
              DataColumn(label: _buildHeader("AKSI")),
            ],
            rows: level.map((l) { // PERBAIKAN: Hindari shadowing variabel 'level'
              return DataRow(
                cells: [
                  DataCell(Text(l.urutan.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(
                      InkWell(
                        onTap: () => onTap(l),
                        child: Text(l.namaLevel, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                      )
                  ),
                  DataCell(Text("${l.targetTotal} ${l.metrik}")),
                  DataCell(Text("${l.modul.length} Materi")), // PERBAIKAN: Sync ke model singular 'modul'
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onPressed: () => onAction(l),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
        letterSpacing: 1.1,
      ),
    );
  }
}