// Lokasi: lib/features/akademik/kurikulum/screens/components/modul_policy_section.dart

import 'package:flutter/material.dart';
import 'modul_shared_widgets.dart';

class ModulPolicySection extends StatelessWidget {
  final bool isStrict;
  final bool isAllowBelowTarget;
  final bool isAccumulated;
  final bool isSingleBurden;
  final bool showSabqiInMutabaah;
  final bool showManzilInDashboard;
  final bool hasMurojaahToggles; // Tambahan flag visibilitas

  // TAMBAHAN: Tooltip untuk Penjelasan Kebijakan (v2026.04.19)
  final String? strictTooltip;
  final String? toleransiTooltip;
  final String? accumulatedTooltip;
  final String? singleBurdenTooltip;
  final String? sabqiTooltip;
  final String? manzilTooltip;

  final VoidCallback onStrictSelected;
  final VoidCallback onToleransiSelected;
  final VoidCallback onAccumulatedSelected;
  final VoidCallback onSingleBurdenSelected;
  final ValueChanged<bool> onSabqiVisibilityChanged;
  final ValueChanged<bool> onManzilVisibilityChanged;

  const ModulPolicySection({
    super.key,
    required this.isStrict,
    required this.isAllowBelowTarget,
    required this.isAccumulated,
    required this.isSingleBurden,
    required this.showSabqiInMutabaah,
    required this.showManzilInDashboard,
    required this.hasMurojaahToggles, // Wajib diisi dari parent
    this.strictTooltip,
    this.toleransiTooltip,
    this.accumulatedTooltip,
    this.singleBurdenTooltip,
    this.sabqiTooltip,
    this.manzilTooltip,
    required this.onStrictSelected,
    required this.onToleransiSelected,
    required this.onAccumulatedSelected,
    required this.onSingleBurdenSelected,
    required this.onSabqiVisibilityChanged,
    required this.onManzilVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildBtnWithTooltip("Wajib Target", Icons.gavel, isStrict, onStrictSelected, strictTooltip)),
              const SizedBox(width: 8),
              Expanded(child: _buildBtnWithTooltip("Toleransi", Icons.fact_check, isAllowBelowTarget, onToleransiSelected, toleransiTooltip)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildBtnWithTooltip("Akumulasi", Icons.history_edu, isAccumulated, onAccumulatedSelected, accumulatedTooltip)),
              const SizedBox(width: 8),
              Expanded(child: _buildBtnWithTooltip("Beban Tunggal", Icons.event_available, isSingleBurden, onSingleBurdenSelected, singleBurdenTooltip)),
            ],
          ),
          if (hasMurojaahToggles) ...[
            const Divider(height: 24),
            _buildTogglePolicy("Aktifkan Murajaah Sabqi (Guru)", showSabqiInMutabaah, onSabqiVisibilityChanged, sabqiTooltip),
            const SizedBox(height: 8),
            _buildTogglePolicy("Ceklist Murojaah Manzil (Siswa)", showManzilInDashboard, onManzilVisibilityChanged, manzilTooltip),
          ],
        ],
      ),
    );
  }

  Widget _buildBtnWithTooltip(String label, IconData icon, bool isSelected, VoidCallback onTap, String? tip) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        SizedBox(
          width: double.infinity,
          child: ModulSharedWidgets.buildPolicyBtn(label, icon, isSelected, onTap),
        ),
        if (tip != null)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Tooltip(
              message: tip,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF1E293B).withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(color: Colors.white, fontSize: 10),
              showDuration: const Duration(seconds: 5),
              triggerMode: TooltipTriggerMode.tap,
              child: Icon(Icons.info_outline, size: 14, color: isSelected ? Colors.white70 : Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildTogglePolicy(String label, bool value, Function(bool) onChanged, String? tip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
              if (tip != null) ...[
                const SizedBox(width: 6),
                Tooltip(
                  message: tip,
                  triggerMode: TooltipTriggerMode.tap,
                  child: const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: const Color(0xFF10B981),
          onChanged: onChanged,
        ),
      ],
    );
  }
}