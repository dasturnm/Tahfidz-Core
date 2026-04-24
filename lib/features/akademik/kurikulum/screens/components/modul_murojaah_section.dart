// Lokasi: lib/features/akademik/kurikulum/screens/components/modul_murojaah_section.dart

import 'package:flutter/material.dart';
import 'modul_shared_widgets.dart';

class ModulMurojaahSection extends StatelessWidget {
  final TextEditingController sabqiController;
  final String sabqiUnit;
  final String manzilType;
  final TextEditingController manzilAmountController;
  final ValueChanged<String> onSabqiUnitChanged;
  final ValueChanged<String> onManzilTypeChanged;

  const ModulMurojaahSection({
    super.key,
    required this.sabqiController,
    required this.sabqiUnit,
    required this.manzilType,
    required this.manzilAmountController,
    required this.onSabqiUnitChanged,
    required this.onManzilTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModulSharedWidgets.buildLabel("PILAR MURAJAAH (STANDARDIZED)"),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.star, color: Colors.orange),
                title: Text("SABAQ", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Hafalan baru (Merujuk pada modul Ziyadah)", style: TextStyle(fontSize: 11)),
              ),
              const Divider(),
              _buildMurojaahSabqiRow(),
              const Divider(),
              _buildMurojaahManzilRow(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMurojaahSabqiRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SABQI (Hafalan Kemarin)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: sabqiController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: ModulSharedWidgets.inputStyle("Angka"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                initialValue: sabqiUnit,
                decoration: ModulSharedWidgets.inputStyle("Satuan"),
                items: ['JUZ', 'HALAMAN', 'BARIS'].map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => onSabqiUnitChanged(v!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMurojaahManzilRow(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("MANZIL (Hafalan Lama)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            IconButton(
              onPressed: () => _showManzilInfo(context),
              icon: const Icon(Icons.info_outline, size: 18, color: Colors.blue),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: manzilType,
              items: const [
                DropdownMenuItem(value: 'fixed', child: Text("Angka")),
                DropdownMenuItem(value: 'percentage', child: Text("Persen"))
              ],
              onChanged: (v) => onManzilTypeChanged(v!),
            ),
          ],
        ),
        TextFormField(
          controller: manzilAmountController,
          textAlign: TextAlign.right,
          decoration: InputDecoration(hintText: manzilType == 'fixed' ? "Juz / Halaman" : "Contoh: 10 (%)"),
        ),
      ],
    );
  }

  void _showManzilInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("💡 Info Manzil"),
        content: const Text("Penelitian menunjukkan bahwa hafalan yang baik itu bisa mutar dalam jangka waktu 30 hari - 40 hari. Disarankan memilih persentase 4% agar siklus murojaah terjaga dengan baik."),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("MENGERTI"))],
      ),
    );
  }
}