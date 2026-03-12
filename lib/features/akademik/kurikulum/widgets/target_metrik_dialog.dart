import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kurikulum_model.dart';
import '../providers/kurikulum_provider.dart';

class TargetMetrikDialog extends ConsumerStatefulWidget {
  final ModulModel modul;
  final TargetMetrikModel? targetToEdit; // Penambahan targetToEdit untuk mode Edit
  const TargetMetrikDialog({super.key, required this.modul, this.targetToEdit});

  @override
  ConsumerState<TargetMetrikDialog> createState() => _TargetMetrikDialogState();
}

class _TargetMetrikDialogState extends ConsumerState<TargetMetrikDialog> {
  late String _selectedMetrik;
  late TextEditingController _mulaiController;
  late TextEditingController _akhirController;
  late double _kkmValue;

  // TAMBAHAN: State untuk fitur metrik mutabaah tingkat lanjut
  late String _inputType;
  late TextEditingController _optionsController;
  late bool _isPrimary;
  late bool _hasTarget;
  late TextEditingController _weightController;

  final Color _emerald = const Color(0xFF10B981);
  final Color _slate = const Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    // Inisialisasi data berdasarkan mode (Tambah Baru vs Edit)
    _selectedMetrik = widget.targetToEdit?.jenisMetrik ?? 'JUZ';
    _mulaiController = TextEditingController(text: widget.targetToEdit?.mulai);
    _akhirController = TextEditingController(text: widget.targetToEdit?.akhir);
    _kkmValue = widget.targetToEdit?.kkm ?? 80.0;

    // Inisialisasi state baru
    _inputType = widget.targetToEdit?.inputType ?? 'NUMBER';
    _optionsController = TextEditingController(text: widget.targetToEdit?.options.join(', '));
    _isPrimary = widget.targetToEdit?.isPrimary ?? false;
    _hasTarget = widget.targetToEdit?.hasTarget ?? true;
    _weightController = TextEditingController(text: widget.targetToEdit?.weight.toString() ?? '0');
  }

  @override
  void dispose() {
    _mulaiController.dispose();
    _akhirController.dispose();
    _optionsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Mengubah AlertDialog menjadi Container untuk BottomSheet
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          left: 32, right: 32, top: 32
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.track_changes, color: _emerald, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                    widget.targetToEdit == null ? "Konfigurasi Metrik" : "Edit Metrik",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _slate)
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Tentukan parameter dan cara pengisian nilai untuk modul ini.", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 32),

          // Membungkus form dengan Flexible agar aman jika keyboard muncul
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROW 1: JENIS & TIPE INPUT
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("JENIS METRIK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              value: _selectedMetrik,
                              items: ['JUZ', 'HALAMAN', 'AYAT', 'SURAH', 'POIN', 'BARIS', 'KUALITATIF'],
                              onChanged: (v) => setState(() => _selectedMetrik = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("TIPE INPUT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              value: _inputType,
                              items: ['NUMBER', 'SELECT', 'SCALE', 'TEXT', 'BOOLEAN'],
                              onChanged: (v) => setState(() => _inputType = v!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // OPTIONS (Hanya muncul jika Tipe Input == SELECT)
                  if (_inputType == 'SELECT') ...[
                    const Text("OPSI PILIHAN (Pisahkan dengan koma)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _optionsController,
                      decoration: _inputStyle("Misal: Mumtaz, Jayyid, Maqbul"),
                      style: TextStyle(fontWeight: FontWeight.bold, color: _slate),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // TOGGLES: PRIMARY & HAS TARGET
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: _emerald,
                          title: const Text("Metrik Utama", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: const Text("Penentu naik level", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          value: _isPrimary,
                          onChanged: (v) => setState(() => _isPrimary = v ?? false),
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: _emerald,
                          title: const Text("Pakai Target", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: const Text("Punya batas awal-akhir", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          value: _hasTarget,
                          onChanged: (v) => setState(() => _hasTarget = v ?? false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // CAKUPAN MATERI (Hanya muncul jika Gunakan Target == TRUE)
                  if (_hasTarget) ...[
                    const Text("CAKUPAN MATERI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _mulaiController, decoration: _inputStyle("Mulai"), style: TextStyle(fontWeight: FontWeight.bold, color: _slate))),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.grey)),
                        Expanded(child: TextField(controller: _akhirController, decoration: _inputStyle("Akhir"), style: TextStyle(fontWeight: FontWeight.bold, color: _slate))),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // BOBOT & KKM
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("BOBOT (%)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: _inputStyle("0-100"),
                              style: TextStyle(fontWeight: FontWeight.bold, color: _slate),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("KKM LULUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                                Text("${_kkmValue.toInt()}%", style: TextStyle(fontWeight: FontWeight.w900, color: _emerald, fontSize: 16)),
                              ],
                            ),
                            Slider(
                              value: _kkmValue,
                              min: 0, max: 100,
                              divisions: 20,
                              activeColor: _emerald,
                              inactiveColor: const Color(0xFFF1F5F9),
                              onChanged: (v) => setState(() => _kkmValue = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _saveTarget,
              style: ElevatedButton.styleFrom(
                backgroundColor: _slate,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                  widget.targetToEdit == null ? "SIMPAN METRIK" : "UPDATE METRIK",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Dropdown yang konsisten
  Widget _buildDropdown({required String value, required List<String> items, required void Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          style: TextStyle(color: _slate, fontWeight: FontWeight.bold, fontSize: 14),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
    );
  }

  Future<void> _saveTarget() async {
    // Validasi ringan
    if (_hasTarget && (_mulaiController.text.isEmpty || _akhirController.text.isEmpty)) return;
    if (_inputType == 'SELECT' && _optionsController.text.isEmpty) return;

    final data = TargetMetrikModel(
      id: widget.targetToEdit?.id, // PERBAIKAN: Sertakan ID untuk Update
      modulId: widget.modul.id!,
      jenisMetrik: _selectedMetrik,
      inputType: _inputType,
      options: _inputType == 'SELECT' ? _optionsController.text.split(',').map((e) => e.trim()).toList() : [],
      isPrimary: _isPrimary,
      hasTarget: _hasTarget,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      satuan: _selectedMetrik,
      mulai: _hasTarget ? _mulaiController.text.trim() : '-',
      akhir: _hasTarget ? _akhirController.text.trim() : '-',
      kkm: _kkmValue,
    );

    await ref.read(targetMetrikListProvider(widget.modul.id!).notifier).saveTarget(data);

    // Refresh provider agar data di ModulDetailScreen langsung terupdate
    ref.invalidate(targetMetrikListProvider(widget.modul.id!));
    ref.invalidate(modulListProvider(widget.modul.levelId));

    if (mounted) Navigator.pop(context);
  }
}