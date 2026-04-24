// Lokasi: lib/features/akademik/kurikulum/screens/components/modul_shared_widgets.dart

import 'package:flutter/material.dart';

class ModulSharedWidgets {
  static Widget buildLevelBadge(String namaLevel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_stories_outlined, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "LEVEL INDUK",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                Text(
                  namaLevel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildInstructionBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF10B981), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Sistem menghitung estimasi tanggal lulus berdasarkan hari efektif di program.",
              style: TextStyle(fontSize: 11, color: Color(0xFF065F46)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
    );
  }

  static InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  static Widget buildPolicyBtn(String label, IconData icon, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF10B981) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? const Color(0xFF10B981) : Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: active ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: active ? Colors.white : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}