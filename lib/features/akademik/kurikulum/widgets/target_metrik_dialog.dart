import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import '../providers/kurikulum_provider.dart';

class TargetMetrikDialog extends ConsumerStatefulWidget {
  final ModulModel modul;
  const TargetMetrikDialog({super.key, required this.modul});

  @override
  ConsumerState<TargetMetrikDialog> createState() => _TargetMetrikDialogState();
}

class _TargetMetrikDialogState extends ConsumerState<TargetMetrikDialog> {
  String _selectedMetrik = 'JUZ';
  final _mulaiController = TextEditingController();
  final _akhirController = TextEditingController();
  double _kkmValue = 80;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.track_changes, color: Color(0xFF10B981)),
          SizedBox(width: 12),
          Text("Konfigurasi Target", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("JENIS METRIK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedMetrik, // Diperbarui untuk mendukung standar Flutter 2026
                decoration: _inputStyle(""),
                items: ['JUZ', 'HALAMAN', 'AYAT', 'SURAH', 'POIN', 'BARIS'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _selectedMetrik = v!),
              ),
              const SizedBox(height: 24),
              const Text("CAKUPAN MATERI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: _mulaiController, decoration: _inputStyle("Mulai"))),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey)),
                  Expanded(child: TextField(controller: _akhirController, decoration: _inputStyle("Akhir"))),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("KKM LULUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                  Text("${_kkmValue.toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 20)),
                ],
              ),
              Slider(
                value: _kkmValue,
                min: 0, max: 100,
                divisions: 20,
                activeColor: const Color(0xFF10B981),
                inactiveColor: const Color(0xFFF1F5F9),
                onChanged: (v) => setState(() => _kkmValue = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600))
        ),
        ElevatedButton(
          onPressed: _saveTarget,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
          ),
          child: const Text("Simpan Target", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _saveTarget() async {
    if (_mulaiController.text.isEmpty || _akhirController.text.isEmpty) return;

    final data = TargetMetrikModel(
      modulId: widget.modul.id!,
      jenisMetrik: _selectedMetrik,
      satuan: _selectedMetrik,
      mulai: _mulaiController.text.trim(),
      akhir: _akhirController.text.trim(),
      kkm: _kkmValue,
    );

    await ref.read(targetMetrikListProvider(widget.modul.id!).notifier).saveTarget(data);

    // Refresh provider agar data di ModulDetailScreen langsung terupdate
    ref.invalidate(targetMetrikListProvider(widget.modul.id!));
    ref.invalidate(modulListProvider(widget.modul.levelId));

    if (mounted) Navigator.pop(context);
  }
}