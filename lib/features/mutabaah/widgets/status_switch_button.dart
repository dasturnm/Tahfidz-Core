import 'package:flutter/material.dart';

/// Widget Custom Switch 3-Way untuk mengontrol Status Keputusan Guru
/// Nilai yang dikembalikan: -1 (Ulang), 0 (Off/Netral), 1 (Lanjut)
class StatusSwitchButton extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const StatusSwitchButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Warna Slate 100
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _buildOption(context, -1, "Ulang", Colors.red),
          _buildOption(context, 0, "Off", Colors.grey),
          _buildOption(context, 1, "Lanjut", Colors.green),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, int optionValue, String label, Color activeColor) {
    final isActive = value == optionValue;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(optionValue),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: activeColor.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}