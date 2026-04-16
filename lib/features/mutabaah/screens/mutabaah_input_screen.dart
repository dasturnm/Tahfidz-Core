// Lokasi: lib/features/mutabaah/screens/mutabaah_input_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart';
import '../../siswa/models/siswa_model.dart';
import '../models/mutabaah_model.dart';
import '../providers/mutabaah_provider.dart';
import '../services/mutabaah_service.dart';
import '../providers/delegasi_provider.dart'; // FIX: Untuk deteksi audit delegasi

class MutabaahInputScreen extends ConsumerStatefulWidget {
  final SiswaModel siswa;
  final ModulModel modul;

  const MutabaahInputScreen({
    super.key,
    required this.siswa,
    required this.modul,
  });

  @override
  ConsumerState<MutabaahInputScreen> createState() => _ModulInputScreenState();
}

class _ModulInputScreenState extends ConsumerState<MutabaahInputScreen> {
  final _supabase = Supabase.instance.client;
  final _catatanController = TextEditingController();
  final _nilaiController = TextEditingController();

  // Controller tambahan untuk Murojaah
  final _sabqiInputController = TextEditingController();
  final _manzilInputController = TextEditingController();

  // State khusus untuk Tipe Hafalan/Al-Quran
  List<Map<String, dynamic>> _surahList = [];
  int? _startSurah, _startAyah, _endSurah, _endAyah;
  double _calculatedPages = 0.0;
  double _calculatedLines = 0.0;
  double _calculatedAyahs = 0.0; // TAMBAHAN: Pendukung Independensi Metrik
  bool _isTargetMet = true;
  bool _isLoadingPages = false;

