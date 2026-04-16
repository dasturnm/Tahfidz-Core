// Lokasi: lib/features/keuangan/widgets/keuangan_card.dart

import 'package:flutter/material.dart';
import '../models/salary_settings_model.dart';

class KeuanganCard extends StatelessWidget {
  final SalarySettingsModel data; // FIX: Menggunakan model yang benar
  final VoidCallback? onTap;

  const KeuanganCard({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        // FIX: Menampilkan ID karena SalarySettingsModel tidak memiliki getter .label
        title: Text("Pengaturan Gaji: ${data.id ?? '-'}"),
        onTap: onTap,
      ),
    );
  }
}