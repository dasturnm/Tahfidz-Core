import 'package:flutter/material.dart';
import '../models/kelas_model.dart';

class KelasCard extends StatelessWidget {
  final KelasModel kelas;
  final VoidCallback onDelete;

  const KelasCard({super.key, required this.kelas, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
          child: Text(
            kelas.level?.substring(0, 1).toUpperCase() ?? 'K',
            style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          kelas.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tingkat: ${kelas.level ?? '-'}"),
            Text(
              "Wali: ${kelas.waliKelas?.nama ?? 'Belum ditentukan'}",
              style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}