  @override
  void initState() {
    super.initState();
    // Mendukung kategori tipe Quran terbaru
    if (['ZIYADAH HAFALAN', 'ZIYADAH TILAWAH', 'MUROJAAH', 'TASMI\''].contains(widget.modul.tipe)) {
      _fetchSurahs();
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    _nilaiController.dispose();
    _sabqiInputController.dispose();
    _manzilInputController.dispose();
    super.dispose();
  }

  Future<void> _fetchSurahs() async {
    try {
      final data = await _supabase
          .from('data_mushaf')
          .select('id:surah_number, name_id:surah_name, total_ayah')
          .eq('ayah_number', 1)
          .order('surah_number');
      setState(() => _surahList = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint("Error fetching surahs: $e");
    }
  }

  void _calculateProgress() async {
    if (_startSurah == null || _startAyah == null || _endSurah == null || _endAyah == null) return;

    setState(() => _isLoadingPages = true);
    try {
      final result = await MutabaahTahfidzService().calculateTahfidzPayload(
        surahMulai: _startSurah!,
        ayatMulai: _startAyah!,
        surahAkhir: _endSurah!,
        ayatAkhir: _endAyah!,
        targetAmount: widget.modul.targetAmount,
        targetUnit: widget.modul.targetAmountUnit, // FIX: Menggunakan unit target dari modul
      );

      setState(() {
        _calculatedPages = (result['calculated_pages'] as num).toDouble();
        _calculatedLines = (result['calculated_lines'] as num).toDouble();
        _calculatedAyahs = (result['calculated_ayahs'] as num? ?? 0).toDouble(); // Simpan hasil hitung ayat
        _isTargetMet = result['is_target_met'] ?? true;
      });
    } catch (e) {
      debugPrint("Error calculating pages/lines: $e");
    } finally {
      setState(() => _isLoadingPages = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(mutabaahProvider);
    const Color emerald = Color(0xFF10B981);
    const Color slate = Color(0xFF1E293B);

    final bool isQuranic = ['ZIYADAH HAFALAN', 'ZIYADAH TILAWAH', 'MUROJAAH', 'TASMI\''].contains(widget.modul.tipe);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Input Progres", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: slate,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSiswaInfo(emerald),
            const SizedBox(height: 32),
            Text(widget.modul.tipe, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 16),

            if (isQuranic) _buildTahfidzForm(emerald),
            if (widget.modul.tipe == 'DINIYAH' || widget.modul.tipe == 'TAHSIN') _buildAkademikForm(emerald),

            const SizedBox(height: 32),
            const Text("CATATAN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _catatanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Evaluasi makhraj, tajwid, atau kelancaran...",
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: submitState.isLoading ? null : _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: slate,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: submitState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SIMPAN MUTABAAH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiswaInfo(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: const Icon(Icons.person_outline, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.siswa.namaLengkap, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A))),
                Text("Modul: ${widget.modul.namaModul}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTahfidzForm(Color color) {
    final double target = widget.modul.targetAmount;
    final bool isBelowTarget = !_isTargetMet && target > 0;

    return Column(
      children: [
        _surahAyahPicker(
            label: "MULAI",
            surahValue: _startSurah,
            ayahValue: _startAyah,
            onUpdate: (s, a) {
              setState(() { _startSurah = s; _startAyah = a; });
              _calculateProgress();
            }
        ),
        const SizedBox(height: 20),
        _surahAyahPicker(
            label: "AKHIR",
            surahValue: _endSurah,
            ayahValue: _endAyah,
            onUpdate: (s, a) {
              setState(() { _endSurah = s; _endAyah = a; });
              _calculateProgress();
            }
        ),
        const SizedBox(height: 32),

        // Ringkasan Realisasi
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isBelowTarget ? Colors.orange.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: isBelowTarget ? Border.all(color: Colors.orange.withValues(alpha: 0.3)) : null,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Realisasi:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  _isLoadingPages
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                      widget.modul.targetAmountUnit == 'HALAMAN'
                          ? "${_calculatedPages.toStringAsFixed(1)} Halaman"
                          : widget.modul.targetAmountUnit == 'AYAT'
                          ? "${_calculatedAyahs.toInt()} Ayat"
                          : "${_calculatedLines.toInt()} Baris",
                      style: TextStyle(color: isBelowTarget ? Colors.orange : color, fontWeight: FontWeight.w900, fontSize: 18)
                  ),
                ],
              ),
              if (target > 0) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Target: ${target.toInt()} ${widget.modul.targetAmountUnit}", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                    Text(
                      isBelowTarget ? "DIBAWAH TARGET" : "TARGET TERCAPAI",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isBelowTarget ? Colors.orange : color),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        if (widget.modul.tipe == 'MUROJAAH') _buildMurojaahFields(color),
      ],
    );
  }

  Widget _buildMurojaahFields(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text("PILAR MURAJAAH", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 16),

        // Sabqi Input
        _pilarInput(
          label: "SABQI (Target: ${widget.modul.sabqiAmount} Hal)",
          controller: _sabqiInputController,
          hint: "Jumlah halaman yang disetor...",
        ),
        const SizedBox(height: 16),

        // Manzil Input
        _pilarInput(
          label: "MANZIL (${widget.modul.manzilType == 'fixed' ? 'Target: ${widget.modul.manzilAmount.toInt()} Hal' : 'Target: ${widget.modul.manzilAmount.toInt()}%'})",
          controller: _manzilInputController,
          hint: "Realisasi manzil hari ini...",
        ),
      ],
    );
  }

  Widget _pilarInput({required String label, required TextEditingController controller, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _surahAyahPicker({required String label, required int? surahValue, required int? ayahValue, required Function(int?, int?) onUpdate}) {
    int maxAyah = 0;
    if (surahValue != null && _surahList.isNotEmpty) {
      maxAyah = _surahList.firstWhere((e) => e['id'] == surahValue)['total_ayah'] as int;
    }
    return StatefulBuilder(builder: (context, setLocalState) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey)),
            Row(
              children: [
                Expanded(flex: 2, child: DropdownButtonFormField<int>(decoration: const InputDecoration(hintText: "Surah", border: InputBorder.none), initialValue: surahValue, items: _surahList.map((s) => DropdownMenuItem(value: s['id'] as int, child: Text("${s['id']}. ${s['name_id']}", style: const TextStyle(fontSize: 13)))).toList(), onChanged: (val) { setLocalState(() => onUpdate(val, null)); })),
                const SizedBox(height: 24, child: VerticalDivider()),
                Expanded(child: DropdownButtonFormField<int>(decoration: const InputDecoration(hintText: "Ayat", border: InputBorder.none), initialValue: ayahValue, items: List.generate(maxAyah, (i) => DropdownMenuItem(value: i + 1, child: Text("${i + 1}"))), onChanged: (val) { setLocalState(() => onUpdate(surahValue, val)); })),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAkademikForm(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SKOR / NILAI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: _nilaiController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(hintText: "0.0", filled: true, fillColor: const Color(0xFFF8FAFC), suffixText: "/ 100", border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
        ),
      ],
    );
  }

  void _submitData() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    final bool isQuranic = ['ZIYADAH HAFALAN', 'ZIYADAH TILAWAH', 'MUROJAAH', 'TASMI\''].contains(widget.modul.tipe);
    Map<String, dynamic> payload = {};

    if (isQuranic) {
      if (_startSurah == null || _startAyah == null || _endSurah == null || _endAyah == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi rentang ayat!")));
        return;
      }

      // LOGIKA VALIDASI KEBIJAKAN BLUEPRINT FINAL
      if (!_isTargetMet && widget.modul.targetAmount > 0) {
        if (widget.modul.isStrict) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red[800], content: Text("Gagal Simpan: Sesuai kebijakan 'Wajib Target', setoran minimal harus ${widget.modul.targetAmount.toInt()} ${widget.modul.targetAmountUnit.toLowerCase()}.")));
          return;
        } else if (widget.modul.isAllowBelowTarget) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Konfirmasi Target"),
              content: const Text("Setoran santri di bawah target. Tetap simpan?"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("BATAL")),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("TETAP SIMPAN", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
              ],
            ),
          );
          if (confirm != true) return;
        }
      }

      payload = {
        "start_surah": _startSurah, "start_ayah": _startAyah,
        "end_surah": _endSurah, "end_ayah": _endAyah,
        "calculated_pages": _calculatedPages, "calculated_lines": _calculatedLines,
        "calculated_ayahs": _calculatedAyahs, // Simpan realisasi unit Ayat ke DB
        "sabqi_realisasi": double.tryParse(_sabqiInputController.text) ?? 0.0,
        "manzil_realisasi": double.tryParse(_manzilInputController.text) ?? 0.0,
      };
    } else {
      payload = {"nilai": double.tryParse(_nilaiController.text) ?? 0.0};
    }

    final String originalGuruId = widget.siswa.guruId ?? '';
    final bool isSubstitute = currentUser.id != originalGuruId;
    String? activeDelegasiId;
    if (isSubstitute) {
      try {
        final delegations = ref.read(incomingDelegationsProvider).value ?? [];
        activeDelegasiId = delegations.firstWhere((d) => d.kelasId == widget.siswa.kelasId).id;
      } catch (_) {}
    }

    final record = MutabaahRecord(
      siswaId: widget.siswa.id ?? '', guruId: currentUser.id,
      originalGuruId: originalGuruId, isDelegasi: isSubstitute,
      delegasiId: activeDelegasiId, payrollStatus: 'pending',
      modulId: widget.modul.id ?? '', tipeModul: widget.modul.tipe,
      dataPayload: payload, catatan: _catatanController.text,
      createdAt: DateTime.now(),
    );

    await ref.read(mutabaahProvider.notifier).submitRecord(record);
    if (mounted) Navigator.pop(context);
  }
}