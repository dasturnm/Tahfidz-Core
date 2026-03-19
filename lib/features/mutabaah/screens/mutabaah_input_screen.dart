// Lokasi: lib/features/mutabaah/screens/mutabaah_input_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart';
import '../../siswa/models/siswa_model.dart';
import '../models/mutabaah_model.dart';
import '../providers/mutabaah_provider.dart';
import '../services/mutabaah_tahfidz_service.dart';

class MutabaahInputScreen extends ConsumerStatefulWidget {
  final SiswaModel siswa;
  final ModulModel modul;

  const MutabaahInputScreen({
    super.key,
    required this.siswa,
    required this.modul,
  });

  @override
  ConsumerState<MutabaahInputScreen> createState() => _MutabaahInputScreenState();
}

class _MutabaahInputScreenState extends ConsumerState<MutabaahInputScreen> {
  final _supabase = Supabase.instance.client;
  final _catatanController = TextEditingController();
  final _nilaiController = TextEditingController();

  // State khusus untuk Tipe Hafalan
  List<Map<String, dynamic>> _surahList = [];
  int? _startSurah, _startAyah, _endSurah, _endAyah;
  double _calculatedPages = 0.0;
  bool _isLoadingPages = false;

  @override
  void initState() {
    super.initState();
    // Ambil daftar surah jika modul bertipe hafalan
    if (widget.modul.tipe == 'HAFALAN') {
      _fetchSurahs();
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    _nilaiController.dispose();
    super.dispose();
  }

  // Mengambil referensi surah dari tabel public.quran_surahs
  Future<void> _fetchSurahs() async {
    try {
      final data = await _supabase
          .from('quran_surahs')
          .select('id, name_id, total_ayah')
          .order('id');
      setState(() => _surahList = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint("Error fetching surahs: $e");
    }
  }

  // Menghitung estimasi halaman menggunakan service
  void _calculateProgress() async {
    if (_startSurah == null || _startAyah == null || _endSurah == null || _endAyah == null) return;

    setState(() => _isLoadingPages = true);
    try {
      final result = await MutabaahTahfidzService().calculateTahfidzPayload(
        surahMulai: _startSurah!,
        ayatMulai: _startAyah!,
        surahAkhir: _endSurah!,
        ayatAkhir: _endAyah!,
      );
      setState(() => _calculatedPages = result['calculated_pages']);
    } catch (e) {
      debugPrint("Error calculating pages: $e");
    } finally {
      setState(() => _isLoadingPages = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(mutabaahProvider);
    const Color emerald = Color(0xFF10B981);
    const Color slate = Color(0xFF1E293B);

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
            const Text("PENGISIAN REKAMAN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 16),

            // FORM BERUBAH BERDASARKAN TIPE
            if (widget.modul.tipe == 'HAFALAN') _buildTahfidzForm(emerald),
            if (widget.modul.tipe == 'AKADEMIK') _buildAkademikForm(emerald),

            const SizedBox(height: 32),
            const Text("CATATAN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _catatanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Tambahkan evaluasi atau catatan khusus...",
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
    return Column(
      children: [
        _surahAyahPicker("MULAI", (s, a) { _startSurah = s; _startAyah = a; _calculateProgress(); }),
        const SizedBox(height: 20),
        _surahAyahPicker("AKHIR", (s, a) { _endSurah = s; _endAyah = a; _calculateProgress(); }),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Estimasi Hafalan:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              _isLoadingPages
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text("${_calculatedPages.toStringAsFixed(2)} Halaman", style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _surahAyahPicker(String label, Function(int?, int?) onUpdate) {
    int? currentSurah;
    int? currentAyah;
    int maxAyah = 0;

    return StatefulBuilder(builder: (context, setLocalState) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey)),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(hintText: "Pilih Surah", border: InputBorder.none),
                    items: _surahList.map((s) => DropdownMenuItem(value: s['id'] as int, child: Text("${s['id']}. ${s['name_id']}"))).toList(),
                    onChanged: (val) {
                      setLocalState(() {
                        currentSurah = val;
                        maxAyah = _surahList.firstWhere((e) => e['id'] == val)['total_ayah'];
                        currentAyah = null;
                      });
                      onUpdate(currentSurah, currentAyah);
                    },
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(hintText: "Ayat", border: InputBorder.none),
                    initialValue: currentAyah,
                    items: List.generate(maxAyah, (i) => DropdownMenuItem(value: i + 1, child: Text("${i + 1}"))),
                    onChanged: (val) {
                      setLocalState(() => currentAyah = val);
                      onUpdate(currentSurah, currentAyah);
                    },
                  ),
                ),
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
          decoration: InputDecoration(
            hintText: "0.0",
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            suffixText: "/ 100",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  void _submitData() async {
    Map<String, dynamic> payload = {};

    if (widget.modul.tipe == 'HAFALAN') {
      if (_startSurah == null || _endAyah == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi rentang ayat hafalan!")));
        return;
      }
      payload = {
        "start_surah": _startSurah,
        "start_ayah": _startAyah,
        "end_surah": _endSurah,
        "end_ayah": _endAyah,
        "calculated_pages": _calculatedPages,
      };
    } else {
      if (_nilaiController.text.isEmpty) return;
      payload = {"nilai": double.tryParse(_nilaiController.text) ?? 0.0};
    }

    final record = MutabaahRecord(
      siswaId: widget.siswa.id!,
      guruId: _supabase.auth.currentUser!.id, // FIX: Menggunakan guruId sesuai model terbaru
      modulId: widget.modul.id!,
      tipeModul: widget.modul.tipe,
      dataPayload: payload,
      catatan: _catatanController.text,
      createdAt: DateTime.now(),
    );

    await ref.read(mutabaahProvider.notifier).submitRecord(record);
    if (mounted) Navigator.pop(context);
  }
}