// Lokasi: lib/features/mutabaah/screens/mutabaah_input_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../akademik/kurikulum/models/kurikulum_model.dart';
import '../../siswa/models/siswa_model.dart';
import '../models/mutabaah_model.dart';
import '../providers/mutabaah_provider.dart';
import '../services/mutabaah_service.dart';
import '../providers/delegasi_provider.dart';

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
  double _calculatedAyahs = 0.0;
  bool _isTargetMet = true;
  bool _isLoadingPages = false;

  // STATE "MUTABAAH PINTAR"
  double _previousDebt = 0.0; // Saldo hutang dari pertemuan sebelumnya
  double _totalTargetSnapshot = 0.0; // Target Modul + Hutang

  // STATE TASMI' (LIVE GRADING)
  final Map<String, int> _penaltyCounts = {
    'itqon_s': 0, 'itqon_t': 0, 'itqon_p': 0,
    'tajwid_k': 0, 'tajwid_s': 0,
    'makhraj_k': 0, 'makhraj_s': 0,
  };
  final Map<String, double> _directScores = {};

  @override
  void initState() {
    super.initState();
    // Mendukung kategori tipe Quran terbaru
    if (['ZIYADAH HAFALAN', 'ZIYADAH TILAWAH', 'MUROJAAH', 'TASMI\''].contains(widget.modul.tipe)) {
      _fetchSurahs();
      _loadDebt(); // Ambil saldo hutang saat form diinisialisasi
    }

    // Inisialisasi skor default untuk Aspek Kategori B (Tasmi')
    if (widget.modul.tipe == 'TASMI\'') {
      final settings = widget.modul.tasmiSettings ?? {};
      settings.forEach((key, val) {
        if (val['active'] == true && (key == 'nada' || key == 'adab' || val['is_custom'] == true)) {
          _directScores[key] = 80.0; // Nilai default awal
        }
      });
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

  Future<void> _loadDebt() async {
    final debt = await MutabaahTahfidzService().getLatestDebt(widget.siswa.id!, widget.modul.id!);
    if (mounted) {
      setState(() {
        _previousDebt = debt;
        _totalTargetSnapshot = widget.modul.targetAmount + (widget.modul.isAccumulated ? debt : 0.0);
      });
    }
  }

  Future<void> _fetchSurahs() async {
    try {
      // FIX: Menghapus total_ayah dari query (karena kolom tidak ada di database).
      final data = await _supabase
          .from('data_mushaf')
          .select('id:surah_number, name_id:surah_name')
          .eq('ayah_number', 1)
          .order('surah_number');

      // FIX: Mapping standar jumlah ayat Al-Quran (Index 1 = Al-Fatihah, Index 114 = An-Nas)
      const totalAyahs = [0, 7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6];

      final seen = <int>{};
      final enrichedData = <Map<String, dynamic>>[];

      for (var e in (data as List)) {
        int sNum = e['id'] as int;
        // Mencegah error duplikasi data pada Dropdown
        if (!seen.contains(sNum)) {
          seen.add(sNum);
          enrichedData.add({
            'id': sNum,
            'name_id': e['name_id'],
            'total_ayah': sNum >= 1 && sNum <= 114 ? totalAyahs[sNum] : 286,
          });
        }
      }

      if (mounted) {
        setState(() => _surahList = enrichedData);
      }
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
        previousDebt: widget.modul.isAccumulated ? _previousDebt : 0.0,
        targetUnit: widget.modul.targetAmountUnit,
      );

      if (mounted) {
        setState(() {
          _calculatedPages = (result['calculated_pages'] as num).toDouble();
          _calculatedLines = (result['calculated_lines'] as num).toDouble();
          _calculatedAyahs = (result['calculated_ayahs'] as num? ?? 0).toDouble();
          _isTargetMet = result['is_target_met'] ?? true;
        });
      }
    } catch (e) {
      debugPrint("Error calculating pages/lines: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingPages = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(mutabaahProvider);
    const Color emerald = Color(0xFF10B981);
    const Color slate = Color(0xFF1E293B);

    final bool isQuranic = ['ZIYADAH HAFALAN', 'ZIYADAH TILAWAH', 'MUROJAAH', 'TASMI\''].contains(widget.modul.tipe);

    // FIX: Menghapus pemanggilan activeModulsBySiswaProvider di dalam build() untuk mencegah Infinite Loop
    // Logika kantong hutang (Delayed Pocket) dihitung dari data hutang (_previousDebt) saja agar lebih aman.
    final bool isDelayedPocket = _previousDebt > 0;

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
            _buildSiswaInfo(emerald, isDelayedPocket),
            const SizedBox(height: 32),
            Text(widget.modul.tipe, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 16),

            if (isQuranic && widget.modul.tipe != 'TASMI\'') _buildTahfidzForm(emerald, isDelayedPocket),
            if (widget.modul.tipe == 'TASMI\'') _buildTasmiGradingForm(emerald),
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

  Widget _buildSiswaInfo(Color color, bool isDelayed) {
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
                Row(
                  children: [
                    // FIX: Membungkus nama modul dengan Expanded agar tidak Overflow (Garis Kuning-Hitam)
                    Expanded(
                      child: Text("Modul: ${widget.modul.namaModul}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    _buildPocketBadge(isDelayed),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW: TASMI' GRADING FORM ---
  Widget _buildTasmiGradingForm(Color color) {
    final settings = widget.modul.tasmiSettings ?? {};
    double currentScore = MutabaahTahfidzService().calculateTasmiScore(settings, _penaltyCounts, _directScores);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _surahAyahPicker(
            label: "RENTANG UJIAN MULAI",
            surahValue: _startSurah, ayahValue: _startAyah,
            onUpdate: (s, a) { setState(() { _startSurah = s; _startAyah = a; }); _calculateProgress(); }
        ),
        const SizedBox(height: 16),
        _surahAyahPicker(
            label: "RENTANG UJIAN AKHIR",
            surahValue: _endSurah, ayahValue: _endAyah,
            onUpdate: (s, a) { setState(() { _endSurah = s; _endAyah = a; }); _calculateProgress(); }
        ),
        const SizedBox(height: 32),

        // Live Score Board
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("LIVE SCORE", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              Text(
                currentScore.toStringAsFixed(1),
                style: TextStyle(color: currentScore >= widget.modul.kkm ? const Color(0xFF10B981) : Colors.orange, fontSize: 28, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Pinalti
        const Text("KATEGORI A: PENGURANGAN (KLIK UNTUK MENGURANGI)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 12),
        if (settings['itqon']?['active'] == true) _buildPenaltyRow("Itqon", ['itqon_s', 'itqon_t', 'itqon_p'], ['[S] Saktah', '[T] Tawaquf', '[P] Pindah']),
        if (settings['tajwid']?['active'] == true) _buildPenaltyRow("Tajwid", ['tajwid_k', 'tajwid_s'], ['[K] Kurang', '[S] Salah']),
        if (settings['makhraj']?['active'] == true) _buildPenaltyRow("Makhraj", ['makhraj_k', 'makhraj_s'], ['[K] Kurang', '[S] Salah']),

        const SizedBox(height: 24),
        const Text("KATEGORI B: SKOR LANGSUNG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 12),
        ..._directScores.keys.map((key) {
          String label = settings[key]?['name'] ?? key.toUpperCase();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$label: ${_directScores[key]?.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Slider(
                value: _directScores[key] ?? 80.0,
                min: 0, max: 100, divisions: 100,
                activeColor: color,
                onChanged: (val) => setState(() => _directScores[key] = val),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPenaltyRow(String title, List<String> keys, List<String> labels) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: List.generate(keys.length, (i) {
                return ActionChip(
                  label: Text("${labels[i]}: ${_penaltyCounts[keys[i]]}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                  backgroundColor: Colors.red.withValues(alpha: 0.05),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
                  onPressed: () => setState(() => _penaltyCounts[keys[i]] = (_penaltyCounts[keys[i]] ?? 0) + 1),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  // --- END TASMI ---

  Widget _buildTahfidzForm(Color color, bool isDelayed) {
    final bool isBelowTarget = !_isTargetMet && _totalTargetSnapshot > 0;

    return Column(
      children: [
        if (widget.modul.isAccumulated && _previousDebt > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.history_edu, color: Colors.red[800], size: 16),
                  const SizedBox(width: 8),
                  Text("Ada hutang hafalan: ${_previousDebt.toInt()} ${widget.modul.targetAmountUnit}",
                      style: TextStyle(color: Colors.red[800], fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

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
                  Text(
                    isDelayed ? "Realisasi Pelunasan:" : "Realisasi:",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
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
              if (_totalTargetSnapshot > 0) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Target Kumulatif: ${_totalTargetSnapshot.toInt()} ${widget.modul.targetAmountUnit}", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
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

        // Tampilkan pilar murajaah secara kondisional berdasarkan flag modul
        if (widget.modul.tipe == 'MUROJAAH' || widget.modul.showSabqiInMutabaah) _buildMurojaahFields(color),
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

        // Sabqi Input: Muncul jika modul Murojaah atau modul Ziyadah yang mengaktifkan Sabqi
        if (widget.modul.tipe == 'MUROJAAH' || widget.modul.showSabqiInMutabaah)
          _pilarInput(
            label: "SABQI (Target: ${widget.modul.sabqiAmount} Hal)",
            controller: _sabqiInputController,
            hint: "Jumlah halaman yang disetor...",
          ),

        const SizedBox(height: 16),

        // Manzil Input: Muncul hanya jika tipe Murojaah murni
        if (widget.modul.tipe == 'MUROJAAH')
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

    double achieved = 0.0;
    double deficit = 0.0;

    if (isQuranic) {
      if (_startSurah == null || _startAyah == null || _endSurah == null || _endAyah == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi rentang ayat!")));
        return;
      }

      if (widget.modul.tipe == 'TASMI\'') {
        final settings = widget.modul.tasmiSettings ?? {};
        double finalScore = MutabaahTahfidzService().calculateTasmiScore(settings, _penaltyCounts, _directScores);
        achieved = finalScore;
        _isTargetMet = achieved >= widget.modul.kkm; // Lulus jika >= KKM

        payload = {
          "start_surah": _startSurah, "start_ayah": _startAyah,
          "end_surah": _endSurah, "end_ayah": _endAyah,
          "tasmi_score": finalScore,
          "penalty_counts": _penaltyCounts,
          "direct_scores": _directScores,
        };
      } else {
        // Tentukan capaian berdasarkan unit target
        achieved = widget.modul.targetAmountUnit == 'HALAMAN' ? _calculatedPages : (widget.modul.targetAmountUnit == 'AYAT' ? _calculatedAyahs : _calculatedLines);

        // Hitung kekurangan (hutang baru)
        deficit = _totalTargetSnapshot - achieved;
        if (deficit < 0) deficit = 0; // Tidak ada hutang jika melampaui target

        // VALIDASI KEBIJAKAN WAJIB TARGET (STRICT)
        if (!_isTargetMet && _totalTargetSnapshot > 0) {
          if (widget.modul.isStrict) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red[800], content: Text("Gagal Simpan: Sesuai kebijakan 'Wajib Target', setoran minimal (Target + Hutang) harus ${_totalTargetSnapshot.toInt()} ${widget.modul.targetAmountUnit.toLowerCase()}.")));
            return;
          } else if (widget.modul.isAllowBelowTarget) {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Konfirmasi Target"),
                content: Text("Setoran santri di bawah target kumulatif (Kurang: ${deficit.toInt()} ${widget.modul.targetAmountUnit}). Tetap simpan?"),
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
          "calculated_ayahs": _calculatedAyahs,
          "sabqi_realisasi": double.tryParse(_sabqiInputController.text) ?? 0.0,
          "manzil_realisasi": double.tryParse(_manzilInputController.text) ?? 0.0,
        };
      }
    } else {
      payload = {"nilai": double.tryParse(_nilaiController.text) ?? 0.0};
      achieved = payload["nilai"];
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
      dataPayload: payload,
      targetSnapshot: _totalTargetSnapshot,
      achievedAmount: achieved,
      sabqiAmount: double.tryParse(_sabqiInputController.text) ?? 0.0,
      debtCreated: widget.modul.isAccumulated ? deficit : 0.0,
      isPassedTarget: _isTargetMet,
      catatan: _catatanController.text,
      createdAt: DateTime.now(),
    );

    await ref.read(mutabaahProvider.notifier).submitRecord(record);
    if (mounted) Navigator.pop(context);
  }

  Widget _buildPocketBadge(bool isDelayed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDelayed ? Colors.orange.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isDelayed ? "KANTONG HUTANG" : "KANTONG BERJALAN",
        style: TextStyle(
          color: isDelayed ? Colors.orange : Colors.blue,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}