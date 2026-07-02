import 'package:flutter/material.dart';

class MutabaahRatingPicker extends StatelessWidget {
  final int currentValue;
  final ValueChanged<int> onRatingSelected;

  const MutabaahRatingPicker({
    super.key,
    required this.currentValue,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("EVALUASI CAPAIAN (SKALA 1-4)", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // FIX: Gunakan Expanded dan penyesuaian label deskripsi lengkap skala 1-4 untuk mencegah overflow
            Expanded(child: _ratingChip(1, "Belum Layak")),
            const SizedBox(width: 4),
            Expanded(child: _ratingChip(2, "Cukup / Perlu Pembinaan")),
            const SizedBox(width: 4),
            Expanded(child: _ratingChip(3, "Baik / Layak")),
            const SizedBox(width: 4),
            Expanded(child: _ratingChip(4, "Sangat Baik")),
          ],
        ),
      ],
    );
  }

  Widget _ratingChip(int value, String label) {
    bool isSelected = currentValue == value;
    Color baseColor = _getRatingColor(value);
    return GestureDetector(
      onTap: () => onRatingSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? baseColor : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(value.toString(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isSelected ? Colors.white : Colors.grey)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int value) {
    switch (value) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.blue;
      case 4: return const Color(0xFF10B981);
      default: return Colors.grey;
    }
  }
}